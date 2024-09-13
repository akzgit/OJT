import 'package:flutter/material.dart';
import 'voice_helper.dart';
import 'welcome_screen.dart';
import 'face_recognition_screen.dart';
import 'add_face_screen.dart';
import 'activity_recognition_screen.dart';
import 'text_reading_screen.dart';
import 'currency_detection_screen.dart';
import 'object_detection_screen.dart';
import 'image_description_screen.dart';

void main() {
  runApp(VisionAssistApp());
}

class VisionAssistApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision Assist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomeScreen(),  // The welcome screen is shown for first-time users
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VoiceHelper _voiceHelper = VoiceHelper();  // For handling voice instructions and listening

  @override
  void initState() {
    super.initState();
    _startVoiceControl();
  }

  Future<void> _startVoiceControl() async {
    // Give the user instructions using TTS
    await _voiceHelper.giveInstructions('Please select a feature or say the feature name.');
    // Listen for the user's voice command
    String? command = await _voiceHelper.listenForCommand();
    if (command != null) {
      _handleVoiceCommand(command);  // Handle the recognized voice command
    }
  }

  void _handleVoiceCommand(String command) {
    // Handle navigation based on voice commands
    if (command.toLowerCase().contains('face recognition')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => FaceRecognitionScreen()));
    } else if (command.toLowerCase().contains('add face')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddFaceScreen()));
    } else if (command.toLowerCase().contains('activity recognition')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityRecognitionScreen()));
    } else if (command.toLowerCase().contains('text reading')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TextReadingScreen()));
    } else if (command.toLowerCase().contains('currency detection')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CurrencyDetectionScreen()));
    } else if (command.toLowerCase().contains('object detection')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ObjectDetectionScreen()));
    } else if (command.toLowerCase().contains('image description')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ImageDescriptionScreen()));
    } else if (command.toLowerCase().contains('help')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));  // Go to help/welcome screen
    } else {
      _voiceHelper.giveInstructions("I didn't understand that command. Please try again.");  // Fallback for unrecognized command
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vision Assist'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Face Recognition'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FaceRecognitionScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Add Face'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFaceScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Activity Recognition'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActivityRecognitionScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Text Reading'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TextReadingScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Currency Detection'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CurrencyDetectionScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Object Detection'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ObjectDetectionScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Image Description'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageDescriptionScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
