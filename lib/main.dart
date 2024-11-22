import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Vérifier la connexion persistante
  User? initialUser = FirebaseAuth.instance.currentUser;

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: initialUser != null ? AppPages.HOME : AppPages.LOGIN,
      getPages: AppPages.routes,
    ),
  );
}