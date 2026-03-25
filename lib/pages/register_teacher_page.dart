import 'package:flutter/material.dart';
import 'package:norm_journal/constant_subjects.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/data/utils/user_preferences.dart';
import 'package:norm_journal/pages/calendar_page.dart';

class RegisterTeacherPage extends StatefulWidget {
  final ScheduleRepository? scheduleRepository;
  const RegisterTeacherPage({super.key, this.scheduleRepository});

  @override
  State<RegisterTeacherPage> createState() => _RegisterTeacherPageState();
}

class _RegisterTeacherPageState extends State<RegisterTeacherPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<String> _selectedSubjects = [];

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Выберите хотя бы один предмет')));
      return;
    }

    await UserPreferences.saveUser(true, "Teacher", subjects: _selectedSubjects);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => CalendarPage(
            scheduleRepository: widget.scheduleRepository!,
            changeLanguage: (l) {},
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[50],
      appBar: AppBar(title: const Text('Регистрация учителя'), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
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
                decoration: const InputDecoration(labelText: 'ФИО', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Введите ФИО' : null,
              ),
              const SizedBox(height: 20),
              const Text('Выберите ваши предметы:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: ListView.builder(
                    itemCount: ConstantSubjects.availableSubjects.length,
                    itemBuilder: (context, index) {
                      final s = ConstantSubjects.availableSubjects[index];
                      return CheckboxListTile(
                        title: Text(s),
                        value: _selectedSubjects.contains(s),
                        onChanged: (val) => setState(() => val! ? _selectedSubjects.add(s) : _selectedSubjects.remove(s)),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  onPressed: _register,
                  child: const Text('Зарегистрироваться', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}