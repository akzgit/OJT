import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'voice_helper.dart';
import 'tts_service.dart';

class ActivityRecognitionScreen extends StatefulWidget {
  @override
  _ActivityRecognitionScreenState createState() => _ActivityRecognitionScreenState();
}

class _ActivityRecognitionScreenState extends State<ActivityRecognitionScreen> {
  CameraController? _cameraController;
  bool _isRecording = false;
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
    await _voiceHelper.giveInstructions(
        'You are in the Activity Recognition section. Please record a short video for activity recognition.');
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _startVideoRecording() async {
    if (_cameraController != null && !_isRecording) {
      setState(() {
        _isRecording = true;
      });

      await _cameraController!.startVideoRecording();
      await _voiceHelper.giveInstructions('Recording started. Please perform an activity.');

      // Stop recording after 5 seconds
      await Future.delayed(Duration(seconds: 5));
      await _stopVideoRecording();
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_cameraController != null && _isRecording) {
      XFile videoFile = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      await _voiceHelper.giveInstructions('Recording stopped. Processing the video.');
      await _sendVideoForRecognition(videoFile.path);
    }
  }

  Future<void> _sendVideoForRecognition(String videoPath) async {
    try {
      var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.x.x:8000/api/activity_recognition/'),  // Replace with your backend URL
      );
      request.files.add(await http.MultipartFile.fromPath('file', videoPath));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var activities = _extractActivityPredictions(responseData);
        await _announceActivities(activities);
      } else {
        await _ttsService.speak('Failed to recognize the activity.');
      }
    } catch (e) {
      await _ttsService.speak('Error in recognizing the activity. Please try again.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  List<Map<String, dynamic>> _extractActivityPredictions(String response) {
    // Assuming the backend returns a JSON response with activity predictions
    // e.g., {"activities": [{"activity": "running", "confidence": 0.75}, ...]}
    try {
      var jsonResponse = jsonDecode(response);
      List<dynamic> activities = jsonResponse['activities'] ?? [];
      // Filter activities with confidence > 0.3 (30%)
      return activities.where((activity) => activity['confidence'] > 0.3).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _announceActivities(List<Map<String, dynamic>> activities) async {
    if (activities.isEmpty) {
      await _ttsService.speak('No activities were confidently recognized.');
    } else {
      StringBuffer activityMessage = StringBuffer('The following activities were recognized: ');
      for (var activity in activities) {
        activityMessage.write('${activity['activity']} with ${((activity['confidence'] as double) * 100).toStringAsFixed(1)} percent confidence. ');
      }
      await _ttsService.speak(activityMessage.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Recognition'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraController!),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isRecording || _isProcessing ? null : _startVideoRecording,
            child: Text(_isRecording ? 'Recording...' : 'Start Video Recording'),
          ),
          if (_isProcessing) ...[
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing video, please wait...'),
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
