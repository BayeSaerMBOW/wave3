import 'package:get/get.dart';

import '../controllers/lectricite_controller.dart';

class LectriciteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LectriciteController>(
      () => LectriciteController(),
    );
  }
}
