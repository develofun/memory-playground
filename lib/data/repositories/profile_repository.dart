import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:uuid/uuid.dart';

import '../../core/storage.dart';
import '../models/profile.dart';

class ProfilesNotifier extends Notifier<List<Profile>> {
  Box get _box => Hive.box(Boxes.profiles);

  @override
  List<Profile> build() => _load();

  List<Profile> _load() => _box.values
      .map((raw) => Profile.fromMap(asStringMap(raw)))
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  Future<Profile> add({required String name, required String avatar}) async {
    final profile = Profile(
      id: const Uuid().v4(),
      name: name.trim(),
      avatar: avatar,
      createdAt: DateTime.now(),
    );
    await _box.put(profile.id, profile.toMap());
    state = _load();
    return profile;
  }

  Future<void> save(Profile profile) async {
    await _box.put(profile.id, profile.toMap());
    state = _load();
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
    if (ref.read(currentProfileIdProvider) == id) {
      await ref.read(currentProfileIdProvider.notifier).select(null);
    }
    state = _load();
  }
}

final profilesProvider =
    NotifierProvider<ProfilesNotifier, List<Profile>>(ProfilesNotifier.new);

/// 지금 사용 중인 아이 프로필 id (앱을 다시 켜도 유지).
class CurrentProfileIdNotifier extends Notifier<String?> {
  Box get _box => Hive.box(Boxes.settings);

  @override
  String? build() => _box.get(SettingKeys.currentProfileId) as String?;

  Future<void> select(String? id) async {
    state = id;
    if (id == null) {
      await _box.delete(SettingKeys.currentProfileId);
    } else {
      await _box.put(SettingKeys.currentProfileId, id);
    }
  }
}

final currentProfileIdProvider =
    NotifierProvider<CurrentProfileIdNotifier, String?>(
        CurrentProfileIdNotifier.new);

final currentProfileProvider = Provider<Profile?>((ref) {
  final id = ref.watch(currentProfileIdProvider);
  if (id == null) return null;
  final profiles = ref.watch(profilesProvider);
  for (final p in profiles) {
    if (p.id == id) return p;
  }
  return null;
});
