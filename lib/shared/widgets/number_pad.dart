import 'package:flutter/material.dart';

/// 아이 손가락에 맞춘 큰 숫자 키패드 (1~9, ⌫, 0, ✓).
/// 부모 잠금과 숫자 거꾸로 게임에서 함께 쓴다.
class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
    this.buttonSize = 76,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onSubmit;
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget key(Widget child, VoidCallback? onTap, {Color? color}) => Padding(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: onTap,
              child: child,
            ),
          ),
        );

    final digitStyle = TextStyle(
        fontSize: buttonSize * 0.42, fontWeight: FontWeight.bold);

    Widget digit(int d) => key(Text('$d', style: digitStyle), () => onDigit(d));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [for (final d in row) digit(d)],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            key(
                Icon(Icons.backspace_outlined,
                    size: buttonSize * 0.38, semanticLabel: '지우기'),
                onBackspace),
            digit(0),
            key(
              Icon(Icons.check_rounded,
                  size: buttonSize * 0.45,
                  color: scheme.onPrimary,
                  semanticLabel: '확인'),
              onSubmit,
              color: onSubmit == null ? null : scheme.primary,
            ),
          ],
        ),
      ],
    );
  }
}
