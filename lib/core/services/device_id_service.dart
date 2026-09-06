import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  static const String _key = 'quizai_device_id';
  final Uuid _uuid = const Uuid();
  String? _cachedId;

  Future<String> getDeviceId() async {
    if (_cachedId != null) return _cachedId!;

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);

    if (id == null) {
      id = _uuid.v4();
      await prefs.setString(_key, id);
    }

    _cachedId = id;
    return id;
  }
}
