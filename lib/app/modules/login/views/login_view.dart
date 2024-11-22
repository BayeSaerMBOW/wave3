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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFF8E24AA),
              Color(0xFFAB47BC)
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Connexion',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                        SizedBox(height: 30),
                        _buildEmailTextField(),
                        SizedBox(height: 20),
                        _buildPasswordTextField(),
                        SizedBox(height: 30),
                        _buildLoginButton(),
                        SizedBox(height: 20),
                        _buildGoogleLoginButton(),
                        SizedBox(height: 20),
                        _buildForgotPasswordButton(),
                        SizedBox(height: 20),
                        _buildSignUpRow(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return Obx(() => TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email, color: Color(0xFF6A1B9A)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFF6A1B9A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFF6A1B9A), width: 2),
            ),
            errorText: controller.errorMessage.value.isNotEmpty &&
                    controller.errorMessage.value.contains('email')
                ? controller.errorMessage.value
                : null,
          ),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enableSuggestions: false,
        ));
  }

  Widget _buildPasswordTextField() {
    return Obx(() => TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            prefixIcon: Icon(Icons.lock, color: Color(0xFF6A1B9A)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFF6A1B9A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFF6A1B9A), width: 2),
            ),
            errorText: controller.errorMessage.value.isNotEmpty &&
                    controller.errorMessage.value.contains('mot de passe')
                ? controller.errorMessage.value
                : null,
          ),
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
        ));
  }

  Widget _buildLoginButton() {
    return Obx(() => SizedBox(
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
              backgroundColor: Color(0xFF6A1B9A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: controller.isLoading.value
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Se connecter avec Email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ));
  }

  Widget _buildGoogleLoginButton() {
    return Obx(() => SizedBox(
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
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              elevation: 3,
              padding: EdgeInsets.symmetric(vertical: 12),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () => Get.toNamed('/forgot-password'),
      child: Text(
        'Mot de passe oublié ?',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF6A1B9A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSignUpRow() {
    return Row(
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
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}