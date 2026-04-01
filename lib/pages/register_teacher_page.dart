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
          color: Colors.blueAccent),
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
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(l10n.teacherRegistrationTitle, 
        style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [_buildLanguagePicker()],
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Icon(Icons.school_rounded, size: 70, color: Colors.blueAccent.withOpacity(0.8))),
              const SizedBox(height: 32),
              
              _buildInputLabel(l10n.fullName),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(l10n.fullName, Icons.person_outline),
                validator: (v) => v!.isEmpty ? l10n.enterFullName : null,
              ),
              
              const SizedBox(height: 24),
              _buildInputLabel(l10n.selectSubjects),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ListView.separated(
                    itemCount: ConstantSubjects.subjects.length,
                    separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey[100]),
                    itemBuilder: (context, index) {
                      final s = ConstantSubjects.subjects[index];
                      final isSelected = _selectedSubjects.contains(s);
                      return CheckboxListTile(
                        activeColor: Colors.blueAccent,
                        title: Text(ConstantSubjects.getTranslatedSubject(s, l10n)),
                        value: isSelected,
                        onChanged: (val) => setState(() => val! ? _selectedSubjects.add(s) : _selectedSubjects.remove(s)),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  onPressed: _register,
                  child: Text(l10n.register, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
    );
  }
}