import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/profile_repository.dart';
import '../../shared/widgets/page_frame.dart';
import '../../shared/widgets/profile_editor_dialog.dart';

class ProfileManageScreen extends ConsumerWidget {
  const ProfileManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    final notifier = ref.read(profilesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('아이 프로필 관리')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('추가'),
        onPressed: () async {
          final draft = await showProfileEditor(context);
          if (draft != null) {
            await notifier.add(name: draft.name, avatar: draft.avatar);
          }
        },
      ),
      body: PageFrame(
        child: ListView(
          children: [
            for (final p in profiles)
              ListTile(
                leading: Text(p.avatar, style: const TextStyle(fontSize: 32)),
                title: Text(p.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: '고치기',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        final draft =
                            await showProfileEditor(context, initial: p);
                        if (draft != null) {
                          await notifier.save(
                              p.copyWith(name: draft.name, avatar: draft.avatar));
                        }
                      },
                    ),
                    IconButton(
                      tooltip: '삭제',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('${p.name} 프로필을 삭제할까요?'),
                            content: const Text('이 아이의 기록도 함께 사라지고 되돌릴 수 없어요.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('취소'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('삭제'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) await notifier.remove(p.id);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
