import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/main.dart';

void main() {
  testWidgets('GK Quiz app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GKQuizApp());
    // App starts without crashing
    expect(find.byType(GKQuizApp), findsOneWidget);
  });
}
