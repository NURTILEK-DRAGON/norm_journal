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
  String get studentsLable => 'Students ';

  @override
  String get addStudentLabel => 'Add Student Name';

  @override
  String get addButton => 'Add';

  @override
  String get changeSchedulelabel => 'Change';

  @override
  String get setSchedulelabel => 'Set Up';

  @override
  String get saveAndProceedButton => 'Save and Proceed';

  @override
  String get schedulePageTitle => 'Schedule Page';

  @override
  String get scheduleFor => 'Schedule for';

  @override
  String lessonsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '$count lesson',
    );
    return '$_temp0';
  }

  @override
  String get notSet => 'Not set';

  @override
  String get presentStatus => 'Present';

  @override
  String get absentStatus => 'Absent';

  @override
  String get sickStatus => 'Sick';

  @override
  String get documentedStatus => 'Documented';

  @override
  String get addLessonButton => 'Add Lesson';

  @override
  String get saveLessonsButton => 'Save Lessons';

  @override
  String get expelStudentButton => 'Expel Student';

  @override
  String get expelStudentTitle => 'Expel Student';

  @override
  String get lessonsFor => 'Lessons';

  @override
  String get noLessonsToday => 'No lessons on this day';

  @override
  String get lesson => 'Lesson';

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
  String get editTimeButton => 'Edit Time';

  @override
  String get removeTimeButton => 'Remove Time';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get weeklySetUp => 'Weekly Setup';

  @override
  String get day1 => 'Monday';

  @override
  String get day2 => 'Tuesday';

  @override
  String get day3 => 'Wednesday';

  @override
  String get day4 => 'Thursday';

  @override
  String get day5 => 'Friday';

  @override
  String get day6 => 'Saturday';

  @override
  String get day7 => 'Sunday';

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
  String get readyToSave => 'Ready to Save';

  @override
  String get configureAllDays => 'Configure All Days';

  @override
  String get confirmDeleteTitle => 'Confirm Delete';

  @override
  String get subjectAlgebra => 'Algebra';

  @override
  String get subjectEnglish => 'English';

  @override
  String get subjectPhysics => 'Physics';

  @override
  String get subjectChemistry => 'Chemistry';

  @override
  String get subjectBiology => 'Biology';

  @override
  String get subjectGeography => 'Geography';

  @override
  String get subjectHistory => 'History';

  @override
  String get subjectRussian => 'Russian';

  @override
  String get subjectRussianLiterature => 'Russian Literature';

  @override
  String get subjectKyrgyz => 'Kyrgyz';

  @override
  String get subjectKyrgyzLiterature => 'Kyrgyz Literature';

  @override
  String get subjectPE => 'Physical Education';

  @override
  String get subjectPME => 'PME';

  @override
  String get subjectFBE => 'FBE';

  @override
  String get noLessonsYet => 'No lessons yet';

  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String confirmDeleteMessage(Object studentName) {
    return 'Are you sure you want to delete $studentName?';
  }

  @override
  String get deleteButton => 'Delete';

  @override
  String get editStudentName => 'Edit Student Name';

  @override
  String get saveButton => 'Save';

  @override
  String get editLessonTitle => 'Edit Lesson';

  @override
  String get whoAreYou => 'Who are you?';

  @override
  String get selectYourRole => 'Select your role';

  @override
  String get iAmMonitor => 'I am a Monitor';

  @override
  String get iAmTeacher => 'I am a Teacher';

  @override
  String get monitorRegistrationTitle => 'Monitor Registration';

  @override
  String get teacherRegistrationTitle => 'Teacher Registration';

  @override
  String get enterGroupName => 'Enter Group Name';

  @override
  String get groupNameLabel => 'Group Name';

  @override
  String get groupNameHint => 'E.g. RMP-24';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter Full Name';

  @override
  String get selectSubjects => 'Select Subjects';

  @override
  String get selectAnySubject => 'Select at least one subject';

  @override
  String get register => 'Register';
}
