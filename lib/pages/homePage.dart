import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'display_result.dart'; // Import the DisplayResult page
import 'history_page.dart';
import 'profile_page.dart'; // Import the ProfilePage
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomePage extends StatefulWidget {
  final bool isGuest;

  HomePage({required this.isGuest});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _name;
  String? _email;
  bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    if (!widget.isGuest) {
      _fetchUserData();
    }
  }

  void _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _name = userData['fullName'];
        _email = userData['email'];
      });
    }
  }

  Future<void> _identifyHerb(File image) async {
    setState(() {
      _isLoading = true;
    });

    String url = 'http://172.20.10.3:8000/ml/classify-herb/';
    //String gptUrl = dotenv.env['GPT_VISION_API_ENDPOINT']!;
    //String apikey = dotenv.env['OPENAI_API_KEY']!;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var result = jsonDecode(responseData);

        setState(() {
          _isLoading = false;
        });

        if (result != null && result['herbName'] != null) {
          String herbName = result['herbName'];
          String medicinalProperties = result['medicinalProperties'];
          String uses = result['uses'];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DisplayResult(
                herbName: herbName,
                medicinalProperties: medicinalProperties,
                uses: uses,
              ),
            ),
          );
        } else {
          _showErrorDialog('No Recognition Result', 'The herb could not be identified. Please try again with a clearer image.');
        }
      } else {
        _showErrorDialog('Error', 'Failed to connect to the server.');
      }
    } catch (e) {
      print('Error identifying herb: $e');
      _showErrorDialog('Error', 'An error occurred while identifying the herb. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }








  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF18492F),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Herb Identifier',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            widget.isGuest
                ? PopupMenuButton<String>(
              icon: Icon(Icons.person, color: Colors.white),
              onSelected: (value) {
                if (value == 'Sign In') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Sign In'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
                : IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      name: _name ?? 'Loading...',
                      email: _email ?? 'Loading...',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for herbs...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF18492F)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                if (!widget.isGuest) {
                  // Handle search history only if not in guest mode
                }
              },
            ),
            SizedBox(height: 10,),



            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add padding to the sides
                child: Wrap(
                  spacing: 10, // Add spacing between the buttons
                  runSpacing: 10, // Add spacing between rows if buttons wrap
                  alignment: WrapAlignment.center, // Align buttons to the center
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        print('Camera button pressed');
                        try {
                          final ImagePicker _picker = ImagePicker();
                          final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                          if (image != null) {
                            print('Image captured: ${image.path}');
                            await _identifyHerb(File(image.path));
                          } else {
                            print('No image selected');
                          }
                        } catch (e) {
                          print('Error capturing image: $e');
                        }
                      },
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      label: Text('Capture Leaf', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF383737),
                        padding: EdgeInsets.symmetric(horizontal: 46, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        print('Upload button pressed');
                        try {
                          final ImagePicker _picker = ImagePicker();
                          final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            print('Image selected: ${image.path}');
                            await _identifyHerb(File(image.path));
                          } else {
                            print('No image selected');
                          }
                        } catch (e) {
                          print('Error selecting image: $e');
                        }
                      },
                      icon: Icon(Icons.upload_file, color: Colors.white),
                      label: Text('Upload Leaf', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF383737),
                        padding: EdgeInsets.symmetric(horizontal: 46, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),






            SizedBox(height: 30),
            Text(
              'Herb Categories',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: Color(0xFF18492F),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryCard('Medicinal'),
                  _buildCategoryCard('Culinary'),
                  _buildCategoryCard('Aromatic'),
                  _buildCategoryCard('Ornamental'),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Recent Identifications',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: Color(0xFF18492F),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildRecentIdentifications(),
          ],
        ),
      ),












      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF18492F),
        unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (widget.isGuest) {
              _showErrorDialog('Sign In Required', 'Please sign in to access this feature.');
            } else {
              switch (index) {
                case 0:
                // Home
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryPage()),
                  );
                  break;
                case 2:
                // Favorites
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        name: _name ?? 'Loading...',
                        email: _email ?? 'Loading...',
                      ),
                    ),
                  );
                  break;
              }
            }
          },

          items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    return GestureDetector(
      onTap: () {
        // Navigate to the category page
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.local_florist, color: Color(0xFF18492F), size: 40),
              SizedBox(height: 10),
              Text(
                category,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: Color(0xFF18492F),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentIdentifications() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.local_florist, color: Color(0xFF18492F)),
          title: Text('Basil'),
          subtitle: Text('Identified on: 12/07/2023'),
        ),
        ListTile(
          leading: Icon(Icons.local_florist, color: Color(0xFF18492F)),
          title: Text('Mint'),
          subtitle: Text('Identified on: 10/07/2023'),
        ),
      ],
    );
  }
}
