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

  Future<String> recognize(Float32List audioData, String lang) async {
    if (_deepgram == null || !isAvailable) {
      dev.log("Deepgram not initialized");
      return '';
    }

    final params = {
      'language': lang,
      'encoding': 'linear16',
      'sample_rate': 16000,
    };

    final audioBytes = _float32ListToUint8List(audioData);

    try {
      final res = await _deepgram!.listen.bytes(audioBytes, queryParams: params);
      return res.transcript ?? '';
    } catch (e) {
      dev.log('Deepgram recognize error: $e');
      return '';
    }
  }

  Uint8List _float32ListToUint8List(Float32List float32list) {
    final byteData = ByteData(float32list.length * 2);
    for (int i = 0; i < float32list.length; i++) {
      final sample = (float32list[i] * 32767).toInt();
      byteData.setInt16(i * 2, sample, Endian.little);
    }
    return byteData.buffer.asUint8List();
  }
}
