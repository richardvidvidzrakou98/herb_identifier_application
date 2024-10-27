import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'HomePage.dart';
import 'RegisterScreen.dart';
//import '../services/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  String? _errorMessage;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _navigateToForgotPassword() {
    // Handle navigation to the forgot password screen
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  void _navigateToHomePageAsGuest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(isGuest: true)),
    );
  }

  void _login() async {
    try {
      User? user = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(isGuest: false)),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to login. Please check your credentials.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found with this email.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Incorrect password.';
        } else {
          _errorMessage = 'An error occurred. Please try again.';
        }
      });
    }
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
              SizedBox(height: 100), // Add some spacing to center the content
              // Login text
              Text(
                'Login',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: Color(0xFF18492F), // Hexadecimal color
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Login to your account text
              Text(
                'Login to your account',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Color(0xFF18492F), size: 30), // Change color
                  hintText: 'Email',
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
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF18492F), size: 30), // Change color
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
              SizedBox(height: 10),
              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              // Forgot password text link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _navigateToForgotPassword,
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Color(0xFF18492F), // Change color
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF18492F), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Don't have an account text with Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  TextButton(
                    onPressed: _navigateToSignUp,
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color(0xFF18492F), // Change color
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20), // Add some spacing at the bottom
              // Continue as guest button
              TextButton(
                onPressed: _navigateToHomePageAsGuest,
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: Color(0xFF18492F),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20), // Add some spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }
}