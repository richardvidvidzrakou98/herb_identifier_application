import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../pages/LoginPage.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> register(String fullName, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
        });

        Get.offAll(() => LoginScreen());
      } else {
        Get.snackbar('Error', 'User registration failed. User is null.', snackPosition: SnackPosition.BOTTOM);
        print("User is null after registration.");
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'The email is already in use by another account.';
          break;
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = 'An unknown error occurred.';
      }
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
      print("FirebaseAuthException: $message");
    } catch (e) {
      Get.snackbar('Error', 'Registration failed. Please try again.', snackPosition: SnackPosition.BOTTOM);
      print("Exception during registration: $e");
    }
  }
}
