import 'dart:async';
import 'dart:typed_data';
import 'package:app/config/default_config.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'dart:developer' as dev;

typedef OnAsrResult = void Function(String transcript, bool isFinal);

class DeepgramAsr {
  static get apiKey => DefaultConfig.defaultDeepgramApiKey;

  Deepgram? _deepgram;
  DeepgramLiveListener? _listener;
  Stream<List<int>>? _micStream;

  OnAsrResult? onResult;

  bool get isAvailable => apiKey.isNotEmpty;

  Future<void> init() async {
    if (isAvailable) {
      _deepgram = Deepgram(apiKey);
    }
  }

  void startStreaming(Stream<List<int>> micStream, String lang) {
    if (_deepgram == null || !isAvailable) {
      dev.log("Deepgram not initialized");
      return;
    }

    _micStream = micStream;

    final params = {
      'language': lang,
      'encoding': 'linear16',
      'sample_rate': 16000,
      'interim_results': true,
      'endpointing': 300,
    };

    _listener = _deepgram!.listen.liveListener(_micStream!, queryParams: params);

    _listener!.stream.listen((result) {
      final transcript = result.transcript;
      final isFinal = result.map['is_final'];
      if (transcript != null && transcript.isNotEmpty) {
        onResult?.call(transcript, isFinal);
      }
    });

    _listener!.start();
  }

  void pushAudio(List<int> audio) {
    // This is handled by the stream directly
  }

  void stopStreaming() {
    _listener?.close();
    _listener = null;
  }

  void dispose() {
    stopStreaming();
  }
}
