import 'package:flutter_test/flutter_test.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/data/repositories/data_repository.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/data/repositories/auth_repository_impl.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      repo: AppRepository(),
      acct: AccountCubit(repo: LocalAuthRepository()),
      role: RoleCubit(),
    ));
    await tester.pump();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
