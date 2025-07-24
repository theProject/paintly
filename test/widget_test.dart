import 'package:flutter_test/flutter_test.dart';
import 'package:painted/main.dart';

void main() {
  testWidgets('Paint by number app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that we can find the app name or initial UI elements
    expect(find.text('New'), findsOneWidget);
  });
}