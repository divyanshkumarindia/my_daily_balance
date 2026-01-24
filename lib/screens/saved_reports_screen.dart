import 'dart:async';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:my_daily_balance_flutter/services/report_service.dart';
import 'package:my_daily_balance_flutter/state/app_state.dart';
import 'package:my_daily_balance_flutter/theme.dart';
import 'report_viewer_screen.dart';

class SavedReportsScreen extends StatefulWidget {
  const SavedReportsScreen({super.key});

  @override
  State<SavedReportsScreen> createState() => _SavedReportsScreenState();
}

class _SavedReportsScreenState extends State<SavedReportsScreen> {
  final ReportService _reportService = ReportService();
  final TextEditingController _searchController = TextEditingController();

  // Stream state
  late Stream<List<Map<String, dynamic>>> _reportsStream;
  Timer? _debounce;

  // Filter state
  bool _isDescending = true;
  String _searchQuery = '';
  String? _selectedUseCase; // null = All, or 'Personal', 'Business', etc.

  // Optimistic delete state
  final Set<String> _pendingDeleteIds = {};
  final Map<String, bool> _animatingOut = {};
  Timer? _pendingDeleteTimer;
  Map<String, dynamic>? _pendingDeleteReport;

  @override
  void initState() {
    super.initState();
    // Initialize filter from AppState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.activeUseCaseString != null) {
        setState(() {
          _selectedUseCase = appState.activeUseCaseString;
          _refreshReports();
        });
      } else {
        _refreshReports();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _pendingDeleteTimer?.cancel();
    super.dispose();
  }

  void _refreshReports() {
    setState(() {
      _reportsStream = _reportService.getReportsStream(
        query: _searchQuery,
        isDescending: _isDescending,
        useCaseType: _selectedUseCase,
      );
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = value;
          _refreshReports();
        });
      }
    });
  }

  void _deleteReport(Map<String, dynamic> report) {
    final reportId = report['id'].toString();

    // Cancel any existing pending delete
    _pendingDeleteTimer?.cancel();

    // Start slide-out animation
    setState(() {
      _animatingOut[reportId] = true;
    });

    // Wait for animation to complete, then mark as deleted
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _pendingDeleteReport = report;
          _pendingDeleteIds.add(reportId);
          _animatingOut.remove(reportId);
        });
      }
    });

    // Show SnackBar with Undo option
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report Deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: _undoDelete,
        ),
      ),
    );

    // Start timer to actually delete after 4 seconds
    _pendingDeleteTimer = Timer(const Duration(seconds: 4), () async {
      if (mounted && _pendingDeleteIds.contains(reportId)) {
        try {
          await _reportService.deleteReport(reportId);
          if (mounted) {
            setState(() {
              _pendingDeleteIds.remove(reportId);
              if (_pendingDeleteReport == report) {
                _pendingDeleteReport = null;
              }
            });
          }
        } catch (e) {
          // If delete fails, restore the item
          if (mounted) {
            _undoDelete();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete report: $e')),
            );
          }
        }
      }
    });
  }

  void _undoDelete() {
    _pendingDeleteTimer?.cancel();
    if (_pendingDeleteReport != null) {
      final reportId = _pendingDeleteReport!['id'].toString();
      setState(() {
        _pendingDeleteIds.remove(reportId);
        _pendingDeleteReport = null;
      });
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Saved Reports'),
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isDescending = !_isDescending;
                _refreshReports();
              });
            },
            icon: Icon(
              _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            tooltip: _isDescending ? 'Newest First' : 'Oldest First',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by type or date...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Use Case Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', null, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Personal', 'Personal', isDark,
                    color: const Color(0xFF00C853)),
                const SizedBox(width: 8),
                _buildFilterChip('Business', 'Business', isDark,
                    color: const Color(0xFF2563EB)),
                const SizedBox(width: 8),
                _buildFilterChip('Institute', 'Institute', isDark,
                    color: const Color(0xFF7C3AED)),
                const SizedBox(width: 8),
                _buildFilterChip('Other', 'Other', isDark,
                    color: const Color(0xFFF59E0B)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reports List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _reportsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading reports',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  );
                }

                final reports = snapshot.data ?? [];

                // Filter out items that are pending deletion (optimistic UI)
                final displayReports = reports
                    .where(
                        (r) => !_pendingDeleteIds.contains(r['id'].toString()))
                    .toList();

                if (displayReports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open_outlined,
                          size: 64,
                          color: isDark ? Colors.white30 : Colors.black26,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No matching reports found'
                              : 'No saved reports yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: displayReports.length,
                  itemBuilder: (context, index) {
                    final report = displayReports[index];
                    return _buildDismissibleReportCard(context, report, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleReportCard(
    BuildContext context,
    Map<String, dynamic> report,
    bool isDark,
  ) {
    final reportId = report['id'].toString();
    final isAnimatingOut = _animatingOut[reportId] ?? false;

    return AnimatedSlide(
      offset: isAnimatingOut ? const Offset(-1.0, 0.0) : Offset.zero,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Slidable(
        key: Key(reportId),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (_) => _deleteReport(report),
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete, color: Colors.white, size: 24),
                  SizedBox(height: 4),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        child: _buildReportCard(context, report, isDark),
      ),
    );
  }

  Widget _buildReportCard(
      BuildContext context, Map<String, dynamic> report, bool isDark) {
    // Safely parse dates
    DateTime? reportDate;
    if (report['report_date'] != null) {
      reportDate = DateTime.tryParse(report['report_date']);
    }

    final type = report['report_type'] ?? 'Report';

    // Attempt to extract title from JSONB if available or use generic
    String title = '$type Report';
    if (report['report_data'] != null &&
        report['report_data']['pageTitle'] != null) {
      title = report['report_data']['pageTitle'];
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF1F2937) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.analytics_outlined,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reportDate != null
                        ? DateFormat('dd MMM yyyy, hh:mm a')
                            .format(reportDate.toLocal())
                        : 'Unknown Date',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Use Case Badge
                      if (report['use_case_type'] != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getUseCaseColor(report['use_case_type'])
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _getUseCaseColor(report['use_case_type'])
                                  .withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            report['use_case_type'],
                            style: TextStyle(
                              fontSize: 10,
                              color: _getUseCaseColor(report['use_case_type']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportViewerScreen(
                      reportData: report['report_data'] ?? {},
                      reportType: report['report_type'] ?? 'Normal',
                      reportDate: reportDate != null
                          ? DateFormat('dd MMM yyyy').format(reportDate)
                          : '',
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[400] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? useCase, bool isDark,
      {Color? color}) {
    final isSelected = _selectedUseCase == useCase;
    final primaryColor = color ?? AppTheme.primaryColor;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedUseCase = selected ? useCase : null;
          _refreshReports();
        });
      },
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      selectedColor: primaryColor.withValues(alpha: 0.2),
      checkmarkColor: primaryColor,
      labelStyle: TextStyle(
        color: isSelected
            ? primaryColor
            : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? primaryColor
              : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
        ),
      ),
    );
  }

  Color _getUseCaseColor(String? useCase) {
    switch (useCase) {
      case 'Personal':
        return const Color(0xFF00C853);
      case 'Business':
        return const Color(0xFF2563EB);
      case 'Institute':
        return const Color(0xFF7C3AED);
      case 'Other':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }
}
