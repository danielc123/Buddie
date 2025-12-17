import 'dart:typed_data';
import 'package:app/config/default_config.dart';
import 'dart:developer' as dev;
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:wav/wav.dart';
import 'package:flutter/foundation.dart';
import 'package:dart_openai/dart_openai.dart';

class OpenAiAsr {
  static get apiKey => DefaultConfig.defaultLlmToken;

  bool get isAvailable {
    return apiKey.isNotEmpty;
  }

  Future<void> init() async {
    if (isAvailable) {
      OpenAI.apiKey = apiKey;
    }
  }

  Future<String> recognize(Float32List audioData) async {
    if (!isAvailable) {
      throw Exception('OpenAI API key not configured');
    }

    final audioFile = await _writeAudioToFile(audioData);
    try {
      final transcription = await OpenAI.instance.audio.createTranscription(
        file: audioFile,
        model: 'whisper-1',
      );
      dev.log("Whisper API result: ${transcription.text}");
      return transcription.text;
    } catch (error) {
      dev.log("Recognition error: $error");
      throw error;
    } finally {
      await audioFile.delete();
    }
  }

  Future<File> _writeAudioToFile(Float32List audioData) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/recorded_audio_$timestamp.wav');

    final wav = Wav([Float64List.fromList(audioData)], 16000);
    await file.writeAsBytes(wav.write());
    return file;
  }

  void dispose() {
    // No specific resources to dispose for OpenAI ASR
    dev.log('OpenAI ASR disposed');
  }
}
