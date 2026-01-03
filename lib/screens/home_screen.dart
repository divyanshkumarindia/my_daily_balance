import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/accounting_model.dart';
import '../models/accounting.dart';
import '../services/recent_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserType? selectedUseCase;
  String description = 'Description will appear here';

  // display titles for dropdown; can be overridden by user-saved values
  final Map<UserType, String> displayTitles = {};

  final Map<UserType, String> descriptions = {
    UserType.personal:
        'Manage personal and family finances with income and expense tracking.',
    UserType.business:
        'Track sales, purchases, and business transactions efficiently.',
    UserType.institute: 'Manage fees, donations, and organizational finances.',
    UserType.other: 'Custom tracking for your specific needs.',
  };

  @override
  void initState() {
    super.initState();
    _loadPageTitles();
    _loadRecents();
    // Load default page type after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDefaultPageType();
    });
  }

  Future<void> _loadDefaultPageType() async {
    final model = Provider.of<AccountingModel>(context, listen: false);
    final defaultPage = model.defaultPageType;

    if (defaultPage != null && defaultPage.isNotEmpty) {
      UserType? selectedType;
      switch (defaultPage) {
        case 'Personal':
          selectedType = UserType.personal;
          break;
        case 'Business':
          selectedType = UserType.business;
          break;
        case 'Institute':
          selectedType = UserType.institute;
          break;
        case 'Other':
          selectedType = UserType.other;
          break;
      }

      if (selectedType != null) {
        setState(() {
          selectedUseCase = selectedType;
          description =
              descriptions[selectedType] ?? 'Description will appear here';
        });
      }
    }
  }

  List<RecentPage> _recents = [];

  Future<void> _loadRecents() async {
    final list = await RecentService.listRecent();
    if (mounted) setState(() => _recents = list);
  }

  UserType _userTypeForTemplate(String key) {
    switch (key) {
      case 'family':
        return UserType.personal;
      case 'business':
        return UserType.business;
      case 'institute':
        return UserType.institute;
      default:
        return UserType.other;
    }
  }

  String _routeForTemplate(String key) {
    switch (key) {
      case 'family':
        return '/accounting/family';
      case 'business':
        return '/accounting/business';
      case 'institute':
        return '/accounting/institute';
      default:
        return '/accounting/other';
    }
  }

  Future<void> _loadPageTitles() async {
    // initialize with defaults
    for (var ut in UserType.values) {
      displayTitles[ut] = userTypeConfigs[ut]!.name;
    }
    // try load saved overrides
    for (var ut in UserType.values) {
      final saved = await AccountingModel.loadSavedPageTitle(ut);
      if (saved != null && saved.isNotEmpty) {
        displayTitles[ut] = saved;
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF18181B) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Kaccha-Pakka Khata',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF27272A) : Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Color.fromRGBO(99, 102, 241, 0.2)
                        : const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF6366F1),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Receipts & Payments Tracker',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 32),

                // Main Card
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Your Use Case',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dropdown
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3F3F46)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF52525B)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<UserType>(
                            value: selectedUseCase,
                            hint: Text(
                              'Choose...',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFA1A1AA)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: isDark
                                  ? const Color(0xFFA1A1AA)
                                  : const Color(0xFF64748B),
                            ),
                            dropdownColor:
                                isDark ? const Color(0xFF3F3F46) : Colors.white,
                            items: UserType.values.map((ut) {
                              return DropdownMenuItem(
                                value: ut,
                                child: Text(
                                  displayTitles[ut] ??
                                      userTypeConfigs[ut]!.name,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedUseCase = val;
                                description = descriptions[val] ??
                                    'Description will appear here';
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3F3F46)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedUseCase == null
                              ? null
                              : () async {
                                  final model = AccountingModel(
                                      userType: selectedUseCase!);
                                  await model.loadFromPrefs();
                                  String route = '/accounting';
                                  switch (selectedUseCase!) {
                                    case UserType.personal:
                                      route = '/accounting/family';
                                      break;
                                    case UserType.business:
                                      route = '/accounting/business';
                                      break;
                                    case UserType.institute:
                                      route = '/accounting/institute';
                                      break;
                                    case UserType.other:
                                      route = '/accounting/other';
                                      break;
                                  }
                                  await Navigator.pushNamed(context, route,
                                      arguments: model);
                                  await _loadPageTitles();
                                  await _loadRecents();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Continue to Accounting',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Recent Pages Section
                if (_recents.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF27272A) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Pages',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(
                          _recents.length > 3 ? 3 : _recents.length,
                          (idx) {
                            final recent = _recents[idx];
                            final userType =
                                _userTypeForTemplate(recent.templateKey);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tileColor: isDark
                                    ? const Color(0xFF3F3F46)
                                    : const Color(0xFFF1F5F9),
                                leading: Icon(
                                  Icons.history,
                                  color: const Color(0xFF6366F1),
                                ),
                                title: Text(
                                  recent.displayTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                subtitle: Text(
                                  userTypeConfigs[userType]!.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFFA1A1AA)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: isDark
                                      ? const Color(0xFFA1A1AA)
                                      : const Color(0xFF64748B),
                                ),
                                onTap: () async {
                                  final model =
                                      AccountingModel(userType: userType);
                                  await model.loadFromPrefs();
                                  final route =
                                      _routeForTemplate(recent.templateKey);
                                  await Navigator.pushNamed(context, route,
                                      arguments: model);
                                  await _loadPageTitles();
                                  await _loadRecents();
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                // Features Section
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeatureItem(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Track\nReceipts',
                        isDark: isDark,
                      ),
                      _buildFeatureItem(
                        icon: Icons.payments_outlined,
                        label: 'Track\nPayments',
                        isDark: isDark,
                      ),
                      _buildFeatureItem(
                        icon: Icons.assessment_outlined,
                        label: 'Detailed\nReports',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color:
                    isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
