import 'package:flutter/material.dart';

/// 태블릿/웹에서도 너무 넓어지지 않도록 가운데 정렬 + 최대 폭 제한.
class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.child, this.maxWidth = 640});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
