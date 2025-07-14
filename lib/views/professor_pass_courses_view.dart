import 'package:flutter/material.dart';

class ProfessorPassCoursesView extends StatefulWidget {
  final Map<String, dynamic> professorData;
  const ProfessorPassCoursesView({super.key, required this.professorData});

  @override
  State<ProfessorPassCoursesView> createState() => _ProfessorPassCoursesViewState();
}

class _ProfessorPassCoursesViewState extends State<ProfessorPassCoursesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Cursos (Profesor)'),
        backgroundColor: const Color(0xFFF07613),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            // Aquí iría la lista de cursos pasados del profesor
            const Center(
              child: Text('No hay cursos pasados (placeholder).'),
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