import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'speech_service.dart';
import 'voice_helper.dart';

class AddFaceScreen extends StatefulWidget {
  @override
  _AddFaceScreenState createState() => _AddFaceScreenState();
}

class _AddFaceScreenState extends State<AddFaceScreen> {
  CameraController? _cameraController;
  final VoiceHelper _voiceHelper = VoiceHelper();
  List<XFile> _capturedImages = [];
  bool _isCapturing = false;
  String? _personName;
  bool _confirmingName = false;
  bool _nameConfirmed = false;
  final int _requiredImages = 5;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _giveInitialInstructions();
  }

  Future<void> _giveInitialInstructions() async {
    await _voiceHelper.giveInstructions(
        'You are in the Add Face section. Please take 5 pictures of the person. After that, I will ask for the person\'s name.');
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _capturedImages.length < _requiredImages) {
      final image = await _cameraController!.takePicture();
      setState(() {
        _capturedImages.add(image);
      });

      if (_capturedImages.length == _requiredImages) {
        await _voiceHelper.giveInstructions('You have taken 5 pictures. Now please tell me the name of the person.');
        await _askForName();
      } else {
        await _voiceHelper.giveInstructions(
            'Picture ${_capturedImages.length} taken. Please take more.');
      }
    }
  }

  Future<void> _askForName() async {
    String? name = await _voiceHelper.listenForCommand();
    if (name != null) {
      setState(() {
        _personName = name;
        _confirmingName = true;
      });
      await _confirmName();
    } else {
      await _voiceHelper.giveInstructions('I didn\'t catch that. Please say the name again.');
      await _askForName();
    }
  }

  Future<void> _confirmName() async {
    await _voiceHelper.giveInstructions('You said $_personName. Is that correct? Say yes or no.');
    String? response = await _voiceHelper.listenForCommand();
    if (response != null && response.toLowerCase().contains('yes')) {
      setState(() {
        _nameConfirmed = true;
        _confirmingName = false;
      });
      await _voiceHelper.giveInstructions('Thank you! The name has been confirmed. Now sending data.');
      await _sendData();
    } else {
      await _voiceHelper.giveInstructions('Let\'s try again. Please tell me the name of the person.');
      await _askForName();
    }
  }

  Future<void> _sendData() async {
    if (_capturedImages.length == _requiredImages && _personName != null && _nameConfirmed) {
      var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.x.x:8000/api/add_face/'), // Replace with your backend URL
      );
      for (var image in _capturedImages) {
        request.files.add(await http.MultipartFile.fromPath('files', image.path));
      }
      request.fields['name'] = _personName!;
      var response = await request.send();

      if (response.statusCode == 200) {
        await _voiceHelper.giveInstructions('The face and name have been successfully added.');
      } else {
        await _voiceHelper.giveInstructions('Failed to add the face. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Face'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraController!),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isCapturing || _capturedImages.length == _requiredImages ? null : _captureImage,
            child: Text('Capture Image'),
          ),
          SizedBox(height: 16),
          _capturedImages.isEmpty
              ? Text('No images captured yet.')
              : Text('${_capturedImages.length} of $_requiredImages images taken'),
          SizedBox(height: 16),
          if (_confirmingName) ...[
            Text('Waiting for name confirmation...'),
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
