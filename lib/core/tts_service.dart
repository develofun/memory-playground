import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../data/repositories/settings_repository.dart';

enum TtsLang {
  ko('ko-KR'),
  en('en-US');

  const TtsLang(this.code);
  final String code;
}

/// flutter_tts 래퍼.
/// - 한 번에 하나의 발화만 진행 (새 발화 시작 시 이전 발화 중단)
/// - [speakSequence]로 숫자/단어를 일정 간격으로 하나씩 읽기
/// - [stop]을 부르면 진행 중인 시퀀스도 중단
class TtsService {
  TtsService(this._rateMultiplier);

  final double Function() _rateMultiplier;
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  int _generation = 0;

  /// 플랫폼마다 '보통 속도' 값이 다르다 (웹 1.0 기준, 안드로이드 0.5 기준).
  double get _baseRate => kIsWeb ? 0.9 : 0.45;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  Future<void> _prepare(TtsLang lang) async {
    await _ensureInit();
    await _tts.setLanguage(lang.code);
    await _tts.setSpeechRate((_baseRate * _rateMultiplier()).clamp(0.1, 1.5));
  }

  /// 문장 하나를 읽고, 다 읽을 때까지 기다린다.
  Future<void> speak(String text, {TtsLang lang = TtsLang.ko}) async {
    final gen = ++_generation;
    await _tts.stop();
    await _prepare(lang);
    if (gen != _generation) return;
    await _tts.speak(text);
  }

  /// 항목을 하나씩 [gap] 간격으로 읽는다. 중간에 [stop]되면 false.
  Future<bool> speakSequence(
    List<String> items, {
    TtsLang lang = TtsLang.ko,
    Duration gap = const Duration(milliseconds: 600),
  }) async {
    final gen = ++_generation;
    await _tts.stop();
    await _prepare(lang);
    for (final item in items) {
      if (gen != _generation) return false;
      await _tts.speak(item);
      if (gen != _generation) return false;
      await Future<void>.delayed(gap);
    }
    return gen == _generation;
  }

  Future<void> stop() async {
    _generation++;
    await _tts.stop();
  }

  /// 기기에 해당 언어 음성이 있는지 (부모 설정의 소리 점검용).
  Future<bool> isLanguageAvailable(TtsLang lang) async {
    await _ensureInit();
    try {
      final result = await _tts.isLanguageAvailable(lang.code);
      return result == true || result == 1;
    } catch (_) {
      // 웹 등 일부 플랫폼은 미지원 → 목록에서 직접 확인
      final langs = await _tts.getLanguages;
      if (langs is List) {
        final prefix = lang.code.split('-').first.toLowerCase();
        return langs.any((l) => l.toString().toLowerCase().startsWith(prefix));
      }
      return false;
    }
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService(() => ref.read(speechRateProvider));
  ref.onDispose(service.stop);
  return service;
});
