import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vittalo/main.dart';

void main() {
  testWidgets('VittaloApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VittaloApp()));
    expect(find.byType(VittaloApp), findsOneWidget);
  });
}
