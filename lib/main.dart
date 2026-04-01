import 'package:norm_journal/data/data_source/remote_schedule_data_source.dart';
import 'package:norm_journal/data/utils/user_preferences.dart';
import 'package:norm_journal/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:norm_journal/pages/role_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/data/data_source/local_schedule_data_source.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final localDS = LocalScheduleDataSource();
  final remoteDS = RemoteScheduleDataSource();
  final scheduleRepository = ScheduleRepository(localDS, remoteDS);
  final bool registered = await UserPreferences.isRegistered();
  
  runApp(AttendanceApp(
    scheduleRepository: scheduleRepository,
    isRegistered: registered,));
}
class AttendanceApp extends StatefulWidget {
  
  final ScheduleRepository scheduleRepository;
  final bool isRegistered;

  const AttendanceApp({
    super.key, 
    required this.scheduleRepository, 
    required this.isRegistered});
    
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
        home: widget.isRegistered 
         ? CalendarPage(
          changeLanguage: _changeLanguage,
          scheduleRepository: widget.scheduleRepository
          )
          :  RoleSelectionPage(
          scheduleRepository: widget.scheduleRepository, 
          changeLanguage: _changeLanguage,)
      );
  }
}
