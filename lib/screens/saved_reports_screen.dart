import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../state/accounting_model.dart';
import '../models/accounting.dart';
import 'category_reports_screen.dart';

class SavedReportsScreen extends StatefulWidget {
  const SavedReportsScreen({super.key});

  @override
  State<SavedReportsScreen> createState() => _SavedReportsScreenState();
}

class _SavedReportsScreenState extends State<SavedReportsScreen> {
  // Store custom pages: id -> title
  Map<String, String> _customPages = {};

  // Palette for custom pages
  final List<Color> _customPalette = const [
    Color(0xFFEF4444), // Red
    Color(0xFF0891B2), // Cyan
    Color(0xFFDB2777), // Pink
    Color(0xFFEA580C), // Orange
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomPages();
  }

  Future<void> _loadCustomPages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPages = prefs.getString('custom_pages');
    if (savedPages != null) {
      final decoded = jsonDecode(savedPages) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _customPages = decoded.map((k, v) => MapEntry(k, v.toString()));
        });
      }
    }
  }

  Future<void> _saveCustomPages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_pages', jsonEncode(_customPages));
  }

  void _showAddNewPageDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController();
    final model = Provider.of<AccountingModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final hasText = controller.text.trim().isNotEmpty;

          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_circle_outline,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(model.t('dialog_new_page_title')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.t('dialog_new_page_msg'),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  onChanged: (value) {
                    setDialogState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: model.t('hint_new_page'),
                  ),
                ),
                if (!hasText)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      model.t('err_title_required'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(model.t('btn_cancel')),
              ),
              ElevatedButton(
                onPressed: hasText
                    ? () {
                        final pageName = controller.text.trim();
                        Navigator.pop(context);
                        _createCustomPage(pageName);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  disabledForegroundColor: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
                child: Text(model.t('btn_create')),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createCustomPage(String pageName) async {
    final pageId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _customPages[pageId] = pageName;
    });
    await _saveCustomPages();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AccountingModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(model.t('title_saved_reports')),
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Account Category',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View your saved balance sheets and history for each specific account type.',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                // 20% increased size: ~135.0
                const double cardSize = 135.0;

                // Prepare standard items
                final List<Widget> items = [];

                // 1. Personal
                items.add(_buildWrapper(
                  cardSize,
                  _buildCategoryCard(
                    context,
                    title: model.pageHeaderTitles['family'] ??
                        model.t('card_personal'),
                    icon: Icons.people_outline,
                    color: const Color(0xFF60A5FA),
                    bgColor: const Color(0xFFEFF6FF),
                    borderColor: const Color(0xFFBFDBFE),
                    isActive: model.userType == UserType.personal,
                    onTap: () => _navigateToReports(
                      context,
                      model.pageHeaderTitles['family'] ??
                          model.t('card_personal'),
                      'Personal',
                      const Color(0xFF60A5FA),
                    ),
                    isDark: isDark,
                  ),
                ));

                // 2. Business
                items.add(_buildWrapper(
                  cardSize,
                  _buildCategoryCard(
                    context,
                    title: model.pageHeaderTitles['business'] ??
                        model.t('card_business'),
                    icon: Icons.store_outlined,
                    color: const Color(0xFF10B981),
                    bgColor: const Color(0xFFECFDF5),
                    borderColor: const Color(0xFFA7F3D0),
                    isActive: model.userType == UserType.business,
                    onTap: () => _navigateToReports(
                      context,
                      model.pageHeaderTitles['business'] ??
                          model.t('card_business'),
                      'Business',
                      const Color(0xFF10B981),
                    ),
                    isDark: isDark,
                  ),
                ));

                // 3. Institute
                items.add(_buildWrapper(
                  cardSize,
                  _buildCategoryCard(
                    context,
                    title: model.pageHeaderTitles['institute'] ??
                        model.t('card_institute'),
                    icon: Icons.school_outlined,
                    color: const Color(0xFF8B5CF6),
                    bgColor: const Color(0xFFF5F3FF),
                    borderColor: const Color(0xFFDDD6FE),
                    isActive: model.userType == UserType.institute,
                    onTap: () => _navigateToReports(
                      context,
                      model.pageHeaderTitles['institute'] ??
                          model.t('card_institute'),
                      'Institute',
                      const Color(0xFF8B5CF6),
                    ),
                    isDark: isDark,
                  ),
                ));

                // 4. Other
                items.add(_buildWrapper(
                  cardSize,
                  _buildCategoryCard(
                    context,
                    title: model.pageHeaderTitles['other'] ??
                        model.t('card_other'),
                    icon: Icons.category_outlined,
                    color: const Color(0xFFF59E0B),
                    bgColor: const Color(0xFFFFFBEB),
                    borderColor: const Color(0xFFFDE68A),
                    isActive: model.userType == UserType.other,
                    onTap: () => _navigateToReports(
                      context,
                      model.pageHeaderTitles['other'] ?? model.t('card_other'),
                      'Other',
                      const Color(0xFFF59E0B),
                    ),
                    isDark: isDark,
                  ),
                ));

                // 5. Custom Pages
                int customIndex = 0;
                _customPages.forEach((id, defaultTitle) {
                  final color =
                      _customPalette[customIndex % _customPalette.length];
                  final displayTitle =
                      model.pageHeaderTitles[id] ?? defaultTitle;

                  items.add(_buildWrapper(
                    cardSize,
                    _buildCategoryCard(
                      context,
                      title: displayTitle,
                      icon: Icons.star_outline_rounded,
                      color: color,
                      bgColor: color.withOpacity(0.05),
                      borderColor: color.withOpacity(0.2),
                      isActive: false,
                      onTap: () => _navigateToReports(
                        context,
                        displayTitle,
                        id,
                        color,
                      ),
                      isDark: isDark,
                    ),
                  ));
                  customIndex++;
                });

                // 6. Add New Button
                items.add(_buildWrapper(
                  cardSize,
                  _buildAddNewCard(context, isDark, cardSize),
                ));

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: items,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWrapper(double size, Widget child) {
    return SizedBox(width: size, height: size, child: child);
  }

  void _navigateToReports(
      BuildContext context, String title, String useCase, Color color) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryReportsScreen(
          categoryName: title,
          useCaseType: useCase,
          categoryColor: color,
        ),
      ),
    );
  }

  Widget _buildAddNewCard(BuildContext context, bool isDark, double size) {
    return GestureDetector(
      onTap: () => _showAddNewPageDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              size: 38,
              color: isDark ? Colors.white54 : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Add New',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white54 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    // If dark mode, adjust colors to be darker
    final cardBg = isDark ? color.withOpacity(0.15) : bgColor;
    final cardBorder = isDark ? color.withOpacity(0.3) : borderColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : cardBorder,
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 38,
                    color: color,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
