import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aakashvani/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AakashvaniApp()));
    await tester.pumpAndSettle();
    // The login screen should be visible on first launch
    expect(find.text('Aakashvani'), findsOneWidget);
  });
}
