import "package:flutter/material.dart";
import "package:hive/hive.dart";

class NotificationSettingsRepository extends ChangeNotifier {
  static const _boxName = "pet_diary_settings";
  static const _key = "notification_settings";

  late Box _box;
  bool _initialized = false;

  bool enabled = true;
  bool silentMode = false;
  bool duplicateEmail = false;
  bool receiveReminders = true;
  bool receiveClinic = true;
  bool receiveBilling = true;

  bool get isInitialized => _initialized;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    final stored = _box.get(_key);
    if (stored is Map) {
      enabled = stored['enabled'] as bool? ?? enabled;
      silentMode = stored['silentMode'] as bool? ?? silentMode;
      duplicateEmail = stored['duplicateEmail'] as bool? ?? duplicateEmail;
      receiveReminders = stored['receiveReminders'] as bool? ?? receiveReminders;
      receiveClinic = stored['receiveClinic'] as bool? ?? receiveClinic;
      receiveBilling = stored['receiveBilling'] as bool? ?? receiveBilling;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> update({
    bool? enabled,
    bool? silentMode,
    bool? duplicateEmail,
    bool? receiveReminders,
    bool? receiveClinic,
    bool? receiveBilling,
  }) async {
    if (enabled != null) this.enabled = enabled;
    if (silentMode != null) this.silentMode = silentMode;
    if (duplicateEmail != null) this.duplicateEmail = duplicateEmail;
    if (receiveReminders != null) this.receiveReminders = receiveReminders;
    if (receiveClinic != null) this.receiveClinic = receiveClinic;
    if (receiveBilling != null) this.receiveBilling = receiveBilling;
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    if (!_box.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
    await _box.put(_key, {
      'enabled': enabled,
      'silentMode': silentMode,
      'duplicateEmail': duplicateEmail,
      'receiveReminders': receiveReminders,
      'receiveClinic': receiveClinic,
      'receiveBilling': receiveBilling,
    });
  }

  @override
  void dispose() {
    if (_box.isOpen) {
      _box.close();
    }
    super.dispose();
  }
}
