import 'package:norm_journal/data/data_source/local_schedule_data_source.dart';
import 'package:norm_journal/data/data_source/remote_schedule_data_source.dart';
import '../data_source/schedule_data_source.dart';

class ScheduleRepository {
  final LocalScheduleDataSource localDataSource;
  final RemoteScheduleDataSource remoteDataSource;

  ScheduleRepository(
    this.localDataSource,
    this.remoteDataSource,);

  Future<void> saveNewSchedule(String groupId, Map<String, List<String>> schedule) async {

    final versions = await remoteDataSource.loadVersionsForGroup(groupId);

    final fromDate = DateTime.now(); 

    versions.removeWhere((v) => v.from.isAtSameMomentAs(fromDate));
    versions.add(ScheduleVersion(from: fromDate, schedule: schedule));
    versions.sort((a, b) => a.from.compareTo(b.from));

    await remoteDataSource.saveVersionsForGroup(groupId, versions);
    
    await localDataSource.saveVersions(versions);
  }

  Future<Map<String, List<String>>> getScheduleForDate(DateTime date, String groupId) async {
    List<ScheduleVersion> versions = await remoteDataSource.loadVersionsForGroup(groupId);
    if (versions.isEmpty) {
      versions = await localDataSource.loadVersions();
    } else {
      await localDataSource.saveVersions(versions);
    }

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
    return best?.schedule ?? versions.first.schedule;
  }

  Future<bool> hasAnySchedule() async {
  // Проверяем локалку или удаленку (для быстроты проверим локалку)
  final versions = await localDataSource.loadVersions();
  return versions.isNotEmpty;
}

Future<List<DateTime>> getChangeDates() async {
  // Получаем даты всех изменений расписания
  final versions = await localDataSource.loadVersions();
  return versions.map((e) => e.from).toList();
}
}



