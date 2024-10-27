import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../user_auth/controllers/signup_controller.dart';
import 'LoginPage.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscureText = true;
  bool _passwordValid = true; // Track password validation state
  String? _errorMessage; // Store error message for display
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final SignupController controller = Get.put(SignupController());

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _register() async {
    if (_validateInputs()) {
      try {
        // Create user with email and password
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Add user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
        });

        // Navigate to the login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'email-already-in-use') {
            _errorMessage = 'Email already exists.';
          } else {
            _errorMessage = 'An error occurred. Please try again.';
          }
        });
      }
    }
  }

  bool _validateInputs() {
    bool isValid = true;

    // Clear previous error message
    setState(() {
      _errorMessage = null;
    });

    // Validate full name
    if (_fullNameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Full Name cannot be empty.';
      });
      isValid = false;
    }

    // Validate email
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Email cannot be empty.';
      });
      isValid = false;
    } else {
      // Use a refined regex pattern to validate the email format
      String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
      RegExp regex = RegExp(emailPattern);
      if (!regex.hasMatch(_emailController.text.trim())) {
        setState(() {
          _errorMessage = 'Please enter a valid email address.';
        });
        isValid = false;
      }
    }

    // Validate password length
    if (_passwordController.text.trim().length < 6) {
      setState(() {
        _passwordValid = false;
        _errorMessage = 'Password must be at least 6 characters.';
      });
      isValid = false;
    } else {
      setState(() {
        _passwordValid = true;
      });
    }

    return isValid;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Register text
              SizedBox(height: 100),
              Text(
                'Register',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: Color(0xFF18492F), // Hexadecimal color
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 60),
              // Create a new account text
              Text(
                'Create a new account',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: Color(0xFF18492F),
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Full Name TextField
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Color(0xFF18492F)),
                  hintText: 'Full Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Color(0xFF18492F)),
                  hintText: 'user@gmail.com',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Password TextField
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF18492F)),
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              SizedBox(height: 50),
              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF18492F), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Link to login screen
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(color: Color(0xFF18492F)),
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
