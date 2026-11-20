import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tts_service.dart';
import '../../data/repositories/profile_repository.dart';
import '../../shared/widgets/page_frame.dart';
import '../../shared/widgets/parent_gate.dart';
import '../games/game_catalog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('곧 만들어질 거예요! 🛠️')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final theme = Theme.of(context);
    if (profile == null) return const SizedBox.shrink(); // 라우터가 '/'로 보냄

    return Scaffold(
      appBar: AppBar(
        // 이름을 누르면 인사말을 들려준다 (소리 확인 겸용)
        title: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            textStyle: theme.textTheme.titleLarge,
          ),
          onPressed: () => ref
              .read(ttsServiceProvider)
              .speak('안녕, ${profile.name}! 오늘도 같이 놀자!'),
          child: Text('${profile.avatar} ${profile.name}, 안녕!'),
        ),
        actions: [
          IconButton(
            tooltip: '친구 바꾸기',
            icon: const Icon(Icons.switch_account_outlined),
            onPressed: () => context.go('/'),
          ),
          IconButton(
            tooltip: '부모님 메뉴',
            icon: const Icon(Icons.lock_outline),
            onPressed: () async {
              if (await showParentGate(context) && context.mounted) {
                context.push('/parent');
              }
            },
          ),
        ],
      ),
      body: PageFrame(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 오늘의 코스
            Card(
              color: theme.colorScheme.primaryContainer,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _comingSoon(context),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Text('🚀', style: TextStyle(fontSize: 56)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '오늘의 코스',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '10분 동안 4가지 놀이를 해요',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.play_circle_fill, size: 48),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('자유 놀이', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                for (final g in gameCatalog)
                  _Tile(
                    emoji: g.emoji,
                    title: g.title,
                    subtitle: g.subtitle,
                    color: g.color,
                    onTap: () => g.route == null
                        ? _comingSoon(context)
                        : context.push(g.route!),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Tile(
                    emoji: '👨‍👧',
                    title: '함께하기',
                    subtitle: '엄마 아빠랑',
                    color: const Color(0xFFE85D75),
                    onTap: () => _comingSoon(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Tile(
                    emoji: '⭐',
                    title: '스티커북',
                    subtitle: '모은 스티커',
                    color: const Color(0xFFE2B007),
                    onTap: () => _comingSoon(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 6),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
