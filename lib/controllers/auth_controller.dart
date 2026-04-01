import 'package:get/get.dart';
import '../../utils/appwrite_service.dart';
import '../../models/user.dart';

class AuthController extends GetxController {
  var user = Rxn<AppUser>();
  var loading = false.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final currentUser = await AppwriteService.getCurrentUser();
      if (currentUser != null) {
        user.value = AppUser(
          uid: currentUser.$id,
          email: currentUser.email ?? '',
          name: currentUser.name ?? '',
        );
      }
    } catch (e) {}
  }

  Future<bool> signIn(String email, String password) async {
    loading.value = true;
    error.value = '';
    try {
      await AppwriteService.createEmailPasswordSession(email, password);
      await checkAuthStatus();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    loading.value = true;
    error.value = '';
    try {
      await AppwriteService.createAccount(email, password, name);
      await AppwriteService.createEmailPasswordSession(email, password);
      await checkAuthStatus();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> signOut() async {
    await AppwriteService.deleteCurrentSession();
    user.value = null;
  }

  bool get isLoggedIn => user.value != null;
}
