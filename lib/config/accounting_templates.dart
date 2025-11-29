class TemplateConfig {
  final String key;
  final String friendlyName;
  final String pageTitleDefault;
  final String incomeSectionTitle;
  final String expenseSectionTitle;
  final Map<String, String> defaultAccounts;
  final Map<String, String> labels;

  const TemplateConfig({
    required this.key,
    required this.friendlyName,
    required this.pageTitleDefault,
    required this.incomeSectionTitle,
    required this.expenseSectionTitle,
    this.defaultAccounts = const {},
    this.labels = const {},
  });
}

const Map<String, TemplateConfig> defaultTemplates = {
  'family': TemplateConfig(
    key: 'family',
    friendlyName: 'Family',
    pageTitleDefault: 'Family Accounting',
    incomeSectionTitle: 'Income',
    expenseSectionTitle: 'Expenses',
    labels: {
      'reportDuration': 'Report Duration',
      'selectPeriod': 'Select Period',
      'startDate': 'Start date',
      'endDate': 'End date',
      'viewReport': 'View Report',
    },
    defaultAccounts: {
      'salary': 'Salary / Wages',
      'business_income': 'Business Income',
      'groceries': 'Groceries',
      'utilities': 'Utilities',
    },
  ),
  'business': TemplateConfig(
    key: 'business',
    friendlyName: 'Business',
    pageTitleDefault: 'Business Accounting',
    incomeSectionTitle: 'Income',
    expenseSectionTitle: 'Expenses',
    labels: {
      'reportDuration': 'Report Duration',
      'selectPeriod': 'Select Period',
      'startDate': 'Start date',
      'endDate': 'End date',
      'viewReport': 'View Report',
    },
  ),
  'institute': TemplateConfig(
    key: 'institute',
    friendlyName: 'Institute',
    pageTitleDefault: 'Institute Accounting',
    incomeSectionTitle: 'Income',
    expenseSectionTitle: 'Expenses',
    labels: {
      'reportDuration': 'Report Duration',
      'selectPeriod': 'Select Period',
      'startDate': 'Start date',
      'endDate': 'End date',
      'viewReport': 'View Report',
    },
  ),
  'other': TemplateConfig(
    key: 'other',
    friendlyName: 'Other',
    pageTitleDefault: 'Accounting',
    incomeSectionTitle: 'Income',
    expenseSectionTitle: 'Expenses',
    labels: {
      'reportDuration': 'Report Duration',
      'selectPeriod': 'Select Period',
      'startDate': 'Start date',
      'endDate': 'End date',
      'viewReport': 'View Report',
    },
  ),
};
