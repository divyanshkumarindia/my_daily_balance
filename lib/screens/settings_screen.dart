import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/accounting_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final model = Provider.of<AccountingModel>(context);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Settings Section
          _buildSectionHeader('Account Settings', Icons.person, isDark),
          _buildSettingsCard(
            isDark,
            [
              _buildSettingTile(
                context,
                'Default Page Type',
                model.defaultPageType ?? 'Personal',
                Icons.category,
                () => _showPageTypeDialog(context, model),
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Appearance Section
          _buildSectionHeader('Appearance', Icons.palette, isDark),
          _buildSettingsCard(
            isDark,
            [
              _buildSettingTile(
                context,
                'Theme Mode',
                _getThemeModeLabel(model.themeMode),
                Icons.brightness_6,
                () => _showThemeModeDialog(context, model),
                isDark,
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                context,
                'Theme Color',
                _getThemeColorLabel(model.themeColor),
                Icons.color_lens,
                () => _showThemeColorDialog(context, model),
                isDark,
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                context,
                'Font Size',
                'Adjust text size',
                Icons.text_fields,
                () => _showComingSoonSnackBar(context),
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Data Management', Icons.storage, isDark),
          _buildSettingsCard(
            isDark,
            [
              _buildSettingTile(
                context,
                'Backup Data',
                'Save your data to file',
                Icons.backup,
                () => _showBackupDialog(context, model),
                isDark,
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                context,
                'Restore Data',
                'Load data from backup',
                Icons.restore,
                () => _showRestoreDialog(context, model),
                isDark,
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                context,
                'Export All Data',
                'Export to Excel/PDF',
                Icons.file_download,
                () => _showComingSoonSnackBar(context),
                isDark,
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                context,
                'Clear All Data',
                'Delete all saved data',
                Icons.delete_forever,
                () => _showClearDataDialog(context, model),
                isDark,
                textColor: const Color(0xFFDC2626),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Report Settings Section
          _buildSectionHeader('Report Settings', Icons.article, isDark),
          _buildSettingsCard(
            isDark,
            [
              _buildSwitchTile(
                'Auto-Save Reports',
                'Automatically save generated reports',
                Icons.save,
                model.autoSaveReports,
                (value) => model.toggleAutoSaveReports(),
                isDark,
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                context,
                'Default Report Format',
                model.defaultReportFormat ?? 'Basic',
                Icons.format_list_bulleted,
                () => _showReportFormatDialog(context, model),
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // About Section
          _buildSectionHeader('About', Icons.info, isDark),
          _buildSettingsCard(
            isDark,
            [
              _buildInfoTile(
                'App Version',
                '1.0.0',
                Icons.app_settings_alt,
                isDark,
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                context,
                'Developer',
                'Divyansh Kumar',
                Icons.code,
                () => _showDeveloperInfo(context),
                isDark,
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                context,
                'Privacy Policy',
                'View our privacy policy',
                Icons.privacy_tip,
                () => _showComingSoonSnackBar(context),
                isDark,
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                context,
                'Terms of Service',
                'View terms and conditions',
                Icons.description,
                () => _showComingSoonSnackBar(context),
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? const Color(0xFF10B981)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: textColor ?? const Color(0xFF10B981),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor ?? (isDark ? Colors.white : const Color(0xFF111827)),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDark,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF10B981),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF111827),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF10B981),
      ),
    );
  }

  Widget _buildInfoTile(
      String title, String value, IconData icon, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF10B981),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF111827),
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
    );
  }

  // Dialog Functions
  void _showPageTypeDialog(BuildContext context, AccountingModel model) {
    final pageTypes = ['Personal', 'Business', 'Institute', 'Other'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Default Page Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: pageTypes.map((type) {
            return RadioListTile<String>(
              title: Text(type),
              value: type,
              groupValue: model.defaultPageType,
              activeColor: const Color(0xFF10B981),
              onChanged: (value) {
                model.setDefaultPageType(value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showReportFormatDialog(BuildContext context, AccountingModel model) {
    final formats = ['Basic', 'Detailed'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Default Report Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: formats.map((format) {
            return RadioListTile<String>(
              title: Text(format),
              value: format,
              groupValue: model.defaultReportFormat,
              activeColor: const Color(0xFF10B981),
              onChanged: (value) {
                model.setDefaultReportFormat(value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBackupDialog(BuildContext context, AccountingModel model) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Backup Data'),
        content: const Text(
          'This will save all your accounting data to a file. You can restore this backup later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              model.backupData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data backed up successfully!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, AccountingModel model) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restore Data'),
        content: const Text(
          'This will replace all current data with the backup. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              model.restoreData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data restored successfully!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, AccountingModel model) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your accounting data including pages, categories, and saved reports. This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              model.clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared successfully'),
                  backgroundColor: Color(0xFFDC2626),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.code, color: Color(0xFF10B981)),
            SizedBox(width: 12),
            Text('Developer Info'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Daily Balance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Developed by:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Divyansh Kumar'),
            const SizedBox(height: 4),
            Text(
              'A comprehensive accounting solution for daily balance management',
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        backgroundColor: Color(0xFF6366F1),
      ),
    );
  }

  // Helper methods for theme labels
  String _getThemeModeLabel(String themeMode) {
    switch (themeMode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System Default';
      default:
        return 'System Default';
    }
  }

  String _getThemeColorLabel(String themeColor) {
    switch (themeColor) {
      case 'blue':
        return 'Blue';
      case 'green':
        return 'Green';
      case 'purple':
        return 'Purple';
      case 'orange':
        return 'Orange';
      case 'red':
        return 'Red';
      case 'teal':
        return 'Teal';
      default:
        return 'Blue';
    }
  }

  // Theme Mode Dialog
  void _showThemeModeDialog(BuildContext context, AccountingModel model) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.brightness_6, color: Color(0xFF6366F1)),
            SizedBox(width: 12),
            Text('Theme Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Row(
                children: [
                  Icon(Icons.light_mode, size: 20),
                  SizedBox(width: 12),
                  Text('Light'),
                ],
              ),
              value: 'light',
              groupValue: model.themeMode,
              activeColor: const Color(0xFF6366F1),
              onChanged: (value) {
                model.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Row(
                children: [
                  Icon(Icons.dark_mode, size: 20),
                  SizedBox(width: 12),
                  Text('Dark'),
                ],
              ),
              value: 'dark',
              groupValue: model.themeMode,
              activeColor: const Color(0xFF6366F1),
              onChanged: (value) {
                model.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Row(
                children: [
                  Icon(Icons.settings_brightness, size: 20),
                  SizedBox(width: 12),
                  Text('System Default'),
                ],
              ),
              value: 'system',
              groupValue: model.themeMode,
              activeColor: const Color(0xFF6366F1),
              onChanged: (value) {
                model.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Theme Color Dialog
  void _showThemeColorDialog(BuildContext context, AccountingModel model) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = [
      {'name': 'Blue', 'value': 'blue', 'color': const Color(0xFF6366F1)},
      {'name': 'Green', 'value': 'green', 'color': const Color(0xFF10B981)},
      {'name': 'Purple', 'value': 'purple', 'color': const Color(0xFF8B5CF6)},
      {'name': 'Orange', 'value': 'orange', 'color': const Color(0xFFF97316)},
      {'name': 'Red', 'value': 'red', 'color': const Color(0xFFEF4444)},
      {'name': 'Teal', 'value': 'teal', 'color': const Color(0xFF14B8A6)},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.color_lens, color: Color(0xFF6366F1)),
            SizedBox(width: 12),
            Text('Theme Color'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: colors.map((colorData) {
            final isSelected = model.themeColor == colorData['value'];
            return ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorData['color'] as Color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? (colorData['color'] as Color)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
              title: Text(colorData['name'] as String),
              onTap: () {
                model.setThemeColor(colorData['value'] as String);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
