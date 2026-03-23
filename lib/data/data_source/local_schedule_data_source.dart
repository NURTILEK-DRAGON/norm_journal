import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'schedule_data_source.dart';

class LocalScheduleDataSource implements ScheduleDataSource {
  static const String _key = 'schedule_versions';

  @override
  Future<List<ScheduleVersion>> loadVersions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final List decoded = jsonDecode(raw);
    return decoded.map((e) => ScheduleVersion.fromJson(e)).toList();
  }

  @override
  Future<void> saveVersions(List<ScheduleVersion> versions) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(versions.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
