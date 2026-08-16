import 'package:my_resturant/data/repositories/category_data_repo_mixin.dart';
import 'package:my_resturant/data/repositories/order_data_repo_mixin.dart';
import 'package:my_resturant/data/repositories/recipe_data_repo_mixin.dart';
import 'package:my_resturant/data/repositories/setting_data_repo_mixin.dart';
import 'package:my_resturant/data/repositories/supabase_repo_base.dart';
import 'package:my_resturant/domain/repositories/data_repository.dart';

class SupabaseDataRepository extends SupabaseDataRepoBase
    with RecipeDataRepoMixin, OrderDataRepoMixin, SettingDataRepoMixin, CategoryDataRepoMixin
    implements DataRepository {}
