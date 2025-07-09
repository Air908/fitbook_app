import 'package:get/get.dart';
import '../../features/admin/bloc/admin_controller.dart';
import '../../features/auth/bloc/AuthController.dart';
import '../../features/facilities/bloc/facility_controller.dart';
import '../../features/home/bloc/home_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(FacilityController());
    Get.put(HomeController());
    Get.put(AdminController());
  }
}
