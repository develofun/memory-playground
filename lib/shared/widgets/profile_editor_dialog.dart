import 'package:flutter/material.dart';

import '../../data/models/profile.dart';

class ProfileDraft {
  const ProfileDraft(this.name, this.avatar);
  final String name;
  final String avatar;
}

/// 프로필 만들기/고치기 창. 취소하면 null.
Future<ProfileDraft?> showProfileEditor(
  BuildContext context, {
  Profile? initial,
}) {
  return showDialog<ProfileDraft>(
    context: context,
    builder: (_) => _ProfileEditorDialog(initial: initial),
  );
}

class _ProfileEditorDialog extends StatefulWidget {
  const _ProfileEditorDialog({this.initial});
  final Profile? initial;

  @override
  State<_ProfileEditorDialog> createState() => _ProfileEditorDialogState();
}

class _ProfileEditorDialogState extends State<_ProfileEditorDialog> {
  late final _nameController =
      TextEditingController(text: widget.initial?.name ?? '');
  late String _avatar = widget.initial?.avatar ?? Profile.avatars.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _valid => _nameController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.initial == null ? '새 친구 만들기' : '프로필 고치기'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: '이름 (별명도 좋아요)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final a in Profile.avatars)
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _avatar = a),
                    child: Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          width: 3,
                          color: a == _avatar
                              ? scheme.primary
                              : Colors.transparent,
                        ),
                        color: a == _avatar
                            ? scheme.primaryContainer
                            : scheme.surfaceContainerHighest,
                      ),
                      child: Text(a, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _valid
              ? () => Navigator.of(context)
                  .pop(ProfileDraft(_nameController.text.trim(), _avatar))
              : null,
          child: const Text('저장'),
        ),
      ],
    );
  }
}
