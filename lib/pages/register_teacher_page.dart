import 'package:flutter/material.dart';
import 'package:norm_journal/constant_subjects.dart';
import 'package:norm_journal/data/repository/firestore_service.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/data/utils/user_preferences.dart';
import 'package:norm_journal/pages/calendar_page.dart';
import 'package:norm_journal/l10n/app_localizations.dart';

class RegisterTeacherPage extends StatefulWidget {
  final ScheduleRepository? scheduleRepository;
  final Function(Locale)? changeLanguage;

  const RegisterTeacherPage({
    super.key, 
    this.scheduleRepository, 
    required this.changeLanguage, });

  @override
  State<RegisterTeacherPage> createState() => _RegisterTeacherPageState();
}

class _RegisterTeacherPageState extends State<RegisterTeacherPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<String> _selectedSubjects = [];
  final FirestoreService _firestoreService = FirestoreService();

    Widget _buildLanguagePicker() {
      return PopupMenuButton<String>(
        icon: const Icon(
          Icons.language, 
          color: Colors.white),
        onSelected: (val) => widget.changeLanguage!(
          val == 'en' ? const Locale('en') : const Locale('ru'),
        ),
        itemBuilder: (ctx) => [
          const PopupMenuItem(value: 'en', child: Text('English')),
          const PopupMenuItem(value: 'ru', child: Text('Русский')),
        ],
      );
    }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Выберите хотя бы один предмет')));
      return;
    }

    try{
    await _firestoreService.saveTeacher(
     name:  _nameController.text.trim(),
     subjects: _selectedSubjects,);

    await UserPreferences.saveUser(
      true, 
      "Teacher", 
      subjects: _selectedSubjects);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => CalendarPage(
            scheduleRepository: widget.scheduleRepository!,
            changeLanguage: (L) {},
          ),
        ),
        (route) => false,
      );
    }
  }catch(e){
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка регистрации: $e')),
      );
    }
  }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.cyan[50],
      appBar: AppBar(title:  Text(l10n.teacherRegistrationTitle), 
      actions: [
        _buildLanguagePicker()
      ],
      backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.assignment_ind, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.fullName, 
                  border: OutlineInputBorder(), 
                  prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? l10n.enterFullName : null,
              ),
              const SizedBox(height: 20),
              Text(l10n.selectSubjects, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(8), 
                    border: Border.all(color: Colors.grey.shade300)),
                  child: ListView.builder(
                    itemCount: ConstantSubjects.subjects.length,
                    itemBuilder: (context, index) {
                      final s = ConstantSubjects.subjects[index];
                      return CheckboxListTile(
                        title: Text(ConstantSubjects.getTranslatedSubject(s, l10n)),
                        value: _selectedSubjects.contains(s),
                        onChanged: (val) => setState(() => val! 
                        ? _selectedSubjects.add(s) 
                        : _selectedSubjects.remove(s)),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, 
                    foregroundColor: Colors.white),
                  onPressed: _register,
                  child: Text(l10n.register, style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}