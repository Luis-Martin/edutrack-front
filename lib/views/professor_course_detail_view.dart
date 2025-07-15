import 'package:edutrackf/controllers/professor_controller.dart';
import 'package:flutter/material.dart';
import 'package:edutrackf/views/professor_course_students_view.dart';
import 'package:edutrackf/views/professor_course_grades_view.dart';
import 'package:edutrackf/views/professor_course_attendance_view.dart';

class ProfessorCourseDetailView extends StatefulWidget {
  final Map<String, dynamic> courseData;
  const ProfessorCourseDetailView({super.key, required this.courseData});

  @override
  State<ProfessorCourseDetailView> createState() => _ProfessorCourseDetailViewState();
}

class _ProfessorCourseDetailViewState extends State<ProfessorCourseDetailView> {
  late Future<Map<String, dynamic>> _studentFuture;
  // late Future<Map<String, dynamic>> _attendanceFuture;
  final _controller = ProfessorController();

  @override
  void initState() {
    super.initState();
    _studentFuture = _fetchStudents();
    //_attendanceFuture = _fetchAttendance();
  }

  Future<Map<String, dynamic>> _fetchStudents() async {
    final idOpenCOurse = widget.courseData['id_open_course'];
    
    if (idOpenCOurse == null) {
      return {
        'status': 400,
        'content': {'error': 'ID de curso aperturado'},
      };
    }
    return await _controller.listEnrrollStudents(idOpenCOurse);
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.courseData['course'] ?? {};
    final openCourse = widget.courseData;
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
                    _infoRow('Año académico', openCourse['academic_year']?.toString()),
                    _infoRow('Semestre', openCourse['academic_semester']?.toString()),
                    _infoRow('Sección', openCourse['section']),
                    _infoRow('Carrera profesional', openCourse['professional_career']),
                    _infoRow('Fecha inicio', openCourse['start_class']),
                    _infoRow('Fecha fin', openCourse['end_class']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Notas
            Text(
              'Lista de alumnos matriculados:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF07613)),
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>>(
              future: _studentFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      height: 80,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      height: 80,
                      alignment: Alignment.center,
                      child: Text(
                        'Error al cargar alumnos: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final result = snapshot.data!;
                  if (result['status'] == 200 && result['content'] is List) {
                    final students = result['content'] as List;
                    if (students.isNotEmpty) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: students.length,
                        separatorBuilder: (context, i) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _buildStudentCard(students[i]),
                      );
                    } else {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          height: 80,
                          alignment: Alignment.center,
                          child: const Text('No hay alumnos matriculados.'),
                        ),
                      );
                    }
                  } else {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        width: double.infinity,
                        height: 80,
                        alignment: Alignment.center,
                        child: Text(
                          'Error: ${result['content']?['error'] ?? 'Error desconocido'}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                } else {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      height: 80,
                      alignment: Alignment.center,
                      child: const Text('Sin información de alumnos.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            // Botón para agregar alumno
            Builder(
              builder: (context) {
                final idOpenCourse = widget.courseData['id_open_course'];
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Gestion de Alumnos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF07613),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      // Obtener la lista de alumnos actuales
                      final studentsResult = await _studentFuture;
                      final students = (studentsResult['status'] == 200 && studentsResult['content'] is List)
                          ? studentsResult['content'] as List
                          : <dynamic>[];
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfessorCourseStudentsView(
                            courseData: widget.courseData,
                            students: students,
                          ),
                        ),
                      );
                      // Si se agregó un alumno, refresca la lista
                      if (result == true) {
                        setState(() {
                          _studentFuture = _fetchStudents();
                        });
                      }
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Botón para ir a la vista de notas
            FutureBuilder<Map<String, dynamic>>(
              future: _studentFuture,
              builder: (context, snapshot) {
                final students = (snapshot.hasData && snapshot.data!['status'] == 200 && snapshot.data!['content'] is List)
                  ? snapshot.data!['content'] as List
                  : <dynamic>[];
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.grade),
                    label: const Text('Gestionar Notas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF07613),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: students.isEmpty ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfessorCourseGradesView(
                            courseData: widget.courseData,
                            students: students,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Botón para ir a la vista de asistencias
            FutureBuilder<Map<String, dynamic>>(
              future: _studentFuture,
              builder: (context, snapshot) {
                final students = (snapshot.hasData && snapshot.data!['status'] == 200 && snapshot.data!['content'] is List)
                  ? snapshot.data!['content'] as List
                  : <dynamic>[];
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.event_available),
                    label: const Text('Gestionar Asistencias'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF07613),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: students.isEmpty ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfessorCourseAttendanceView(
                            courseData: widget.courseData,
                            students: students,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
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

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final user = student['student'] ?? student;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.person, color: Color(0xFFF07613), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (user['first_name'] ?? '-') + ' ' + (user['last_name'] ?? '-'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(user['email'] ?? '-', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
