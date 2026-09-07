import 'package:flutter/foundation.dart';
import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/data/repositories/auth_repo_base.dart';
import 'package:my_resturant/domain/entities/role.dart';

mixin AuthRpcMixin on SupabaseAuthRepositoryBase {
  @override
  Future<bool> arePasscodesConfigured() async {
    try {
      return await safeCall(() => client.rpc('passcodes_configured')) == true;
    } catch (e, st) {
      debugPrint('SupabaseAuthRepo.arePasscodesConfigured error: $e\n$st');
      return false;
    }
  }

  @override
  Future<void> savePasscodes(
    String waiterPin,
    String kitchenPin,
    String adminPin,
  ) => safeCallNoRetry(() => client.rpc(
        'save_passcodes',
        params: {
          'p_waiter': waiterPin,
          'p_kitchen': kitchenPin,
          'p_admin': adminPin,
        },
      ));

  @override
  Future<bool> verifyPasscode(Role role, String pin) async {
    try {
      return await safeCall(
            () => client.rpc(
              'verify_pin',
              params: {'p_role': role.name, 'p_pin': pin},
            ),
          ) ==
          true;
    } catch (e, st) {
      debugPrint('SupabaseAuthRepo.verifyPasscode error: $e\n$st');
      return false;
    }
  }

  @override
  Future<void> changePasscode(Role role, String newPin) => safeCallNoRetry(
      () => client.rpc(
        'change_passcode',
        params: {'p_role': role.name, 'p_pin': newPin},
      ));

  @override
  Future<void> saveLoggedInRole(Role? role, {String? pin}) => safeCallNoRetry(
      () => client.rpc('set_role', params: {'p_role': role?.name, 'p_pin': pin}));

  @override
  Future<bool> claimPromoCode(String code) async {
    try {
      final result = await safeCallNoRetry(
        () => client.rpc(
          'claim_promo_code',
          params: {'promo_code': code.trim().toUpperCase()},
        ),
      );
      return result == true;
    } catch (e, st) {
      debugPrint('SupabaseAuthRepo.claimPromoCode error: $e\n$st');
      return false;
    }
  }
}
