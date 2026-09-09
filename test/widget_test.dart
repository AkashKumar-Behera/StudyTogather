import 'package:flutter_test/flutter_test.dart';
import 'package:studytogether/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Verifies app widget instantiates
    expect(const StudyTogetherApp(), isNotNull);
  });
}
