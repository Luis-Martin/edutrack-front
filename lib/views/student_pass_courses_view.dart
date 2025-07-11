import 'package:flutter/material.dart';
import '../controllers/student_controller.dart';
import 'student_course_detail_view.dart';

class StudentPassCoursesView extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const StudentPassCoursesView({super.key, required this.studentData});

  @override
  State<StudentPassCoursesView> createState() => _StudentPassCoursesViewState();
}

class _StudentPassCoursesViewState extends State<StudentPassCoursesView> {
  late Future<List<dynamic>> _coursesFuture;
  final _controller = StudentController();

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchCourses();
  }

  Future<List<dynamic>> _fetchCourses() async {
    final result = await _controller.listStudentEnrollsPassCourses();
    if (result['status'] == 200 && result['content'] is List) {
      return result['content'];
    } else {
      throw Exception(result['content']['error'] ?? 'Error al cargar cursos');
    }
  }

  String _getInitials() {
    final firstName = (widget.studentData['first_name'] ?? '').toString();
    final lastName = (widget.studentData['last_name'] ?? '').toString();
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    return initials.isEmpty ? 'A' : initials;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: const Color(0xFFF07613),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con avatar y nombre
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF07613), Color(0xFFE65A00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      _getInitials(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF07613),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.studentData['first_name'] ?? ''} ${widget.studentData['last_name'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Alumno - Pregrado',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cursos Pasados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF07613),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar cursos: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final courses = snapshot.data!;
                  return Column(
                    children: courses.map((course) => _buildCourseCard(course)).toList(),
                  );
                } else {
                  return const Center(
                    child: Text('No tienes cursos matriculados.'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final courseName = course['course']?['name'] ?? 'Curso';
    final professor = course['professor'];
    final professorName = professor != null
        ? ((professor['first_name'] ?? '') + ' ' + (professor['last_name'] ?? '')).trim()
        : 'Profesor';
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.book_outlined, color: Color(0xFFF07613), size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    courseName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF07613),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    professorName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Año: ${course['academic_year'] ?? '-'}',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.school, color: Colors.grey, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Semestre: ${course['academic_semester'] ?? '-'}',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.group, color: Colors.grey, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Sección: ${course['section'] ?? '-'}',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(width: 18),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF07613),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size(0, 36),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentCourseDetailView(courseData: course),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Ver detalle', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 