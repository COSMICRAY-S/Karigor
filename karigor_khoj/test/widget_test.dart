import 'package:flutter_test/flutter_test.dart';
import 'package:karigor_khoj/main.dart';

void main() {
  testWidgets('KarigorKhojApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KarigorKhojApp());

    // Verify that the splash or initial screen renders without error
    expect(find.byType(KarigorKhojApp), findsOneWidget);
  });
}
