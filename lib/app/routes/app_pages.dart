import 'package:get/get.dart';

import '../../app/modules/home/views/home_view.dart';
import '../../app/modules/login/views/login_view.dart';
import '../../app/modules/user/views/user_view.dart';
import '../modules/balance/bindings/balance_binding.dart';
import '../modules/balance/views/balance_view.dart';
import '../modules/phone_credit/bindings/phone_credit_binding.dart';
import '../modules/phone_credit/views/phone_credit_view.dart';
import '../modules/scan/bindings/scan_binding.dart';
import '../modules/scan/views/scan_view.dart';
import '../modules/transaction/bindings/transaction_binding.dart';
import '../modules/transaction/views/transaction_view.dart';

// lib/app/routes/app_pages.dart

import '../../app/modules/distributor/views/distributor_view.dart'; // Ajoutez l'importation pour la nouvelle page

class AppPages {
  static const INITIAL = '/';
  static const CREATE_USER = '/create-user';
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const DISTRIBUTOR_HOME =
      '/distributor-home'; // Ajoutez la nouvelle route

  static final routes = [
    GetPage(name: INITIAL, page: () => LoginView()),
    GetPage(name: CREATE_USER, page: () => CreateUserView()),
    GetPage(name: LOGIN, page: () => LoginView()),
    GetPage(name: HOME, page: () => HomeView()),
    GetPage(
        name: DISTRIBUTOR_HOME,
        page: () => DistributorHomeView()), // Ajoutez la nouvelle route
  
  ];
}
