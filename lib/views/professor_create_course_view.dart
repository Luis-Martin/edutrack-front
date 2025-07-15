import 'package:flutter/material.dart';
import '../controllers/professor_controller.dart';
import 'professor_courses_view.dart';

class ProfessorCreateCourseView extends StatefulWidget {
  const ProfessorCreateCourseView({super.key});

  @override
  State<ProfessorCreateCourseView> createState() => _ProfessorCreateCourseViewState();
}

class _ProfessorCreateCourseViewState extends State<ProfessorCreateCourseView> {
  final _formKey = GlobalKey<FormState>();
  final ProfessorController _controller = ProfessorController();

  int? _selectedCourseId;
  String? _startClass;
  String? _endClass;
  int? _academicYear;
  int? _academicSemester;
  String? _professionalCareer;
  // Solo un horario

  // Controllers para fechas
  final TextEditingController _startClassController = TextEditingController();
  final TextEditingController _endClassController = TextEditingController();

  // Campos para schedule temporal
  int? _scheduleDayWeek;
  TimeOfDay? _scheduleStartHour;
  TimeOfDay? _scheduleEndHour;

  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _startClassController.dispose();
    _endClassController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetchCourses() async {
    final result = await _controller.listAllCourses();
    if ((result['status'] == 200 || result['status'] == 201) && result['content'] is List) {
      return result['content'];
    } else if (result['content'] is List) {
      // Si el backend retorna lista pero status inesperado, igual la muestro
      return result['content'];
    } else {
      throw Exception(result['content']['error'] ?? 'Error al cargar cursos');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedCourseId == null || _scheduleDayWeek == null || _scheduleStartHour == null || _scheduleEndHour == null) {
      if (_selectedCourseId == null) {
        print('Error: No se seleccionó un curso');
      }
      if (_scheduleDayWeek == null || _scheduleStartHour == null || _scheduleEndHour == null) {
        print('Error: No se completó el horario');
      }
      if (!_formKey.currentState!.validate()) {
        print('Error: El formulario no es válido');
      }
      setState(() {
        _submitError = 'Complete todos los campos y el horario.';
      });
      return;
    }
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    // Construir el horario como array con un solo objeto
    final schedule = [
      {
        'day_week': (_scheduleDayWeek is String) ? int.tryParse(_scheduleDayWeek as String) : _scheduleDayWeek,
        'start_hour': _scheduleStartHour!.format(context).padLeft(5, '0') + ':00'.substring(_scheduleStartHour!.format(context).length == 5 ? 0 : 3),
        'end_hour': _scheduleEndHour!.format(context).padLeft(5, '0') + ':00'.substring(_scheduleEndHour!.format(context).length == 5 ? 0 : 3),
      }
    ];
    print('Datos a enviar a openCourses:');
    print({
      'id_course': _selectedCourseId,
      'start_class': _startClass,
      'end_class': _endClass,
      'academic_year': _academicYear,
      'academic_semester': _academicSemester,
      'professional_career': _professionalCareer,
      'schedule': schedule,
    });
    try {
      final result = await _controller.openCourses(
        _selectedCourseId,
        _startClass,
        _endClass,
        _academicYear,
        _academicSemester,
        _professionalCareer,
        schedule,
      );
      print('Respuesta de openCourses: $result');
      if (result['status'] == 200) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ProfessorCoursesView(professorData: const {}),
            ),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _submitError = result['content']['error']?.toString() ?? 'Error desconocido';
        });
      }
    } catch (e) {
      print('Error en openCourses: $e');
      setState(() {
        _submitError = e.toString();
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aperturar Curso'),
        backgroundColor: const Color(0xFFF07613),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<dynamic>>(
                future: _fetchCourses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('No se pudo cargar la lista de cursos.', style: TextStyle(color: Colors.red)),
                        Text(snapshot.error.toString(), style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    );
                  } else if (snapshot.hasData) {
                    final courses = snapshot.data!;
                    if (courses.isEmpty) {
                      return const Text('No hay cursos disponibles para seleccionar.', style: TextStyle(color: Colors.orange));
                    }
                    return DropdownButtonFormField<dynamic>(
                      decoration: const InputDecoration(labelText: 'Curso'),
                      value: _selectedCourseId,
                      items: courses.map<DropdownMenuItem<dynamic>>((course) {
                        return DropdownMenuItem<dynamic>(
                          value: course['id_course'],
                          child: Text(course['name'] ?? 'Curso'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          if (value is int) {
                            _selectedCourseId = value;
                          } else if (value is String) {
                            _selectedCourseId = int.tryParse(value);
                          } else {
                            _selectedCourseId = null;
                          }
                        });
                      },
                      validator: (value) => value == null ? 'Seleccione un curso' : null,
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startClassController,
                decoration: const InputDecoration(labelText: 'Fecha de inicio (YYYY-MM-DD)'),
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _startClassController.text = picked.toIso8601String().split('T')[0];
                    _startClass = _startClassController.text;
                  }
                },
                validator: (value) => value == null || value.isEmpty ? 'Seleccione la fecha de inicio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endClassController,
                decoration: const InputDecoration(labelText: 'Fecha de fin (YYYY-MM-DD)'),
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _endClassController.text = picked.toIso8601String().split('T')[0];
                    _endClass = _endClassController.text;
                  }
                },
                validator: (value) => value == null || value.isEmpty ? 'Seleccione la fecha de fin' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<dynamic>(
                decoration: const InputDecoration(labelText: 'Año académico'),
                value: _academicYear,
                items: [2024, 2025].map((year) => DropdownMenuItem<dynamic>(
                  value: year,
                  child: Text(year.toString()),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value is int) {
                      _academicYear = value;
                    } else if (value is String) {
                      _academicYear = int.tryParse(value);
                    } else {
                      _academicYear = null;
                    }
                  });
                },
                validator: (value) => value == null ? 'Seleccione el año académico' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<dynamic>(
                decoration: const InputDecoration(labelText: 'Semestre académico'),
                value: _academicSemester,
                items: [1, 2].map((sem) => DropdownMenuItem<dynamic>(
                  value: sem,
                  child: Text(sem.toString()),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value is int) {
                      _academicSemester = value;
                    } else if (value is String) {
                      _academicSemester = int.tryParse(value);
                    } else {
                      _academicSemester = null;
                    }
                  });
                },
                validator: (value) => value == null ? 'Seleccione el semestre académico' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Carrera profesional'),
                value: _professionalCareer,
                items: [
                  'Ingeniería Informática',
                  'Ingeniería de Telecomunicaciones',
                  'Ingeniería Electrónica',
                  'Ingeniería Mecatrónica',
                ].map((career) => DropdownMenuItem<String>(
                  value: career,
                  child: Text(career),
                )).toList(),
                onChanged: (value) => setState(() => _professionalCareer = value),
                validator: (value) => value == null ? 'Seleccione la carrera profesional' : null,
              ),
              const SizedBox(height: 24),
              const Text('Horario', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<dynamic>(
                decoration: const InputDecoration(labelText: 'Día de la semana'),
                value: _scheduleDayWeek,
                items: [
                  {'label': 'Lunes', 'value': 1},
                  {'label': 'Martes', 'value': 2},
                  {'label': 'Miércoles', 'value': 3},
                  {'label': 'Jueves', 'value': 4},
                  {'label': 'Viernes', 'value': 5},
                  {'label': 'Sábado', 'value': 6},
                  {'label': 'Domingo', 'value': 7},
                ].map((day) => DropdownMenuItem<dynamic>(
                  value: day['value'],
                  child: Text(day['label'] as String),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value is int) {
                      _scheduleDayWeek = value;
                    } else if (value is String) {
                      _scheduleDayWeek = int.tryParse(value);
                    } else {
                      _scheduleDayWeek = null;
                    }
                  });
                },
                validator: (value) => value == null ? 'Seleccione el día de la semana' : null,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: 18, minute: 0),
                  );
                  if (picked != null) {
                    setState(() => _scheduleStartHour = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Hora inicio'),
                  child: Text(_scheduleStartHour?.format(context) ?? '--:--'),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: 20, minute: 0),
                  );
                  if (picked != null) {
                    setState(() => _scheduleEndHour = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Hora fin'),
                  child: Text(_scheduleEndHour?.format(context) ?? '--:--'),
                ),
              ),
              const SizedBox(height: 24),
              if (_submitError != null)
                Text(_submitError!, style: const TextStyle(color: Colors.red)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF07613),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Aperturar curso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 