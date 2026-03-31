import 'package:norm_journal/l10n/app_localizations.dart';

class ConstantSubjects {
  static const List<String> subjects = [
    'math',
    'physics',
    'chemistry',
    'biology',
    'geography',
    'history',
    'english',
    'russian',
  ];

  static String getTranslatedSubject(String key, AppLocalizations l10n) {
  switch (key) {
    case 'math': return l10n.subjectMath;
    case 'physics': return l10n.subjectPhysics;
    case 'chemistry': return l10n.subjectChemistry;
    case 'biology': return l10n.subjectBiology;
    case 'geography': return l10n.subjectGeography;
    case 'history': return l10n.subjectHistory;
    case 'english': return l10n.subjectEnglish;
    case 'russian': return l10n.subjectRussian;
    default: return key; // Если вдруг предмет не найден
  }
}
}