import 'package:flutter/material.dart';
import '../controllers/professor_controller.dart';
import 'professor_course_detail_view.dart';
import 'professor_create_course_view.dart';

class ProfessorCoursesView extends StatefulWidget {
  final Map<String, dynamic> professorData;
  const ProfessorCoursesView({super.key, required this.professorData});

  @override
  State<ProfessorCoursesView> createState() => _ProfessorCoursesViewState();
}

class _ProfessorCoursesViewState extends State<ProfessorCoursesView> {
  late Future<List<dynamic>> _coursesFuture;
  final _controller = ProfessorController();

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchCourses();
  }

  Future<List<dynamic>> _fetchCourses() async {
    final result = await _controller.listProfessorOpenCourses();
    if (result['status'] == 200 && result['content'] is List) {
      return result['content'];
    } else {
      throw Exception(result['content']['error'] ?? 'Error al cargar cursos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cursos'),
        backgroundColor: const Color(0xFFF07613),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            const Text(
              'Cursos Asignados',
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
                    child: Text('No hay cursos asignados.'),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            // Créa el botón aquí
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF07613),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.add),
                label: Text('Aperturar curso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfessorCreateCourseView(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            '${widget.professorData['first_name'] ?? ''} ${widget.professorData['last_name'] ?? ''}',
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
              'Profesor',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final courseName = course['course']?['name'] ?? 'Curso';
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
                const Icon(Icons.book, color: Color(0xFFF07613), size: 32),
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
                )
              ],
            ),
            const SizedBox(height: 10),
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
                    minimumSize: const Size(0, 36),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfessorCourseDetailView(courseData: course),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Detalle', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    final firstName = (widget.professorData['first_name'] ?? '').toString();
    final lastName = (widget.professorData['last_name'] ?? '').toString();
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    return initials.isEmpty ? 'P' : initials;
  }
} 