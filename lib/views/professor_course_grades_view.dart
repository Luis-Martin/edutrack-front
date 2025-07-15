import 'package:edutrackf/views/professor_course_detail_view.dart';
import 'package:flutter/material.dart';
import '../controllers/professor_controller.dart';

class ProfessorCourseGradesView extends StatefulWidget {
  final Map<String, dynamic> courseData;
  const ProfessorCourseGradesView({super.key, required this.courseData, required this.students});
  final List<dynamic> students; // No se usará, pero se mantiene por compatibilidad

  @override
  State<ProfessorCourseGradesView> createState() => _ProfessorCourseGradesViewState();
}

class _ProfessorCourseGradesViewState extends State<ProfessorCourseGradesView> {
  late Future<List<dynamic>> _notesFuture;
  final _controller = ProfessorController();

  List<dynamic> _students = [];
  int? _selectedEnrollId;
  String? _selectedTypeNote;
  String _noteValue = '';
  bool _addingNote = false;
  String? _formError;

  final List<String> _noteTypes = [
    'Evaluación Parcial',
    'Evaluación Final',
    'Trabajos Académicos',
  ];

  @override
  void initState() {
    super.initState();
    _notesFuture = _fetchNotes();
  }

  Future<List<dynamic>> _fetchNotes() async {
    final idOpenCourse = widget.courseData['id_open_course'];
    final result = await _controller.listNotesStudents(idOpenCourse);
    if (result['status'] == 200 && result['content'] is List) {
      // Extraer alumnos para el select
      _students = result['content'];
      return result['content'];
    } else {
      _students = [];
      return [];
    }
  }

  Future<void> _handleAddNote() async {
    setState(() { _formError = null; });
    if (_selectedEnrollId == null || _selectedTypeNote == null || _noteValue.isEmpty) {
      setState(() { _formError = 'Completa todos los campos.'; });
      return;
    }
    final noteNum = double.tryParse(_noteValue.replaceAll(',', '.'));
    if (noteNum == null || noteNum < 0 || noteNum > 20) {
      setState(() { _formError = 'La nota debe ser un número entre 0 y 20.'; });
      return;
    }
    setState(() { _addingNote = true; });
    final result = await _controller.noteStudent(_selectedEnrollId, _selectedTypeNote, noteNum);
    setState(() { _addingNote = false; });
    if (result['status'] == 201 || result['status'] == 200) {
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() { _formError = 'Error al registrar la nota.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Notas'),
        backgroundColor: const Color(0xFFF07613),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de Notas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF07613)),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<dynamic>>(
              future: _notesFuture,
              builder: (context, snapshot) {
                final students = (snapshot.hasData && snapshot.data != null)
                    ? snapshot.data!
                    : <dynamic>[];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Select alumno
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Seleccionar alumno',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedEnrollId,
                      items: students.map<DropdownMenuItem<int>>((enroll) {
                        final user = enroll['studnet'] ?? enroll['student'] ?? {};
                        final name = (user['first_name'] ?? '-') + ' ' + (user['last_name'] ?? '-');
                        return DropdownMenuItem<int>(
                          value: enroll['id_enroll_student'],
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() { _selectedEnrollId = value; });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Select tipo de nota
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de nota',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedTypeNote,
                      items: _noteTypes.map((type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      )).toList(),
                      onChanged: (value) {
                        setState(() { _selectedTypeNote = value; });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Input nota
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nota (0-20)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() { _noteValue = value; });
                      },
                    ),
                    if (_formError != null) ...[
                      const SizedBox(height: 8),
                      Text(_formError!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _addingNote
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save),
                        label: Text(_addingNote ? 'Guardando...' : 'Colocar Nota'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF07613),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _addingNote ? null : _handleAddNote,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _notesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar notas.'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final studentsNotes = snapshot.data!;
                    return ListView.separated(
                      itemCount: studentsNotes.length,
                      separatorBuilder: (context, i) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _buildStudentCard(studentsNotes[i]),
                    );
                  } else {
                    return const Center(child: Text('No hay alumnos inscritos.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> enroll) {
    final user = enroll['studnet'] ?? enroll['student'] ?? {};
    final notes = enroll['notes'] as List? ?? [];

    // Helper to get note object by type
    Map<String, dynamic>? getNoteObj(String type) {
      return notes.firstWhere(
        (n) => n['type_note'] == type,
        orElse: () => null,
      );
    }

    String getNoteValue(String type) {
      final note = getNoteObj(type);
      return note != null ? (note['note']?.toString() ?? '-') : '-';
    }

    int? getNoteId(String type) {
      final note = getNoteObj(type);
      return note != null ? note['id_note'] : null;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            const SizedBox(height: 12),
            // Notas en vertical con botón de borrar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _noteColumnWithDelete(
                  'Evaluación Parcial',
                  getNoteValue('Evaluación Parcial'),
                  getNoteId('Evaluación Parcial'),
                ),
                const SizedBox(height: 8),
                _noteColumnWithDelete(
                  'Evaluación Final',
                  getNoteValue('Evaluación Final'),
                  getNoteId('Evaluación Final'),
                ),
                const SizedBox(height: 8),
                _noteColumnWithDelete(
                  'Trabajos Académicos',
                  getNoteValue('Trabajos Académicos'),
                  getNoteId('Trabajos Académicos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _noteColumnWithDelete(String label, String value, int? idNote) {
    double? noteValue = double.tryParse(value.replaceAll(',', '.'));
    Color noteColor;
    if (noteValue != null) {
      noteColor = noteValue > 10 ? Colors.green : Colors.red;
    } else {
      noteColor = Colors.grey;
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: noteColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        if (idNote != null)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            tooltip: 'Borrar nota',
            onPressed: () async {
              // Llama a la función deleteNoteStudent del controlador
              // Asume que tienes acceso a _controller y setState/context
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirmar'),
                  content: const Text('¿Estás seguro de que deseas borrar esta nota?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Borrar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _controller.deleteNoteStudent(idNote);
                // Redirige a la vista de detalle del curso después de borrar la nota
                if (mounted) {
                  // Importa la vista si no está importada ya:
                  // import 'package:edutrackf/views/professor_course_detail_view.dart';
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => ProfessorCourseDetailView(
                        courseData: widget.courseData,
                      ),
                    ),
                    (route) => route.isFirst,
                  );
                }
              }
            },
          ),
      ],
    );
  }
} 