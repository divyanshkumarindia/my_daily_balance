import 'package:flutter_test/flutter_test.dart';
import 'package:my_daily_balance_flutter/main.dart' as app;

void main() {
  testWidgets('basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const app.MyApp());
    // The index screen shows the app title (updated UI)
    expect(find.text('My Kaccha-Pakka Khata'), findsOneWidget);
  });
}
