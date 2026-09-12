import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_maid_app/app.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartMaidApp()));
    await tester.pump();
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
