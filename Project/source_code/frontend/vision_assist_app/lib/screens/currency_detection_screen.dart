import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'voice_helper.dart';
import 'tts_service.dart';

class CurrencyDetectionScreen extends StatefulWidget {
  @override
  _CurrencyDetectionScreenState createState() => _CurrencyDetectionScreenState();
}

class _CurrencyDetectionScreenState extends State<CurrencyDetectionScreen> {
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
    await _voiceHelper.giveInstructions('You are in the Currency Detection section. Please capture an image of the currency note.');
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _detectCurrency() async {
    if (_cameraController != null) {
      setState(() {
        _isProcessing = true;
      });

      final image = await _cameraController!.takePicture();
      await _sendImageForCurrencyDetection(image.path);

      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _sendImageForCurrencyDetection(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.x.x:8000/api/detect_currency/'),  // Replace with your backend URL
      );
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var currency = _extractCurrency(responseData);
        await _ttsService.speak('The currency note is $currency.');
      } else {
        await _ttsService.speak('Failed to recognize the currency note.');
      }
    } catch (e) {
      await _ttsService.speak('Error in recognizing the currency. Please try again.');
    }
  }

  String _extractCurrency(String response) {
    // Logic to extract the recognized currency denomination from the response
    // Assuming the backend returns a JSON with a 'currency' field
    try {
      var jsonResponse = jsonDecode(response);
      return jsonResponse['currency'] ?? 'Unknown currency';
    } catch (e) {
      return 'Unable to extract currency information.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Detection'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraController!),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isProcessing ? null : _detectCurrency,
            child: Text('Capture and Detect Currency'),
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
