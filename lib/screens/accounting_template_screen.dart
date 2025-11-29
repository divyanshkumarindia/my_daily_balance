import 'package:flutter/material.dart';
import 'family_accounting_screen.dart';

/// Thin wrapper that re-uses the existing FamilyAccountingScreen implementation
/// so the new template route renders exactly the same UI. This keeps a single
/// authoritative implementation while allowing routes to point to a template
/// keyed screen. If you prefer a full copy of the file (duplicate source),
/// I can paste the entire family file into this file instead.
class AccountingTemplateScreen extends StatelessWidget {
	final String templateKey;
	const AccountingTemplateScreen({Key? key, required this.templateKey}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		// For now, delegate to FamilyAccountingScreen to guarantee identical UI.
		return const FamilyAccountingScreen();
	}
}
