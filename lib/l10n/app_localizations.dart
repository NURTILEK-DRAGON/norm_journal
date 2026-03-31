import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];


  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  String get createStudentListTitle;
  String get addStudentLabel;
  String get addButton;
  String get saveAndProceedButton;
  String get schedulePageTitle;
  String get scheduleFor;
  String get addLessonButton;
  String get saveLessonsButton;
  String get expelStudentButton;
  String get expelStudentTitle;
  String get lessonsFor;
  String get noLessonsToday;
  String get presentLabel;
  String get absentLabel;
  String get sickLabel;
  String get documentedLabel;
  String get lateLabel;
  String get editLateTimeTitle;
  String get editLessonButton;
  String get removeTimeButton;
  String get cancelButton;
  String get configureAllDays;
  String get readyToSave;
  String get weeklySetUp;
  String get day1;
  String get day2;
  String get day3;
  String get day4;
  String get day5;
  String get day6;
  String get weekday0;
  String get weekday1;
  String get weekday2;
  String get weekday3;
  String get weekday4;
  String get weekday5;
  String get weekday6;
  String get month01;
  String get month02;
  String get month03;
  String get month04;
  String get month05;
  String get month06;
  String get month07;
  String get month08;
  String get month09;
  String get month10;
  String get month11;
  String get month12; 
  String get confirmDeleteTitle;
  String confirmDeleteMessage(Object studentName);
  String get deleteButton;
  String get removeStudentButton;
  String get editStudentName;
  String get saveButton;
  String get editLessonTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
