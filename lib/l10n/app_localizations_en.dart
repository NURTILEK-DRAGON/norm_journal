// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get createStudentListTitle => 'Create Student List';

  @override
  String get addStudentLabel => 'Add Student Name';

  @override
  String get addButton => 'Add';

  @override
  String get saveAndProceedButton => 'Save and Proceed';

  @override
  String get schedulePageTitle => 'Schedule Page';

  @override
  String get scheduleFor => 'Schedule for';

  @override
  String get addLessonButton => 'Add Lesson';

  @override
  String get saveLessonsButton => 'Save Lessons';

  @override
  String get expelStudentButton => 'Expel Student';

  @override
  String get expelStudentTitle => 'Expel Student';

  @override
  String get lessonsFor => 'Lessons -';

  @override
  String get noLessonsToday => 'No lessons on this day';

  @override
  String get presentLabel => 'Present';

  @override
  String get absentLabel => 'Absent';

  @override
  String get sickLabel => 'Sick';

  @override
  String get documentedLabel => 'Documented';

  @override
  String get lateLabel => 'Late';

  @override
  String get editLateTimeTitle => 'Edit Late Time';

  @override
  String get editLessonButton => 'Edit Lesson';

  @override
  String get removeTimeButton => 'Remove Time';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get weekday0 => 'Sun';

  @override
  String get weekday1 => 'Mon';

  @override
  String get weekday2 => 'Tue';

  @override
  String get weekday3 => 'Wed';

  @override
  String get weekday4 => 'Thu';

  @override
  String get weekday5 => 'Fri';

  @override
  String get weekday6 => 'Sat';

  @override
  String get month01 => 'January';

  @override
  String get month02 => 'February';

  @override
  String get month03 => 'March';

  @override
  String get month04 => 'April';

  @override
  String get month05 => 'May';

  @override
  String get month06 => 'June';

  @override
  String get month07 => 'July';

  @override
  String get month08 => 'August';

  @override
  String get month09 => 'September';

  @override
  String get month10 => 'October';

  @override
  String get month11 => 'November';

  @override
  String get month12 => 'December';

  @override
  String get confirmDeleteTitle => 'Confirm Delete';

  @override
  String confirmDeleteMessage(Object studentName) {
    return 'Are you sure you want to delete $studentName?';
  }

  @override
  String get deleteButton => 'Delete';

  @override
  String get removeStudentButton => 'Remove Student';

  @override
  String get editStudentName => 'Edit Student Name';

  @override
  String get saveButton => 'Save';

  @override
  String get editLessonTitle => 'Edit Lesson';
}
