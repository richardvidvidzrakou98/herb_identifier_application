import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'LoginPage.dart';
import 'HomePage.dart'; // Import HomePage

class ProfilePage extends StatelessWidget {
  final String name;
  final String email;

  ProfilePage({required this.name, required this.email});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF18492F),
        title: Center(child: Text('Profile', style: GoogleFonts.lato(color: Colors.white))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $name',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: Color(0xFF18492F),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Email: $email',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: Color(0xFF18492F),
                  fontSize: 20,
                ),
              ),
            ),
            // Spacer(),
            SizedBox(height: 250),
            Center(
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF18492F),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
