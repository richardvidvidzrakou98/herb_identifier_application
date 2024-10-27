import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite/tflite.dart';

class TFLiteHelper {
  // Load the TFLite model
  static Future<void> loadModel() async {
    try {
      print('Attempting to load TFLite model...');
      String? result = await Tflite.loadModel(
        model: 'assets/models/model.tflite',
        labels: 'assets/models/labels.txt',
      );

      if (result == null || result.isEmpty) {
        print('Error: Model failed to load. Result is null or empty.');
      } else {
        print('Model loaded successfully: $result');
      }
    } catch (e) {
      print('Exception occurred while loading model: $e');
    }
  }

  // Preprocess the image and identify the herb
  static Future<Map<String, dynamic>?> identifyHerb(String imagePath) async {
    try {
      print('Starting herb identification for image at path: $imagePath');

      // Preprocess the image: resize to 150x150
      img.Image? image = img.decodeImage(File(imagePath).readAsBytesSync());
      if (image != null) {
        print('Image successfully decoded. Original size: ${image.width}x${image.height}');
        img.Image resizedImage = img.copyResize(image, width: 150, height: 150);
        print('Image resized to: 150x150');

        // Save the resized image to temporary path
        String tempPath = imagePath + "_resized.png";
        File(tempPath).writeAsBytesSync(img.encodePng(resizedImage));
        print('Resized image saved to temporary path: $tempPath');

        // Run the model on the resized image
        print('Running TFLite model on resized image...');
        var recognitions = await Tflite.runModelOnImage(
          path: tempPath, // Use the resized image path
          imageMean: 127.5, // Standardize the image mean to 127.5
          imageStd: 127.5, // Standardize the image std to 127.5
          numResults: 5, // Adjust based on expected number of outputs
          threshold: 0.3, // Try lowering the threshold to catch low confidence results
          asynch: true, // Ensure the model runs asynchronously
        );

        print('Recognition results: $recognitions');

        if (recognitions != null && recognitions.isNotEmpty) {
          var topRecognition = recognitions[0];
          print('Top recognition: ${topRecognition['label']} with confidence: ${topRecognition['confidence']}');

          return {
            'herbName': topRecognition['label'],
            'confidence': topRecognition['confidence'], // Adding confidence for the top recognition
            'medicinalProperties': 'Medicinal properties of ${topRecognition['label']}', // Mock data
            'uses': 'Uses of ${topRecognition['label']}', // Mock data
          };
        } else {
          print('No recognition result found');
        }
      } else {
        print('Failed to decode image. Image might be corrupt or unsupported format.');
      }
    } catch (e) {
      print('Failed to identify herb: $e');
    }
    return null;
  }

  // Dispose of the TFLite model
  static void disposeModel() {
    try {
      print('Attempting to dispose of the TFLite model...');
      Tflite.close();
      print('Model disposed successfully');
    } catch (e) {
      print('Failed to dispose model: $e');
    }
  }
}
