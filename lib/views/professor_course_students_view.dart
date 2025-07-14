import 'package:flutter/material.dart';

class ProfessorCourseStudentsView extends StatelessWidget {
  final Map<String, dynamic> courseData;
  const ProfessorCourseStudentsView({super.key, required this.courseData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumnos del Curso'),
        backgroundColor: const Color(0xFFF07613),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Listado y gestión de alumnos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF07613)),
            ),
            SizedBox(height: 12),
            Text('Aquí podrás ver la lista de alumnos inscritos en el curso y agregar nuevos alumnos.'),
          ],
        ),
      ),
    );
  }
} 