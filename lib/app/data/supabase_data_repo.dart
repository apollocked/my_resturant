import 'package:my_resturant/features/menu/data/repositories/category_data_repo_mixin.dart';
import 'package:my_resturant/features/orders/data/repositories/order_data_repo_mixin.dart';
import 'package:my_resturant/features/menu/data/repositories/recipe_data_repo_mixin.dart';
import 'package:my_resturant/features/settings/data/repositories/setting_data_repo_mixin.dart';
import 'package:my_resturant/app/data/supabase_repo_base.dart';
import 'package:my_resturant/app/domain/data_repository.dart';

class SupabaseDataRepository extends SupabaseDataRepoBase
    with
        RecipeDataRepoMixin,
        OrderDataRepoMixin,
        SettingDataRepoMixin,
        CategoryDataRepoMixin
    implements DataRepository {}
