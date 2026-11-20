import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/page_frame.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void comingSoon() => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('다음 단계에서 만들어요')));

    return Scaffold(
      appBar: AppBar(title: const Text('부모님 메뉴')),
      body: PageFrame(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('아이 프로필 관리'),
              subtitle: const Text('이름·아바타 고치기, 삭제'),
              onTap: () => context.push('/parent/profiles'),
            ),
            ListTile(
              leading: const Icon(Icons.record_voice_over_outlined),
              title: const Text('소리 설정'),
              subtitle: const Text('말하기 속도, 한국어·영어 음성 점검'),
              onTap: () => context.push('/parent/settings'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: const Text('기록 보기'),
              subtitle: const Text('준비 중'),
              onTap: comingSoon,
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: const Text('영어 단어 관리'),
              subtitle: const Text('준비 중'),
              onTap: comingSoon,
            ),
            ListTile(
              leading: const Icon(Icons.style_outlined),
              title: const Text('놀이 미션 카드'),
              subtitle: const Text('준비 중'),
              onTap: comingSoon,
            ),
          ],
        ),
      ),
    );
  }
}
