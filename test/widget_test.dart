import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_playground/data/models/profile.dart';
import 'package:memory_playground/shared/widgets/parent_gate.dart';

void main() {
  group('MathChallenge', () {
    test('범위: 12~19 × 3~9', () {
      final r = Random(42);
      for (var i = 0; i < 500; i++) {
        final c = MathChallenge.random(r);
        expect(c.a, inInclusiveRange(12, 19));
        expect(c.b, inInclusiveRange(3, 9));
      }
    });

    test('정답 확인', () {
      final c = MathChallenge(14, 6);
      expect(c.question, '14 × 6 = ?');
      expect(c.check('84'), isTrue);
      expect(c.check('85'), isFalse);
      expect(c.check(''), isFalse);
      expect(c.check('abc'), isFalse);
    });
  });

  test('Profile toMap/fromMap 왕복', () {
    final p = Profile(
      id: 'abc',
      name: '테스트',
      avatar: '🐶',
      createdAt: DateTime(2026, 11, 20, 9, 30),
    );
    final restored = Profile.fromMap(p.toMap());
    expect(restored.id, p.id);
    expect(restored.name, p.name);
    expect(restored.avatar, p.avatar);
    expect(restored.createdAt, p.createdAt);
  });
}
