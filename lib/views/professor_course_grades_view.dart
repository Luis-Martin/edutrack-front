import 'package:flutter/material.dart';

class ProfessorCourseGradesView extends StatelessWidget {
  final Map<String, dynamic> courseData;
  const ProfessorCourseGradesView({super.key, required this.courseData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colocar Notas'),
        backgroundColor: const Color(0xFFF07613),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Gestión de Notas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF07613)),
            ),
            SizedBox(height: 12),
            Text('Aquí podrás registrar y modificar las notas de los alumnos para este curso.'),
          ],
        ),
      ),
    );
  }
} 