import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DisplayResult extends StatelessWidget {
  final String herbName;
  final String medicinalProperties;
  final String uses;

  DisplayResult({
    required this.herbName,
    required this.medicinalProperties,
    required this.uses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF18492F),
        title: Text(
          'Herb Details',
          style: GoogleFonts.lato(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Herb Identification Result',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: Color(0xFF18492F),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildResultTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTable() {
    return Table(
      border: TableBorder.all(color: Color(0xFF18492F)),
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            _buildTableHeaderCell('Name of Herb'),
            _buildTableContentCell(herbName),
          ],
        ),
        TableRow(
          children: [
            _buildTableHeaderCell('Medicinal Properties'),
            _buildTableContentCell(medicinalProperties),
          ],
        ),
        TableRow(
          children: [
            _buildTableHeaderCell('Uses'),
            _buildTableContentCell(uses),
          ],
        ),
      ],
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: Color(0xFF18492F),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTableContentCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: Color(0xFF18492F),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
