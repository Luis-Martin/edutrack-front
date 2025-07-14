import 'package:flutter/material.dart';

class ProfessorCourseAttendanceView extends StatelessWidget {
  final Map<String, dynamic> courseData;
  const ProfessorCourseAttendanceView({super.key, required this.courseData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colocar Asistencia'),
        backgroundColor: const Color(0xFFF07613),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Gestión de Asistencia',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF07613)),
            ),
            SizedBox(height: 12),
            Text('Aquí podrás registrar la asistencia de los alumnos para este curso.'),
          ],
        ),
      ),
    );
  }
} 