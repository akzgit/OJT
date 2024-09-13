import 'package:flutter/material.dart';
import 'voice_helper.dart';
import 'tts_service.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TtsService _ttsService = TtsService();
  final VoiceHelper _voiceHelper = VoiceHelper();

  @override
  void initState() {
    super.initState();
    _speakWelcomeMessage();
  }

  /// Speaks the welcome message with instructions for the user.
  Future<void> _speakWelcomeMessage() async {
    await _voiceHelper.giveInstructions(
      "Welcome to the Vision Assist app. "
      "This app helps you with object detection, text reading, face recognition, and currency detection. "
      "You can control the app by voice commands or manual interaction. "
      "To start, say 'Start' or choose a feature from the screen. "
      "If you need help at any time, just say 'Help'."
    );
  }

  /// Speaks the help message when the user says 'Help'.
  Future<void> _speakHelpMessage() async {
    await _voiceHelper.giveInstructions(
      "Here are the instructions: "
      "You can say 'Object Detection' to start detecting objects, "
      "'Text Reading' to read text from an image, "
      "'Face Recognition' to identify faces, "
      "or 'Currency Detection' to identify currency notes. "
      "Use voice commands or tap the screen to select any feature."
    );
  }

  /// Starts listening for voice commands.
  Future<void> _listenForVoiceCommand() async {
    String? command = await _voiceHelper.listenForCommand();
    if (command != null) {
      _processCommand(command);
    }
  }

  /// Processes the recognized voice command.
  void _processCommand(String command) {
    if (command.toLowerCase().contains('help')) {
      _speakHelpMessage();
    } else if (command.toLowerCase().contains('start')) {
      _ttsService.speak('Please choose a feature to begin.');
      // Navigate to the next screen based on your app's flow
    } else {
      _ttsService.speak('Unknown command. Please say help for instructions.');
    }
  }

  @override
  void dispose() {
    _voiceHelper.stopAll();  // Stop any ongoing TTS or STT when screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Vision Assist'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Vision Assist',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Say "Start" or tap a button to begin.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _ttsService.speak('Object Detection selected.');
                // Navigate to Object Detection Screen
              },
              child: Text('Object Detection'),
            ),
            ElevatedButton(
              onPressed: () {
                _ttsService.speak('Text Reading selected.');
                // Navigate to Text Reading Screen
              },
              child: Text('Text Reading'),
            ),
            ElevatedButton(
              onPressed: () {
                _ttsService.speak('Face Recognition selected.');
                // Navigate to Face Recognition Screen
              },
              child: Text('Face Recognition'),
            ),
            ElevatedButton(
              onPressed: () {
                _ttsService.speak('Currency Detection selected.');
                // Navigate to Currency Detection Screen
              },
              child: Text('Currency Detection'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _speakHelpMessage,  // Manual button to get help instructions
              child: Text('Help'),
            ),
          ],
        ),
      ),
    );
  }
}
