import 'package:get/get.dart';

import '../controllers/phone_credit_controller.dart';

class PhoneCreditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhoneCreditController>(
      () => PhoneCreditController(),
    );
  }
}
