# 기억력 놀이터 (memory-playground)

초등학교 저학년 아이의 **순간·단기 기억력(작업기억)**을 놀이로 키우는 Flutter 앱입니다.
Android 앱(APK)과 웹(PWA)을 하나의 코드로 만듭니다.

## 주요 기능 (개발 예정)
- 🔢 **숫자 거꾸로 말하기**: 들은 숫자를 거꾸로 입력
- 🛒 **시장에 가면**: 하나씩 늘어나는 물건을 순서대로 기억
- 📋 **지시 따르기**: 2~4단계 지시를 듣고 순서대로 수행
- 🔤 **영어 단어**: 듣고 그림 고르기, 간격 반복 복습
- 👨‍👧 **함께하기**: 부모와 주고받기 게임, 오프라인 놀이 미션 카드
- ⭐ 자동 난이도 조절, 스티커 보상, 부모용 기록 화면, 아이 여러 명 프로필

모든 데이터는 기기 안에만 저장되며, 서버나 로그인은 없습니다.

자세한 계획은 [docs/PLAN.md](docs/PLAN.md)를 참고하세요.

## 실행 방법
```bash
flutter pub get
flutter run -d chrome          # 웹
flutter run -d <android-device> # 안드로이드 (flutter devices로 확인)
flutter test                   # 단위 테스트
```

## 개발 환경
- Flutter 3.38 / Dart 3.10
- Android 빌드: Android Studio에 포함된 JDK 17 이상
