import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../core/storage.dart';

/// 말하기 속도 배율 (0.6 ~ 1.4, 기본 1.0).
class SpeechRateNotifier extends Notifier<double> {
  Box get _box => Hive.box(Boxes.settings);

  @override
  double build() =>
      (_box.get(SettingKeys.speechRate, defaultValue: 1.0) as num).toDouble();

  Future<void> set(double value) async {
    state = value;
    await _box.put(SettingKeys.speechRate, value);
  }
}

final speechRateProvider =
    NotifierProvider<SpeechRateNotifier, double>(SpeechRateNotifier.new);
