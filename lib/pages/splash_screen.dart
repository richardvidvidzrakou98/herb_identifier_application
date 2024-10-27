import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'LoginPage.dart';
import 'RegisterScreen.dart';
import 'HomePage.dart'; // Import HomePage

class SplashScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'images/background_3.jpg',
            fit: BoxFit.cover,
          ),
          // Black overlay to reduce exposure
          Container(
            color: Colors.black.withOpacity(0.68), // Adjust the opacity as needed
          ),
          // Foreground content
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Align the logo image at the top center
                Padding(
                  padding: const EdgeInsets.only(top: 60.0), // Adjust the top padding as needed
                  child: Image.asset(
                    'images/app_logo_4-remove_bg.png',
                    width: 280, // Adjust the width as needed
                    height: 110, // Adjust the height as needed
                  ),
                ),
                SizedBox(height: 40), // Space between the logo and the next text
                Text(
                  'Welcome to Herb Identifier,\n your personal guide to identifying and learning about medicinal herbs',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Text(
                  'Let\'s explore the healing power of nature together',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: 290,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.white.withOpacity(0.2), // White text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Rounded corners
                      ),
                    ),
                    child: Text('Sign In'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    'Create an account',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(isGuest: true)), // Pass the isGuest flag
                    );
                  },
                  child: Text(
                    'Continue without an account',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
