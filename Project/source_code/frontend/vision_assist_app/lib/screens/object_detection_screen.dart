import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'voice_helper.dart';
import 'tts_service.dart';
import 'package:path_provider/path_provider.dart';

class ObjectDetectionScreen extends StatefulWidget {
  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  CameraController? _cameraController;
  bool _isStreaming = false;
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
    await _voiceHelper.giveInstructions('You are in the Object Detection section. Live streaming will begin shortly.');
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _startLiveStream() async {
    if (_cameraController != null && !_isStreaming) {
      setState(() {
        _isStreaming = true;
      });

      _streamFrames();
    }
  }

  Future<void> _streamFrames() async {
    try {
      while (_isStreaming) {
        XFile image = await _cameraController!.takePicture();
        await _sendFrameForDetection(image.path);

        // Stream frames every 1 second
        await Future.delayed(Duration(seconds: 1));
      }
    } catch (e) {
      await _ttsService.speak('Error during live streaming. Please try again.');
    }
  }

  Future<void> _sendFrameForDetection(String imagePath) async {
    try {
      setState(() {
        _isProcessing = true;
      });

      var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.x.x:8000/api/object_detection/'),  // Replace with your backend URL
      );
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var objects = _extractDetectedObjects(responseData);
        await _announceDetectedObjects(objects);
      } else {
        await _ttsService.speak('Failed to detect objects.');
      }
    } catch (e) {
      await _ttsService.speak('Error during object detection. Please try again.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  List<Map<String, dynamic>> _extractDetectedObjects(String response) {
    // Assuming the backend returns a JSON with detected objects
    // e.g., {"objects": [{"name": "person", "confidence": 0.85}, ...]}
    try {
      var jsonResponse = jsonDecode(response);
      List<dynamic> objects = jsonResponse['objects'] ?? [];
      return objects.where((object) => object['confidence'] > 0.3).toList(); // Filter confidence > 30%
    } catch (e) {
      return [];
    }
  }

  Future<void> _announceDetectedObjects(List<Map<String, dynamic>> objects) async {
    if (objects.isEmpty) {
      await _ttsService.speak('No objects detected.');
    } else {
      StringBuffer detectedMessage = StringBuffer('Detected objects: ');
      for (var object in objects) {
        detectedMessage.write('${object['name']} with ${((object['confidence'] as double) * 100).toStringAsFixed(1)} percent confidence. ');
      }
      await _ttsService.speak(detectedMessage.toString());
    }
  }

  Future<void> _stopLiveStream() async {
    setState(() {
      _isStreaming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraController!),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isStreaming ? _stopLiveStream : _startLiveStream,
            child: Text(_isStreaming ? 'Stop Live Streaming' : 'Start Live Streaming'),
          ),
          if (_isProcessing) ...[
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing frame, please wait...'),
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
