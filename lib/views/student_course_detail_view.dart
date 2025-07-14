import 'package:flutter/material.dart';
import '../controllers/student_controller.dart';

class StudentCourseDetailView extends StatefulWidget {
  final Map<String, dynamic> courseData;
  const StudentCourseDetailView({super.key, required this.courseData});

  @override
  State<StudentCourseDetailView> createState() => _StudentCourseDetailViewState();
}

class _StudentCourseDetailViewState extends State<StudentCourseDetailView> {
  late Future<Map<String, dynamic>> _notesFuture;
  late Future<Map<String, dynamic>> _attendanceFuture;
  final _controller = StudentController();

  @override
  void initState() {
    super.initState();
    _notesFuture = _fetchNotes();
    _attendanceFuture = _fetchAttendance();
  }

  Future<Map<String, dynamic>> _fetchNotes() async {
    final idEnrollStudent = widget.courseData['id_enroll_student'];
    
    if (idEnrollStudent == null) {
      return {
        'status': 400,
        'content': {'error': 'ID de matrícula no disponible'},
      };
    }

    return await _controller.listNotesCourse(idEnrollStudent);
  }

  Future<Map<String, dynamic>> _fetchAttendance() async {
    final idEnrollStudent = widget.courseData['id_enroll_student'];
    
    if (idEnrollStudent == null) {
      return {
        'status': 400,
        'content': {'error': 'ID de matrícula no disponible'},
      };
    }

    return await _controller.listAttendanceCourse(idEnrollStudent);
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.courseData['course'] ?? {};
    final openCourse = widget.courseData['open_course'] ?? {};
    final professor = widget.courseData['professor'] ?? {};
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
                    _infoRow('Año académico', widget.courseData['academic_year']?.toString()),
                    _infoRow('Semestre', widget.courseData['academic_semester']?.toString()),
                    _infoRow('Sección', widget.courseData['section']),
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
            FutureBuilder<Map<String, dynamic>>(
              future: _notesFuture,
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
                        'Error al cargar notas: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final result = snapshot.data!;
                  if (result['status'] == 200 && result['content'] is List) {
                    final notes = result['content'] as List;
                    if (notes.isNotEmpty) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: notes.map((note) => _buildNoteItem(note)).toList(),
                          ),
                        ),
                      );
                    } else {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          height: 80,
                          alignment: Alignment.center,
                          child: const Text('No hay notas registradas.'),
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
                      child: const Text('Sin información de notas.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            // Asistencias
            Text(
              'Asistencias',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF07613)),
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>>(
              future: _attendanceFuture,
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
                        'Error al cargar asistencias: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final result = snapshot.data!;
                  if (result['status'] == 200 && result['content'] is List) {
                    final attendance = result['content'] as List;
                    if (attendance.isNotEmpty) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: attendance.map((attendanceItem) => _buildAttendanceItem(attendanceItem)).toList(),
                          ),
                        ),
                      );
                    } else {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          height: 80,
                          alignment: Alignment.center,
                          child: const Text('No hay asistencias registradas.'),
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
                      child: const Text('Sin información de asistencias.'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(Map<String, dynamic> note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note['type_note'] ?? 'Sin tipo',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fecha: ${_formatDate(note['created_at'])}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getNoteColor(note['note']),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${note['note']}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(Map<String, dynamic> attendanceItem) {
    final attendance = attendanceItem['attendance'];
    String status;
    Color color;

    // 0 = presente, 1 = ausente, 2 = tardanza
    switch (attendance) {
      case 0:
        status = 'Presente';
        color = Colors.green;
        break;
      case 1:
        status = 'Ausente';
        color = Colors.red;
        break;
      case 2:
        status = 'Tardanza';
        color = Colors.orange;
        break;
      default:
        status = 'Desconocido';
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(attendanceItem['date']),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Clase del ${_formatDate(attendanceItem['date'])}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNoteColor(dynamic noteValue) {
    if (noteValue == null) return Colors.grey;
    
    final note = double.tryParse(noteValue.toString()) ?? 0;
    if (note >= 13) {
      return Colors.green;
    } else if (note >= 10) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getAttendanceColor(bool isPresent) {
    return isPresent ? Colors.green : Colors.red;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Sin fecha';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
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