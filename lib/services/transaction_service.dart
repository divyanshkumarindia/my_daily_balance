import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing transactions in Supabase
class TransactionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new transaction
  Future<void> createTransaction({
    required String useCaseType,
    required double amount,
    required String transactionType, // 'Receipt' or 'Payment'
    String? category,
    String? description,
    String? paymentMode, // 'Cash', 'Bank', 'Other'
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      await _supabase.from('transactions').insert({
        'user_id': user.id,
        'use_case_type': useCaseType,
        'amount': amount,
        'transaction_type': transactionType,
        'category': category,
        'description': description,
        'payment_mode': paymentMode,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error creating transaction: $e');
      rethrow;
    }
  }

  /// Get transactions stream with filtering
  Stream<List<Map<String, dynamic>>> getTransactionsStream({
    String? useCaseType,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool isDescending = true,
  }) {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    var query = _supabase
        .from('transactions')
        .stream(primaryKey: ['id']).eq('user_id', user.id);

    // Apply filters (note: stream doesn't support all filters, may need to filter in-memory)
    // For now, we'll use basic filtering and handle complex filters client-side

    return query.map((data) {
      var filtered = data;

      // Filter by use case type
      if (useCaseType != null) {
        filtered =
            filtered.where((t) => t['use_case_type'] == useCaseType).toList();
      }

      // Filter by category
      if (category != null) {
        filtered = filtered.where((t) => t['category'] == category).toList();
      }

      // Filter by date range
      if (startDate != null || endDate != null) {
        filtered = filtered.where((t) {
          final createdAt = DateTime.parse(t['created_at']);
          if (startDate != null && createdAt.isBefore(startDate)) return false;
          if (endDate != null && createdAt.isAfter(endDate)) return false;
          return true;
        }).toList();
      }

      // Sort by created_at
      filtered.sort((a, b) {
        final aTime = DateTime.parse(a['created_at']);
        final bTime = DateTime.parse(b['created_at']);
        return isDescending ? bTime.compareTo(aTime) : aTime.compareTo(bTime);
      });

      return filtered;
    });
  }

  /// Update a transaction
  Future<void> updateTransaction(
    String id, {
    double? amount,
    String? category,
    String? description,
    String? paymentMode,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final updates = <String, dynamic>{};
      if (amount != null) updates['amount'] = amount;
      if (category != null) updates['category'] = category;
      if (description != null) updates['description'] = description;
      if (paymentMode != null) updates['payment_mode'] = paymentMode;

      if (updates.isEmpty) return;

      await _supabase
          .from('transactions')
          .update(updates)
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
      print('❌ Error updating transaction: $e');
      rethrow;
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      await _supabase
          .from('transactions')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
      print('❌ Error deleting transaction: $e');
      rethrow;
    }
  }

  /// Get total for a specific use case and transaction type
  Future<double> getTotal({
    required String useCaseType,
    required String transactionType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      var query = _supabase
          .from('transactions')
          .select('amount')
          .eq('user_id', user.id)
          .eq('use_case_type', useCaseType)
          .eq('transaction_type', transactionType);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final data = await query;
      return data.fold<double>(
          0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
    } catch (e) {
      print('❌ Error calculating total: $e');
      return 0.0;
    }
  }
}
