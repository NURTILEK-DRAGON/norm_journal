import 'package:norm_journal/l10n/app_localizations.dart';

class ConstantSubjects {
  static const List<String> subjects = [
    'algebra',
    'physics',
    'chemistry',
    'biology',
    'geography',
    'history',
    'english',
    'russian',
    'russian Literature',
    'kyrgyz',
    'kyrgyz Literature',
    'PE',
    'PME',
    'FBE'
  ];

  static String getTranslatedSubject(String key, AppLocalizations l10n) {
  switch (key) {
    case 'algebra': return l10n.subjectAlgebra;
    case 'physics': return l10n.subjectPhysics;
    case 'chemistry': return l10n.subjectChemistry;
    case 'biology': return l10n.subjectBiology;
    case 'geography': return l10n.subjectGeography;
    case 'history': return l10n.subjectHistory;
    case 'english': return l10n.subjectEnglish;
    case 'russian': return l10n.subjectRussian;
    case 'russian Literature': return l10n.subjectRussianLiterature;
    case 'kyrgyz': return l10n.subjectKyrgyz;
    case 'kyrgyz Literature': return l10n.subjectKyrgyzLiterature;
    case 'PE': return l10n.subjectPE;
    case 'PME': return l10n.subjectPME;
    case 'FBE': return l10n.subjectFBE;
    default: return key; // Если вдруг предмет не найден
  }
}
}