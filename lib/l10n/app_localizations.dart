import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// Title for the student list creation page
  ///
  /// In en, this message translates to:
  /// **'Create Student List'**
  String get createStudentListTitle;

  /// Label for the text field to add a student name
  ///
  /// In en, this message translates to:
  /// **'Add Student Name'**
  String get addStudentLabel;

  /// Button text for adding a student
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// Button text for saving the student list and proceeding
  ///
  /// In en, this message translates to:
  /// **'Save and Proceed'**
  String get saveAndProceedButton;

  /// Title for the schedule page
  ///
  /// In en, this message translates to:
  /// **'Schedule Page'**
  String get schedulePageTitle;

  /// Label for the schedule day
  ///
  /// In en, this message translates to:
  /// **'Schedule for'**
  String get scheduleFor;

  /// No description provided for @lessonsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} lesson} other{{count} lessons}}'**
  String lessonsCount(num count);

  /// Label for when a value is not set
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Button text for adding a lesson
  ///
  /// In en, this message translates to:
  /// **'Add Lesson'**
  String get addLessonButton;

  /// Button text for saving lessons
  ///
  /// In en, this message translates to:
  /// **'Save Lessons'**
  String get saveLessonsButton;

  /// Button text for expelling a student
  ///
  /// In en, this message translates to:
  /// **'Expel Student'**
  String get expelStudentButton;

  /// Title for the expel student page
  ///
  /// In en, this message translates to:
  /// **'Expel Student'**
  String get expelStudentTitle;

  /// Prefix for lessons on a specific date
  ///
  /// In en, this message translates to:
  /// **'Lessons -'**
  String get lessonsFor;

  /// Message when there are no lessons on a selected day
  ///
  /// In en, this message translates to:
  /// **'No lessons on this day'**
  String get noLessonsToday;

  /// Label for present attendance status
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get presentLabel;

  /// Label for absent attendance status
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absentLabel;

  /// Label for sick attendance status
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get sickLabel;

  /// Label for documented absence status
  ///
  /// In en, this message translates to:
  /// **'Documented'**
  String get documentedLabel;

  /// Label for late attendance status
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get lateLabel;

  /// Title for the edit late time dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Late Time'**
  String get editLateTimeTitle;

  /// Button text for editing late time
  ///
  /// In en, this message translates to:
  /// **'Edit Time'**
  String get editTimeButton;

  /// Button text for removing late time
  ///
  /// In en, this message translates to:
  /// **'Remove Time'**
  String get removeTimeButton;

  /// Button text for canceling an action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Title for the weekly schedule setup page
  ///
  /// In en, this message translates to:
  /// **'Weekly Setup'**
  String get weeklySetUp;

  String get day1;

  String get day2;

  String get day3;

  String get day4;

  String get day5;

  String get day6;
  

  /// Abbreviation for Sunday
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekday0;

  /// Abbreviation for Monday
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekday1;

  /// Abbreviation for Tuesday
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekday2;

  /// Abbreviation for Wednesday
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekday3;

  /// Abbreviation for Thursday
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekday4;

  /// Abbreviation for Friday
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekday5;

  /// Abbreviation for Saturday
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekday6;

  /// Name of the month January
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get month01;

  /// Name of the month February
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get month02;

  /// Name of the month March
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get month03;

  /// Name of the month April
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get month04;

  /// Name of the month May
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get month05;

  /// Name of the month June
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get month06;

  /// Name of the month July
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get month07;

  /// Name of the month August
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get month08;

  /// Name of the month September
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get month09;

  /// Name of the month October
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get month10;

  /// Name of the month November
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get month11;

  /// Name of the month December
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get month12;

  String get readyToSave;

  String get configureAllDays;
  /// Title for the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteTitle;

  /// Message for the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {studentName}?'**
  String confirmDeleteMessage(Object studentName);

  /// Button text for confirming deletion
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// Button text for removing a student
  ///
  /// In en, this message translates to:
  /// **'Remove Student'**
  String get removeStudentButton;

  /// Title for the edit student name dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Student Name'**
  String get editStudentName;

  /// Button text for saving changes
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// Title for the edit lesson dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Lesson'**
  String get editLessonTitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
