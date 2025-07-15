import 'package:flutter/material.dart';
import '../controllers/professor_controller.dart';

class ProfessorCourseStudentsView extends StatefulWidget {
  final Map<String, dynamic> courseData;
  final List<dynamic> students;
  const ProfessorCourseStudentsView({super.key, required this.courseData, required this.students});

  @override
  State<ProfessorCourseStudentsView> createState() => _ProfessorCourseStudentsViewState();
}

class _ProfessorCourseStudentsViewState extends State<ProfessorCourseStudentsView> {
  final _controller = ProfessorController();

  List<dynamic> _notEnrolledStudents = [];
  int? _selectedStudentId;
  bool _loadingNoEnrolled = false;
  bool _addingStudent = false;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotEnrolledStudents();
  }

  Future<void> _fetchNotEnrolledStudents() async {
    setState(() { _loadingNoEnrolled = true; });
    final idOpenCourse = widget.courseData['id_open_course'];
    final result = await _controller.listNoEnrrollStudents(idOpenCourse);
    if (result['status'] == 200 && result['content'] is List) {
      setState(() {
        _notEnrolledStudents = result['content'];
        _loadingNoEnrolled = false;
      });
    } else {
      setState(() {
        _notEnrolledStudents = [];
        _loadingNoEnrolled = false;
      });
    }
  }

  Future<void> _handleAddStudent() async {
    if (_selectedStudentId == null) return;
    setState(() { _addingStudent = true; });
    final idOpenCourse = widget.courseData['id_open_course'];
    final result = await _controller.enrrollStudent(idOpenCourse, _selectedStudentId);
    if (result['status'] == 201) {
      // Limpiar selección antes de regresar
      setState(() { _selectedStudentId = null; });
      if (mounted) Navigator.pop(context, true);
    }
    setState(() { _addingStudent = false; });
  }

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
          children: [
            const Text(
              'Gestión de Alumnos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF07613)),
            ),
            const SizedBox(height: 12),
            // Input select con alumnos no matriculados
            _loadingNoEnrolled
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar alumno a agregar',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedStudentId,
                    items: _notEnrolledStudents.map<DropdownMenuItem<int>>((student) {
                      final name = (student['first_name'] ?? '-') + ' ' + (student['last_name'] ?? '-');
                      return DropdownMenuItem<int>(
                        value: student['id_student'],
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() { _selectedStudentId = value; });
                    },
                  ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: _addingStudent ? const Text('Agregando...') : const Text('Agregar alumno'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF07613),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _addingStudent || _selectedStudentId == null ? null : _handleAddStudent,
              ),
            ),
            if (_feedbackMessage != null) ...[
              const SizedBox(height: 8),
              Text(_feedbackMessage!, style: TextStyle(color: _feedbackMessage!.contains('Error') ? Colors.red : Colors.green)),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: widget.students.isNotEmpty
                  ? ListView.separated(
                      itemCount: widget.students.length,
                      separatorBuilder: (context, i) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _buildStudentCard(widget.students[i]),
                    )
                  : const Center(child: Text('No hay alumnos inscritos.')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final user = student['student'] ?? student; // por si viene anidado
    final int? idStudent = user['id_student'];
    final int? idOpenCourse = widget.courseData['id_open_course'];
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
            // Botón eliminar
            if (idStudent != null && idOpenCourse != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Eliminar alumno',
                onPressed: () async {
                  final result = await _controller.deleteEnrrollStudent(idOpenCourse, idStudent);
                  if (result['status'] == 200 || result['status'] == 201) {
                    if (mounted) Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al eliminar alumno.')),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
} 