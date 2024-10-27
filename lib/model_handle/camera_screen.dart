// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import '../pages/display_result.dart';
// import 'tflite_helper.dart';
// //import 'display_result.dart';
//
// class CameraScreen extends StatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }
//
// class _CameraScreenState extends State<CameraScreen> {
//   CameraController? _cameraController;
//   bool _isDetecting = false;
//
//   @override
//   void initState() {
//     super.initState();
//     initializeCamera();
//   }
//
//   Future<void> initializeCamera() async {
//     final cameras = await availableCameras();
//     _cameraController = CameraController(cameras[0], ResolutionPreset.high);
//     await _cameraController!.initialize();
//     setState(() {});
//   }
//
//   void onCapture() async {
//     if (_cameraController != null && !_isDetecting) {
//       _isDetecting = true;
//       final image = await _cameraController!.takePicture();
//       final recognitions = await TFLiteHelper.classifyImage(image.path);
//       _isDetecting = false;
//       if (recognitions != null && recognitions.isNotEmpty) {
//         final recognition = recognitions[0];
//         final herb = herbsData.firstWhere(
//                 (herb) => herb['Name'] == recognition['label']);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DisplayResult(
//               herbName: herb['Name'],
//               medicinalProperties: herb['Medicinal Properties'],
//               uses: herb['Uses'],
//             ),
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Capture Herb'),
//         backgroundColor: Color(0xFF18492F),
//       ),
//       body: _cameraController == null || !_cameraController!.value.isInitialized
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           Expanded(
//             flex: 3,
//             child: CameraPreview(_cameraController!),
//           ),
//           Expanded(
//             flex: 1,
//             child: Center(
//               child: ElevatedButton(
//                 onPressed: onCapture,
//                 child: Text('Capture Image'),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
