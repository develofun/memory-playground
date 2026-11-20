import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:memory_playground/app.dart';
import 'package:memory_playground/core/storage.dart';
import 'package:memory_playground/data/repositories/profile_repository.dart';
import 'package:memory_playground/features/home/home_screen.dart';
import 'package:memory_playground/features/profile/profile_select_screen.dart';

/// 실제 앱 테마로 각 화면을 그려서 렌더링 오류(예: 테마 assert)를 잡는다.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mp_test');
    Hive.init(tempDir.path);
    await Hive.openBox(Boxes.profiles);
    await Hive.openBox(Boxes.settings);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  Widget wrap(Widget child, ProviderContainer container) =>
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  testWidgets('프로필 선택 화면 (빈 상태)', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(wrap(const ProfileSelectScreen(), container));
    expect(tester.takeException(), isNull);
    expect(find.text('친구 만들기'), findsOneWidget);
  });

  testWidgets('홈 화면', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final profile = await tester.runAsync(() => container
        .read(profilesProvider.notifier)
        .add(name: '테스트', avatar: '🐶'));
    await tester.runAsync(() =>
        container.read(currentProfileIdProvider.notifier).select(profile!.id));
    await tester.pumpWidget(wrap(const HomeScreen(), container));
    expect(tester.takeException(), isNull);
    expect(find.text('오늘의 코스'), findsOneWidget);
  });
}
