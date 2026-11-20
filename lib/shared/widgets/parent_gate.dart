import 'dart:math';

import 'package:flutter/material.dart';

import 'number_pad.dart';

/// 부모 확인용 문제: 두 자리 수 × 한 자리 수 (초2가 아직 배우지 않은 범위).
class MathChallenge {
  MathChallenge(this.a, this.b);

  factory MathChallenge.random([Random? random]) {
    final r = random ?? Random();
    return MathChallenge(12 + r.nextInt(8), 3 + r.nextInt(7)); // 12~19 × 3~9
  }

  final int a;
  final int b;
  int get answer => a * b;
  String get question => '$a × $b = ?';
  bool check(String input) => int.tryParse(input) == answer;
}

/// 부모 메뉴에 들어가기 전에 띄우는 잠금 창. 맞히면 true.
Future<bool> showParentGate(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => const _ParentGateDialog(),
  );
  return result ?? false;
}

class _ParentGateDialog extends StatefulWidget {
  const _ParentGateDialog();

  @override
  State<_ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<_ParentGateDialog> {
  MathChallenge _challenge = MathChallenge.random();
  String _input = '';
  bool _wrong = false;

  void _onDigit(int d) {
    if (_input.length >= 3) return;
    setState(() {
      _input += '$d';
      _wrong = false;
    });
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _submit() {
    if (_challenge.check(_input)) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _wrong = true;
        _input = '';
        _challenge = MathChallenge.random();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('부모님 확인', textAlign: TextAlign.center),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_challenge.question, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              _input.isEmpty ? ' ' : _input,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
            if (_wrong)
              Text('다시 풀어주세요',
                  style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 12),
            NumberPad(
              onDigit: _onDigit,
              onBackspace: _onBackspace,
              onSubmit: _input.isEmpty ? null : _submit,
              buttonSize: 64,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
