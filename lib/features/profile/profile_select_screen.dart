import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/profile_repository.dart';
import '../../shared/widgets/page_frame.dart';
import '../../shared/widgets/parent_gate.dart';
import '../../shared/widgets/profile_editor_dialog.dart';

class ProfileSelectScreen extends ConsumerWidget {
  const ProfileSelectScreen({super.key});

  Future<void> _createProfile(BuildContext context, WidgetRef ref,
      {required bool needsGate}) async {
    if (needsGate && !await showParentGate(context)) return;
    if (!context.mounted) return;
    final draft = await showProfileEditor(context);
    if (draft == null) return;
    final profile = await ref
        .read(profilesProvider.notifier)
        .add(name: draft.name, avatar: draft.avatar);
    await ref.read(currentProfileIdProvider.notifier).select(profile.id);
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: PageFrame(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text('🧠✨', style: TextStyle(fontSize: 64)),
              Text('기억력 놀이터', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                profiles.isEmpty ? '먼저 친구를 만들어 볼까요?' : '누가 놀러 왔나요?',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: profiles.isEmpty
                    ? Center(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 20),
                            textStyle: theme.textTheme.titleLarge,
                          ),
                          onPressed: () =>
                              _createProfile(context, ref, needsGate: false),
                          icon: const Icon(Icons.add),
                          label: const Text('친구 만들기'),
                        ),
                      )
                    : GridView.extent(
                        maxCrossAxisExtent: 180,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          for (final p in profiles)
                            _ProfileCard(
                              emoji: p.avatar,
                              label: p.name,
                              onTap: () async {
                                await ref
                                    .read(currentProfileIdProvider.notifier)
                                    .select(p.id);
                                if (context.mounted) context.go('/home');
                              },
                            ),
                          _ProfileCard(
                            emoji: '➕',
                            label: '친구 추가',
                            onTap: () =>
                                _createProfile(context, ref, needsGate: true),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 8),
            Text(label,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
