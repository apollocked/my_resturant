import 'package:flutter_test/flutter_test.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/data/repositories/data_repository.dart';
import 'package:my_resturant/presentation/cubits/admin_auth_cubit.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(repo: AppRepository(), auth: AdminAuthCubit()));
    await tester.pump();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
