import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/tts_service.dart';
import '../../data/repositories/settings_repository.dart';
import '../../shared/widgets/page_frame.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Map<TtsLang, bool>? _available;

  @override
  void initState() {
    super.initState();
    _checkVoices();
  }

  Future<void> _checkVoices() async {
    final tts = ref.read(ttsServiceProvider);
    final result = {
      for (final lang in TtsLang.values)
        lang: await tts.isLanguageAvailable(lang),
    };
    if (mounted) setState(() => _available = result);
  }

  @override
  Widget build(BuildContext context) {
    final rate = ref.watch(speechRateProvider);
    final tts = ref.read(ttsServiceProvider);
    final theme = Theme.of(context);

    String voiceStatus(TtsLang lang) => switch (_available?[lang]) {
          null => '확인 중…',
          true => '✅ 사용 가능',
          false => '⚠️ 음성이 없어요 (기기 설정 → 텍스트 음성 변환에서 설치)',
        };

    return Scaffold(
      appBar: AppBar(title: const Text('소리 설정')),
      body: PageFrame(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('말하기 속도', style: theme.textTheme.titleMedium),
            Slider(
              value: rate,
              min: 0.6,
              max: 1.4,
              divisions: 8,
              label: rate.toStringAsFixed(1),
              onChanged: (v) => ref.read(speechRateProvider.notifier).set(v),
            ),
            Text(
              rate < 1 ? '천천히' : (rate > 1 ? '빠르게' : '보통'),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 32),
            ListTile(
              leading: const CircleAvatar(child: Text('한')),
              title: const Text('한국어 음성'),
              subtitle: Text(voiceStatus(TtsLang.ko)),
              trailing: FilledButton.tonal(
                onPressed: () => tts.speakSequence(
                  ['숫자를 잘 들어 보세요.', '3', '7', '2'],
                ),
                child: const Text('들어보기'),
              ),
            ),
            ListTile(
              leading: const CircleAvatar(child: Text('En')),
              title: const Text('영어 음성'),
              subtitle: Text(voiceStatus(TtsLang.en)),
              trailing: FilledButton.tonal(
                onPressed: () => tts.speakSequence(
                  ['apple', "I'm hungry."],
                  lang: TtsLang.en,
                ),
                child: const Text('들어보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
