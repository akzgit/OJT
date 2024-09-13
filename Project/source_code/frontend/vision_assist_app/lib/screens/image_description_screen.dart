import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'voice_helper.dart';
import 'tts_service.dart';

class ImageDescriptionScreen extends StatefulWidget {
  @override
  _ImageDescriptionScreenState createState() => _ImageDescriptionScreenState();
}

class _ImageDescriptionScreenState extends State<ImageDescriptionScreen> {
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
    await _voiceHelper.giveInstructions('You are in the Image Description section. Please capture an image to get its description.');
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _describeImage() async {
    if (_cameraController != null) {
      setState(() {
        _isProcessing = true;
      });

      final image = await _cameraController!.takePicture();
      await _sendImageForDescription(image.path);

      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _sendImageForDescription(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.x.x:8000/api/describe_image/'),  // Replace with your backend URL
      );
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var description = _extractDescription(responseData);
        await _ttsService.speak('The image contains: $description');
      } else {
        await _ttsService.speak('Failed to describe the image.');
      }
    } catch (e) {
      await _ttsService.speak('Error in describing the image. Please try again.');
    }
  }

  String _extractDescription(String response) {
    // Logic to extract the image description from the response
    // Assuming the backend returns a JSON with a 'description' field
    try {
      var jsonResponse = jsonDecode(response);
      return jsonResponse['description'] ?? 'No description available';
    } catch (e) {
      return 'Unable to extract description.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Image Description'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraController!),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isProcessing ? null : _describeImage,
            child: Text('Capture and Describe Image'),
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
