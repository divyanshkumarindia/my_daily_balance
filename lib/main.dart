import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens/index_screen.dart';
import 'screens/accounting_screen.dart';
import 'screens/family_accounting_screen.dart';
import 'screens/business_accounting_screen.dart';
import 'screens/institute_accounting_screen.dart';
import 'screens/others_accounting_screen.dart';
import 'state/accounting_model.dart';
import 'models/accounting.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We provide a default AccountingModel for safe access; IndexScreen will push a configured model
    return ChangeNotifierProvider<AccountingModel>(
      create: (_) => AccountingModel(userType: UserType.personal),
      child: MaterialApp(
        title: 'My Daily Balance',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const IndexScreen(),
          '/accounting': (context) => const AccountingScreen(),
          // Separate routes per use case
          '/accounting/family': (context) => const FamilyAccountingScreen(),
          '/accounting/business': (context) => const BusinessAccountingScreen(),
          '/accounting/institute': (context) =>
              const InstituteAccountingScreen(),
          '/accounting/other': (context) => const OthersAccountingScreen(),
        },
      ),
    );
  }
}
