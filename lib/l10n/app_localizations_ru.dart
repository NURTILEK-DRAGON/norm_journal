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
  String get studentsLable => 'Студенты';

  @override
  String get addStudentLabel => 'Добавить имя ученика';

  @override
  String get addButton => 'Добавить';

  @override
  String get changeSchedulelabel => 'Изменить';

  @override
  String get setSchedulelabel => 'Настроить';

  @override
  String get saveAndProceedButton => 'Сохранить и продолжить';

  @override
  String get schedulePageTitle => 'Страница расписания';

  @override
  String get scheduleFor => 'Расписание для';

  @override
  String lessonsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count уроков',
      few: '$count урока',
      one: '$count урок',
    );
    return '$_temp0';
  }

  @override
  String get notSet => 'Не установлено';

  @override
  String get addLessonButton => 'Добавить урок';

  @override
  String get saveLessonsButton => 'Сохранить уроки';

  @override
  String get expelStudentButton => 'Исключить ученика';

  @override
  String get expelStudentTitle => 'Исключить ученика';

  @override
  String get lessonsFor => 'Уроки';

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
  String get editTimeButton => 'Редактировать время';

  @override
  String get removeTimeButton => 'Удалить время';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get weeklySetUp => 'Настройка расписания';

  @override
  String get day1 => 'Понедельник'; 

  @override
  String get day2 => 'Вторник';

  @override
  String get day3 => 'Среда';

  @override
  String get day4 => 'Четверг';

  @override
  String get day5 => 'Пятница';

  @override
  String get day6 => 'Суббота';

  @override
  String get day7 => 'Воскресенье';

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
  String get readyToSave => 'Готово к сохранению';

  @override
  String get configureAllDays => 'Настроить все дни';

  @override
  String get confirmDeleteTitle => 'Подтверждение удаления';

  @override
  String get subjectAlgebra => 'Алгебра';

  @override
  String get subjectPhysics => 'Физика';

  @override
  String get subjectChemistry => 'Химия';

  @override
  String get subjectBiology => 'Биология';

  @override
  String get subjectGeography => 'География';

  @override
  String get subjectHistory => 'История';

  @override
  String get subjectEnglish => 'Английский';

  @override
  String get subjectRussian => 'Русский';

  @override
  String get subjectRussianLiterature => 'Русская литература';

  @override
  String get subjectKyrgyz => 'Кыргызский';

  @override
  String get subjectKyrgyzLiterature => 'Кыргызская литература';

  @override
  String get subjectPE => 'Физическая культура';

  @override
  String get subjectPME => 'ДПМ';

  @override
  String get subjectFBE => 'ОБиП';

  @override
  String get noLessonsYet => 'Уроки еще не добавлены';

  @override
  String get savedSuccessfully => 'Успешно сохранено';


  @override
  String confirmDeleteMessage(Object studentName) {
    return 'Вы уверены, что хотите удалить $studentName?';
  }

  @override
  String get deleteButton => 'Удалить';

  @override
  String get editStudentName => 'Редактировать имя студента';

  @override
  String get saveButton => 'Сохранить';

  @override
  String get editLessonTitle => 'Редактировать урок';

  @override
  String get whoAreYou => 'Кто вы?';

  @override
  String get selectYourRole => 'Выберите вашу роль для настройки профиля';

  @override
  String get iAmMonitor => 'Я Староста';

  @override
  String get iAmTeacher => 'Я Преподаватель';

  @override
  String get monitorRegistrationTitle => 'Регистрация старосты';

  @override
  String get teacherRegistrationTitle => 'Регистрация преподавателя';

  @override
  String get enterGroupName => 'Введите группы';

  @override
  String get groupNameLabel => 'Название группы';

  @override
  String get groupNameHint => 'Например: РМП-24';

  @override
  String get fullName => 'ФИО';

  @override
  String get enterFullName => 'Введите ФИО';

  @override
  String get selectSubjects => 'Выберите предметы:';

  @override
  String get selectAnySubject => 'Выберите хотя бы один предмет';

  @override
  String get register => 'Зарегистрироваться';


}
