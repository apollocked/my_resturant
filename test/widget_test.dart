import 'package:flutter_test/flutter_test.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/database/repository.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(repo: AppRepository()));
    await tester.pump();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
