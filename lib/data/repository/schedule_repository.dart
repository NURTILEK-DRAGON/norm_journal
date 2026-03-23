import '../data_source/schedule_data_source.dart';

class ScheduleRepository {
  final ScheduleDataSource dataSource;

  ScheduleRepository(this.dataSource);

  Future<bool> hasAnySchedule() async {
    final versions = await dataSource.loadVersions();
    return versions.isNotEmpty;
  }

  Future<void> saveNewSchedule(Map<String, List<String>> schedule) async {
    final versions = await dataSource.loadVersions();

    final now = DateTime.now();
    final fromDate = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
    );

    versions.removeWhere((v) => v.from.isAtSameMomentAs(fromDate));

    versions.add(
      ScheduleVersion(
        from: fromDate,
        schedule: schedule,
      ),
    );

    versions.sort((a, b) => a.from.compareTo(b.from));

    await dataSource.saveVersions(versions);
  }

  Future<Map<String, List<String>>> getScheduleForDate(DateTime date) async {
    final versions = await dataSource.loadVersions();
    if (versions.isEmpty) return {};

    final target = DateTime(date.year, date.month, date.day);

    ScheduleVersion? best;

    for (final v in versions) {
      if (!v.from.isAfter(target)) {
        if (best == null || v.from.isAfter(best.from)) {
          best = v;
        }
      }
    }

    if (best == null) {
      return versions.first.schedule;
    }

    return best.schedule;
  }

  Future<List<DateTime>> getChangeDates() async {
    final versions = await dataSource.loadVersions();
    return versions.map((e) => e.from).toList();
  }
}
