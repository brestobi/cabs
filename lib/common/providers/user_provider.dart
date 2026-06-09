import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../../auth/providers/auth_provider.dart';

final userServicePrivider = Provider((ref) => UserService());

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  final userService = ref.read(userServicePrivider);
  return UserNotifier(userService, authState);
});

class UserNotifier extends StateNotifier<UserModel?> {
  final UserService _userService;
  final AuthState _authState;

  UserNotifier(this._userService, this._authState) : super(null) {
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    if (_authState.user != null) {
      final user = await _userService.getUserProfile(_authState.user!.id);
      state = user;
    } else {
      state = null;
    }
  }

  Future<void> setRole(String role) async {
    if (state != null) {
      await _userService.updateUserRole(state!.id, role);
      state = await _userService.getUserProfile(state!.id);
    }
  }

  Future<void> updateDriverVerification({
    required String licenseNumber,
    required String licensePhotoUrl,
    required String selfiePhotoUrl,
  }) async {
    if (state != null) {
      final updatedUser = state!.copyWith(
        licenseNumber: licenseNumber,
        licensePhotoUrl: licensePhotoUrl,
        selfiePhotoUrl: selfiePhotoUrl,
      );
      await _userService.createUserProfile(updatedUser);
      state = updatedUser;
    }
  }
}
