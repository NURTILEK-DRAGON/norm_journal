abstract class ScheduleDataSource {
  Future<List<ScheduleVersion>> loadVersions();
  Future<void> saveVersions(List<ScheduleVersion> versions);
}

class ScheduleVersion {
  final DateTime from;
  final Map<String, List<String>> schedule;

  ScheduleVersion({
    required this.from,
    required this.schedule,
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from.toIso8601String(),
      'schedule': schedule,
    };
  }

  factory ScheduleVersion.fromJson(Map<String, dynamic> json) {
    final rawSchedule = json['schedule'] as Map<String, dynamic>;

    return ScheduleVersion(
      from: DateTime.parse(json['from']),
      schedule: rawSchedule.map(
        (key, value) => MapEntry(
          key,
          List<String>.from(value),
        ),
      ),
    );
  }
}
