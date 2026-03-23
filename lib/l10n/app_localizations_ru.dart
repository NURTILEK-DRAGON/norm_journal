// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get createStudentListTitle => 'Создать список учеников';

  @override
  String get addStudentLabel => 'Добавить имя ученика';

  @override
  String get addButton => 'Добавить';

  @override
  String get saveAndProceedButton => 'Сохранить и продолжить';

  @override
  String get schedulePageTitle => 'Страница расписания';

  @override
  String get scheduleFor => 'Расписание для';

  @override
  String get addLessonButton => 'Добавить урок';

  @override
  String get saveLessonsButton => 'Сохранить уроки';

  @override
  String get expelStudentButton => 'Исключить ученика';

  @override
  String get expelStudentTitle => 'Исключить ученика';

  @override
  String get lessonsFor => 'Уроки -';

  @override
  String get noLessonsToday => 'Нет уроков в этот день';

  @override
  String get presentLabel => 'Присутствует';

  @override
  String get absentLabel => 'Отсутствует';

  @override
  String get sickLabel => 'Болен';

  @override
  String get documentedLabel => 'Документировано';

  @override
  String get lateLabel => 'Опоздал';

  @override
  String get editLateTimeTitle => 'Редактировать время опоздания';

  @override
  String get editLessonButton => 'Редактировать урок';

  @override
  String get removeTimeButton => 'Удалить время';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get weekday0 => 'Вс';

  @override
  String get weekday1 => 'Пн';

  @override
  String get weekday2 => 'Вт';

  @override
  String get weekday3 => 'Ср';

  @override
  String get weekday4 => 'Чт';

  @override
  String get weekday5 => 'Пт';

  @override
  String get weekday6 => 'Сб';

  @override
  String get month01 => 'Январь';

  @override
  String get month02 => 'Февраль';

  @override
  String get month03 => 'Март';

  @override
  String get month04 => 'Апрель';

  @override
  String get month05 => 'Май';

  @override
  String get month06 => 'Июнь';

  @override
  String get month07 => 'Июль';

  @override
  String get month08 => 'Август';

  @override
  String get month09 => 'Сентябрь';

  @override
  String get month10 => 'Октябрь';

  @override
  String get month11 => 'Ноябрь';

  @override
  String get month12 => 'Декабрь';

  @override
  String get confirmDeleteTitle => 'Подтверждение удаления';

  @override
  String confirmDeleteMessage(Object studentName) {
    return 'Вы уверены, что хотите удалить $studentName?';
  }

  @override
  String get deleteButton => 'Удалить';

  @override
  String get removeStudentButton => 'Удалить студента';

  @override
  String get editStudentName => 'Редактировать имя студента';

  @override
  String get saveButton => 'Сохранить';

  @override
  String get editLessonTitle => 'Редактировать урок';
}
