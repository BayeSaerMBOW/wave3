import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  errorText: controller.errorMessage.value.isNotEmpty &&
                          controller.errorMessage.value.contains('email')
                      ? controller.errorMessage.value
                      : null,
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  errorText: controller.errorMessage.value.isNotEmpty &&
                          controller.errorMessage.value.contains('mot de passe')
                      ? controller.errorMessage.value
                      : null,
                ),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
              ),
              SizedBox(height: 24),
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.login(
                              emailController.text,
                              passwordController.text,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      'Se connecter avec Email',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }),
              SizedBox(height: 20),
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google2.png',
                          height: 24,
                          width: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Se connecter avec Google',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => Get.toNamed('/forgot-password'),
                child: Text(
                  'Mot de passe oublié ?',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vous n\'avez pas de compte ?',
                    style: TextStyle(fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/create-user'),
                    child: Text(
                      'S\'inscrire',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
