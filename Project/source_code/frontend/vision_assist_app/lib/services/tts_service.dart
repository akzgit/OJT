import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts;

  TtsService() : _flutterTts = FlutterTts() {
    _initializeTts();
  }

  /// Initializes the TTS engine with basic settings.
  void _initializeTts() async {
    await _flutterTts.setLanguage('en-US'); // Set to your desired language (e.g., 'en-IN' for Indian English)
    await _flutterTts.setSpeechRate(0.5);    // Set speech rate (1.0 is the normal speed, slower is more understandable)
    await _flutterTts.setVolume(1.0);        // Set volume (1.0 is the maximum)
    await _flutterTts.setPitch(1.0);         // Set pitch (1.0 is default, lower is deeper voice, higher is lighter)
  }

  /// Speaks the provided [text].
  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  /// Stops the TTS if it's currently speaking.
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Checks if TTS is currently speaking.
  Future<bool> isSpeaking() async {
    return await _flutterTts.isSpeaking;
  }
}
