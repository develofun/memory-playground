import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/repositories/profile_repository.dart';
import 'features/home/home_screen.dart';
import 'features/parent/parent_home_screen.dart';
import 'features/parent/profile_manage_screen.dart';
import 'features/parent/settings_screen.dart';
import 'features/profile/profile_select_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // 프로필이 바뀌면 redirect를 다시 계산하도록 알림
  final refresh = ValueNotifier<int>(0);
  ref.listen(currentProfileProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final hasProfile = ref.read(currentProfileProvider) != null;
      final loc = state.matchedLocation;
      // 프로필이 없으면 아이용 화면 대신 프로필 선택으로
      if (!hasProfile && loc == '/home') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const ProfileSelectScreen()),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/parent',
        builder: (_, _) => const ParentHomeScreen(),
        routes: [
          GoRoute(
              path: 'profiles',
              builder: (_, _) => const ProfileManageScreen()),
          GoRoute(
              path: 'settings', builder: (_, _) => const SettingsScreen()),
        ],
      ),
    ],
  );
});

class MemoryPlaygroundApp extends ConsumerWidget {
  const MemoryPlaygroundApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: '기억력 놀이터',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: buildAppTheme(),
    );
  }
}

/// 아이용 테마: 따뜻한 색, 큰 글씨, 둥근 모서리.
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF8A3D)),
    fontFamily: 'Jua',
    // Jua에 없는 한글은 NotoSansKRFill로, 이모지는 웹에서만 앱에 넣은 글꼴로 그린다.
    // (안드로이드는 기기 기본 이모지가 더 안정적이라 시스템 글꼴을 쓴다)
    fontFamilyFallback:
        kIsWeb ? const ['NotoSansKRFill', 'NotoEmoji'] : const ['NotoSansKRFill'],
  );
  // ThemeData.textTheme에는 fontSize가 비어 있어서 바로 배율을 곱할 수 없다.
  // Material 3 글자 크기(englishLike2021)를 먼저 채운 뒤 1.1배로 키운다.
  final sizedText = Typography.englishLike2021.merge(base.textTheme);
  return base.copyWith(
    textTheme: sizedText.apply(fontSizeFactor: 1.1),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 56),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}
