import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  @override
  void onInit() {
    super.onInit();
    // Déboguer la configuration de Firebase
    print('Application Firebase : ${Firebase.apps}');
    print('Utilisateur actuel : ${_auth.currentUser}');
  }
Future<void> login(String email, String password) async {
  errorMessage.value = '';
  if (email.isEmpty || password.isEmpty) {
    errorMessage.value = 'Email et mot de passe requis';
    return;
  }
  if (!GetUtils.isEmail(email)) {
    errorMessage.value = 'Veuillez entrer une adresse email valide';
    return;
  }
  isLoading(true);

  try {
    // Tentative de connexion
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Vérifier le rôle de l'utilisateur
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    final userRole = userDoc.data()?['role'] as String?;

    // Rediriger en fonction du rôle
    if (userRole == 'distributeur') {
      Get.offNamed('/distributor-home');
    } else {
      Get.offNamed('/home');
    }

    // Message de succès
    Get.snackbar(
      'Succès',
      'Connexion réussie',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
    );
  } on FirebaseAuthException catch (e) {
    print('FirebaseAuthException: ${e.code} - ${e.message}');
    errorMessage.value = getErrorMessage(e.code);
    Get.snackbar(
      'Erreur',
      errorMessage.value,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
    );
  } catch (e) {
    print('Erreur inattendue lors de la connexion : $e');
    errorMessage.value = 'Une erreur inattendue est survenue';
    Get.snackbar(
      'Erreur',
      errorMessage.value,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
    );
  } finally {
    isLoading(false);
  }
}
 Future<void> signInWithGoogle() async {
    try {
      isLoading(true);

      // Déclencher le flux de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading(false);
        return; // L'utilisateur a annulé la connexion
      }

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Créer un nouvel identifiant
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connexion à Firebase avec l'identifiant Google
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      // Vérifier si c'est un nouvel utilisateur
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Créer un nouveau document utilisateur dans Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
          'role': 'user', // rôle par défaut
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': userCredential.user!.photoURL,
        });
      }

      // Vérifier le rôle de l'utilisateur
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      final userRole = userDoc.data()?['role'] as String?;

      // Rediriger en fonction du rôle
      if (userRole == 'distributeur') {
        Get.offNamed('/distributor-home');
      } else {
        Get.offNamed('/home');
      }

      Get.snackbar(
        'Succès',
        'Connexion avec Google réussie',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      errorMessage.value = getErrorMessage(e.code);
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      print('Erreur lors de la connexion Google : $e');
      errorMessage.value = 'Une erreur est survenue lors de la connexion Google';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading(false);
    }
  }


  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offNamed('/login');
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de la déconnexion',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  String getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Adresse email invalide';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'user-not-found':
        return 'Utilisateur non trouvé';
      case 'user-disabled':
        return 'Utilisateur désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives de connexion. Veuillez réessayer plus tard.';
      case 'operation-not-allowed':
        return 'Opération non autorisée';
      case 'email-already-in-use':
        return 'Adresse email déjà utilisée';
      case 'invalid-credential':
        return 'Les informations d\'identification fournies sont incorrectes, mal formées ou expirées.';
      default:
        return 'Erreur inconnue';
    }
  }
}