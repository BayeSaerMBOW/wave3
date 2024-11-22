import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../../../../models/user_model.dart';

class CreateUserView extends StatelessWidget {
  final UserController controller = Get.put(UserController());

  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController cniController = TextEditingController();
  final TextEditingController dateNaissanceController = TextEditingController();
  final TextEditingController etatCompteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: prenomController,
                decoration: InputDecoration(labelText: 'Prénom'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: adresseController,
                decoration: InputDecoration(labelText: 'Adresse'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: telephoneController,
                decoration: InputDecoration(labelText: 'Téléphone'),
              ),
              TextField(
                controller: cniController,
                decoration: InputDecoration(labelText: 'CNI'),
              ),
              TextField(
                controller: dateNaissanceController,
                decoration: InputDecoration(labelText: 'Date de Naissance'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    dateNaissanceController.text = pickedDate.toIso8601String();
                  }
                },
              ),
              TextField(
                controller: etatCompteController,
                decoration: InputDecoration(labelText: 'État du Compte'),
              ),
              SizedBox(height: 20),
              Obx(() {
                return ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          final user = User(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            nom: nomController.text,
                            prenom: prenomController.text,
                            password: passwordController.text,
                            adresse: adresseController.text,
                            email: emailController.text,
                            telephone: telephoneController.text,
                            cni: cniController.text,
                            dateNaissance: DateTime.parse(dateNaissanceController.text),
                            etatCompte: etatCompteController.text,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          controller.createUser(user);
                        },
                  child: controller.isLoading.value
                      ? CircularProgressIndicator()
                      : Text('Create User'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}