import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/accounting_model.dart';
import '../models/accounting.dart';
import '../widgets/accounting_form.dart';

/// Template route that renders the shared `AccountingForm` widget.
/// Each template key (family, business, institute, other) is passed through
/// so `AccountingForm` can adapt labels/defaults if necessary.
class AccountingTemplateScreen extends StatelessWidget {
  final String templateKey;
  final String? customTitle;
  final String? customPageId;
  final Map<String, dynamic>? initialState; // For editing existing reports
  final String? reportId; // For updating existing report

  const AccountingTemplateScreen({
    Key? key,
    required this.templateKey,
    this.customTitle,
    this.customPageId,
    this.initialState,
    this.reportId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap in a ChangeNotifierProvider to ensure a specific, fresh model instance
    // is available for this form, especially important when editing an existing report
    // so that the imported state doesn't conflict with any global state.
    // We initialize with a default UserType; importState will overwrite it if initialState is present.
    return ChangeNotifierProvider<AccountingModel>(
      create: (_) => AccountingModel(
        userType: UserType.personal,
        shouldLoadFromStorage: false,
      ),
      child: AccountingForm(
        templateKey: templateKey,
        customTitle: customTitle,
        customPageId: customPageId,
        initialState: initialState,
        reportId: reportId,
      ),
    );
  }
}
