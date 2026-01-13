class TransactionRow {
  String id;
  double cash;
  double bank;
  String particulars;

  TransactionRow(
      {required this.id, this.cash = 0, this.bank = 0, this.particulars = ''});

  Map<String, dynamic> toJson() => {
        'id': id,
        'cash': cash,
        'bank': bank,
        'particulars': particulars,
      };

  factory TransactionRow.fromJson(Map<String, dynamic> json) {
    return TransactionRow(
      id: json['id'],
      cash: (json['cash'] as num?)?.toDouble() ?? 0.0,
      bank: (json['bank'] as num?)?.toDouble() ?? 0.0,
      particulars: json['particulars'] ?? '',
    );
  }
}

class TransactionEntry {
  String id;
  String description;
  List<TransactionRow> rows;

  TransactionEntry(
      {required this.id, this.description = '', List<TransactionRow>? rows})
      : rows = rows ?? [TransactionRow(id: '${id}_row_1')];

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'rows': rows.map((e) => e.toJson()).toList(),
      };

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    return TransactionEntry(
      id: json['id'],
      description: json['description'] ?? '',
      rows: (json['rows'] as List?)
          ?.map((e) => TransactionRow.fromJson(e))
          .toList(),
    );
  }
}

enum DurationType { Daily, Weekly, Monthly, Yearly }

enum UserType { personal, business, institute, other }

class AccountConfig {
  final String name;
  final String firmNamePlaceholder;
  final String receiptsLabel;
  final String paymentsLabel;
  final Map<String, String> receiptAccounts;
  final Map<String, String> paymentAccounts;

  AccountConfig({
    required this.name,
    required this.firmNamePlaceholder,
    required this.receiptsLabel,
    required this.paymentsLabel,
    required this.receiptAccounts,
    required this.paymentAccounts,
  });
}

final Map<UserType, AccountConfig> userTypeConfigs = {
  UserType.personal: AccountConfig(
    name: 'Personal / Family Use',
    firmNamePlaceholder: 'My Family / Personal',
    receiptsLabel: 'Income',
    paymentsLabel: 'Expenses',
    receiptAccounts: {
      'salary': 'Salary / Wages',
      'business_income': 'Business Income',
      'rental_income': 'Rental Income',
      'investment_returns': 'Investment Returns / Interest',
      'gifts_received': 'Gifts Received',
      'other_income': 'Other Income',
    },
    paymentAccounts: {
      'groceries': 'Groceries / Food',
      'rent_payment': 'Rent / EMI Payment',
      'education': 'Education Expenses',
      'transport': 'Transport / Fuel',
      'shopping': 'Shopping / Personal',
      'other_expenses': 'Other Expenses',
    },
  ),
  UserType.business: AccountConfig(
    name: 'Business / Professional Use',
    firmNamePlaceholder: 'My Business / Company',
    receiptsLabel: 'Sales (Receipts)',
    paymentsLabel: 'Purchases (Payments)',
    receiptAccounts: {
      'sales': 'Sales Revenue',
      'service_income': 'Service Income',
      'interest_received': 'Interest Received',
      'commission_received': 'Commission Received',
      'loan_received': 'Loans Received',
      'investment': 'Investment Received',
      'other_income': 'Other Income',
    },
    paymentAccounts: {
      'purchases': 'Raw Material / Goods Purchase',
      'salaries': 'Salaries / Wages',
      'rent_commercial': 'Rent / Lease',
      'utilities_business': 'Utilities (Power / Water / Internet)',
      'loan_repayment': 'Loan Repayment / Interest',
      'maintenance': 'Maintenance / Repairs',
      'other_expenses': 'Other Business Expenses',
    },
  ),
  UserType.institute: AccountConfig(
    name: 'Institute / Organization Use',
    firmNamePlaceholder: 'My School / College / Organization',
    receiptsLabel: 'Receipts',
    paymentsLabel: 'Payments',
    receiptAccounts: {
      'fees_collected': 'Fees Collected (Tuition / Admission)',
      'exam_fees': 'Exam Fees',
      'donations': 'Donations Received',
      'grants': 'Grants / Subsidies',
      'event_income': 'Event Income',
      'rental_income_inst': 'Rental Income (Facilities)',
      'other_income_inst': 'Other Income',
    },
    paymentAccounts: {
      'staff_salaries': 'Staff Salaries (Teaching)',
      'non_teaching_salaries': 'Non-Teaching Staff Salaries',
      'utilities_inst': 'Utilities (Electricity / Water / Internet)',
      'library_supplies': 'Library / Books / Supplies',
      'maintenance_inst': 'Building Maintenance',
      'statutory_payments': 'Statutory Payments (PF / ESI)',
      'other_expenses_inst': 'Other Expenses',
    },
  ),
  UserType.other: AccountConfig(
    name: 'Other',
    firmNamePlaceholder: 'My Firm / Organization',
    receiptsLabel: 'Receipts',
    paymentsLabel: 'Payments',
    receiptAccounts: {
      'income_1': 'Income Source 1',
      'income_2': 'Income Source 2',
      'income_3': 'Income Source 3',
      'income_4': 'Income Source 4',
      'income_5': 'Other Income',
    },
    paymentAccounts: {
      'expense_1': 'Expense Category 1',
      'expense_2': 'Expense Category 2',
      'expense_3': 'Expense Category 3',
      'expense_4': 'Expense Category 4',
      'expense_5': 'Other Expenses',
    },
  ),
};

/// Short titles for page headers per use case.
String useCasePageTitle(UserType type) {
  switch (type) {
    case UserType.personal:
      return 'Personal / Family Use';
    case UserType.business:
      return 'Business / Professional Use';
    case UserType.institute:
      return 'Institute / Organization Use';
    case UserType.other:
      return 'Other Use';
  }
}
