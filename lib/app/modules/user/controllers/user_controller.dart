import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../../../models/user_model.dart';
import 'package:flutter/material.dart';

class UserController extends GetxController {
  var isLoading = false.obs;
  var userList = <User>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  Future<void> createUser(User user) async {
    isLoading(true);
    try {
      // 1. Créer l'utilisateur dans Firebase Authentication
      final authResult = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      // 2. Mettre à jour le profil de l'utilisateur dans Firebase Auth
      await authResult.user?.updateDisplayName('${user.prenom} ${user.nom}');

      // 3. Créer l'utilisateur dans Firestore avec l'UID de Firebase Auth
      final userWithAuthId = user.copyWith(
        id: authResult.user!.uid,
        updatedAt: DateTime.now(),
      );

      // 4. Sauvegarder les données dans Firestore (sans le mot de passe)
      final userDataForFirestore = userWithAuthId.toJson();
      userDataForFirestore.remove('password'); // Ne pas stocker le mot de passe dans Firestore

      await _firestore
          .collection('users')
          .doc(authResult.user!.uid)
          .set(userDataForFirestore);

      // 5. Créer automatiquement la balance pour l'utilisateur
      await _firestore
          .collection('balances')
          .doc(authResult.user!.uid)
          .set({
        'userId': authResult.user!.uid,
        'solde': 0.0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // 6. Mettre à jour la liste locale
      userList.add(userWithAuthId);

      isLoading(false);
      Get.snackbar(
        'Succès',
        'Utilisateur créé avec succès',
        snackPosition: SnackPosition.TOP,
      );

      // 7. Rediriger vers la page suivante ou effacer le formulaire
      Get.back(); // ou toute autre navigation souhaitée

    } on auth.FirebaseAuthException catch (e) {
      isLoading(false);
      String errorMessage;

      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Le mot de passe doit contenir au moins 6 caractères';
          break;
        case 'email-already-in-use':
          errorMessage = 'Un compte existe déjà avec cet email';
          break;
        case 'invalid-email':
          errorMessage = 'L\'adresse email n\'est pas valide';
          break;
        default:
          errorMessage = 'Une erreur est survenue: ${e.message}';
      }

      Get.snackbar(
        'Erreur',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading(false);
      Get.snackbar(
        'Erreur',
        'Une erreur inattendue est survenue',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}