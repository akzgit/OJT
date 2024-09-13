import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'voice_helper.dart';
import 'tts_service.dart';

class FaceRecognitionScreen extends StatefulWidget {
  @override
  _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  CameraController? _cameraController;
  bool _isRecognizing = false;
  final TtsService _ttsService = TtsService();
  final VoiceHelper _voiceHelper = VoiceHelper();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _giveInstructions();
  }

  Future<void> _giveInstructions() async {
    await _voiceHelper.giveInstructions('You are in the Face Recognition section. Please capture an image for face recognition.');
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _recognizeFace() async {
    if (_cameraController != null) {
      setState(() {
        _isRecognizing = true;
      });

      final image = await _cameraController!.takePicture();
      await _sendImageForRecognition(image.path);

      setState(() {
        _isRecognizing = false;
      });
    }
  }

  Future<void> _sendImageForRecognition(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.x.x:8000/api/recognize_face/'),  // Replace with your backend URL
      );
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var recognizedPerson = _extractRecognizedPerson(responseData);
        await _ttsService.speak('This is $recognizedPerson');
      } else {
        await _ttsService.speak('Face not recognized.');
      }
    } catch (e) {
      await _ttsService.speak('Error in face recognition. Please try again.');
    }
  }

  String _extractRecognizedPerson(String response) {
    // Logic to extract the recognized person’s name from the response
    // Assuming the response contains the person's name as part of JSON or plain text
    // For simplicity, we are assuming the response contains the name directly
    return response.contains('name') ? response : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Face Recognition'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraController!),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isRecognizing ? null : _recognizeFace,
            child: Text('Capture and Recognize Face'),
          ),
          if (_isRecognizing) ...[
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Recognizing face, please wait...'),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
