import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Hive box 이름 모음. 모델은 코드 생성 없이 Map으로 저장한다.
class Boxes {
  static const profiles = 'profiles';
  static const settings = 'settings';
}

/// 설정 box의 키 모음.
class SettingKeys {
  static const currentProfileId = 'currentProfileId';
  static const speechRate = 'speechRate';
}

Future<void> initStorage() async {
  await Hive.initFlutter('memory_playground');
  await Future.wait([
    Hive.openBox(Boxes.profiles),
    Hive.openBox(Boxes.settings),
  ]);
}

/// Hive가 돌려주는 `Map<dynamic, dynamic>`을 `Map<String, dynamic>`으로 변환.
Map<String, dynamic> asStringMap(Object? raw) =>
    Map<String, dynamic>.from(raw as Map);
