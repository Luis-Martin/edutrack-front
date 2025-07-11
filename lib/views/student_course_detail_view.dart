import 'package:flutter/material.dart';

class StudentCourseDetailView extends StatelessWidget {
  final Map<String, dynamic> courseData;
  const StudentCourseDetailView({super.key, required this.courseData});

  @override
  Widget build(BuildContext context) {
    final course = courseData['course'] ?? {};
    final openCourse = courseData['open_course'] ?? {};
    final professor = courseData['professor'] ?? {};
    return Scaffold(
      appBar: AppBar(
        title: Text(course['name'] ?? 'Detalle del Curso'),
        backgroundColor: const Color(0xFFF07613),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información General
            Text(
              'Información General',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF07613)),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Nombre del curso', course['name']),
                    _infoRow('Código', course['subject_code']?.toString()),
                    _infoRow('Ciclo', course['study_cycle']?.toString()),
                    _infoRow('Créditos', course['credits']?.toString()),
                    _infoRow('Duración (semanas)', course['duration_weeks']?.toString()),
                    _infoRow('Horas teoría', course['theory_hours']?.toString()),
                    _infoRow('Horas práctica', course['practice_hours']?.toString()),
                    _infoRow('Plan de estudios', course['study_plan']?.toString()),
                    _infoRow('Año académico', courseData['academic_year']?.toString()),
                    _infoRow('Semestre', courseData['academic_semester']?.toString()),
                    _infoRow('Sección', courseData['section']),
                    _infoRow('Carrera profesional', openCourse['professional_career']),
                    _infoRow('Profesor', (professor['first_name'] ?? '') + ' ' + (professor['last_name'] ?? '')),
                    _infoRow('Email profesor', professor['email']),
                    _infoRow('Fecha inicio', openCourse['start_class']),
                    _infoRow('Fecha fin', openCourse['end_class']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Notas
            Text(
              'Notas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF07613)),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity,
                height: 80,
                alignment: Alignment.center,
                child: const Text('Sin información de notas.'),
              ),
            ),
            const SizedBox(height: 24),
            // Asistencias
            Text(
              'Asistencias',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF07613)),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity,
                height: 80,
                alignment: Alignment.center,
                child: const Text('Sin información de asistencias.'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value ?? '-', style: const TextStyle()),
          ),
        ],
      ),
    );
  }
} 