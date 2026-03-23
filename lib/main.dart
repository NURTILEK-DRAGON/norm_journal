import 'package:norm_journal/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/data/data_source/local_schedule_data_source.dart';

void main() async {
  
  final scheduleRepository = ScheduleRepository(
    LocalScheduleDataSource(),);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AttendanceApp(scheduleRepository: scheduleRepository,));
}
class AttendanceApp extends StatefulWidget {
  
  final ScheduleRepository scheduleRepository;
  const AttendanceApp({
    super.key, 
    required this.scheduleRepository});
  @override
  State<AttendanceApp> createState() => _AttendanceAppState();
}

class _AttendanceAppState extends State<AttendanceApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('language_code');
    if (savedLocale != null) {
      setState(() {
        _locale = Locale(savedLocale);
      });
    }
  }

  void _changeLanguage(Locale newLocale) async {
    setState(() {
      _locale = newLocale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Attendance App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: Colors.green),
        ),
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: CalendarPage(
          changeLanguage: _changeLanguage,
          scheduleRepository: widget.scheduleRepository
          ),
      );
  }
}
