import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String url = 'http://172.20.10.3:8000/ml_model/get-search-history?user_id=${user.uid}';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          setState(() {
            history = jsonDecode(response.body);
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load history');
        }
      } catch (e) {
        print('Error fetching history: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search History'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return ListTile(
            title: Text(item['herb_name']),
            subtitle: Text(item['medicinal_properties']),
            trailing: Text(item['timestamp']),
          );
        },
      ),
    );
  }
}
