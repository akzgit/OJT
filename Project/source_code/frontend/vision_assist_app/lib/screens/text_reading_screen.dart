import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'voice_helper.dart';
import 'tts_service.dart';

class TextReadingScreen extends StatefulWidget {
  @override
  _TextReadingScreenState createState() => _TextReadingScreenState();
}

class _TextReadingScreenState extends State<TextReadingScreen> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  final TtsService _ttsService = TtsService();
  final VoiceHelper _voiceHelper = VoiceHelper();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _giveInstructions();
  }

  Future<void> _giveInstructions() async {
    await _voiceHelper.giveInstructions('You are in the Text Reading section. Please capture an image of the text you want to read.');
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _readTextFromImage() async {
    if (_cameraController != null) {
      setState(() {
        _isProcessing = true;
      });

      final image = await _cameraController!.takePicture();
      await _sendImageForTextReading(image.path);

      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _sendImageForTextReading(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.x.x:8000/api/read_text/'),  // Replace with your backend URL
      );
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var text = _extractTextFromResponse(responseData);
        await _ttsService.speak('The extracted text is: $text');
      } else {
        await _ttsService.speak('Failed to extract text from the image.');
      }
    } catch (e) {
      await _ttsService.speak('Error in reading text from the image. Please try again.');
    }
  }

  String _extractTextFromResponse(String response) {
    // Logic to extract the recognized text from the response
    // Assuming the backend returns a JSON with a 'text' field
    try {
      var jsonResponse = jsonDecode(response);
      return jsonResponse['text'] ?? 'No text found';
    } catch (e) {
      return 'Unable to extract text from the image.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Text Reading'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraController!),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isProcessing ? null : _readTextFromImage,
            child: Text('Capture and Read Text'),
          ),
          if (_isProcessing) ...[
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing image, please wait...'),
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
