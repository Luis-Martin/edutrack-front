import 'package:flutter/material.dart';
import '../controllers/professor_controller.dart';

class ProfessorCourseAttendanceView extends StatefulWidget {
  final Map<String, dynamic> courseData;
  final List<dynamic> students;
  const ProfessorCourseAttendanceView({super.key, required this.courseData, required this.students});

  @override
  State<ProfessorCourseAttendanceView> createState() => _ProfessorCourseAttendanceViewState();
}

class _ProfessorCourseAttendanceViewState extends State<ProfessorCourseAttendanceView> {
  late Future<List<dynamic>> _attendanceFuture;
  final _controller = ProfessorController();

  DateTime? _selectedDate;
  List<int> _selectedEnrollIds = [];
  int _attendanceType = 0; // 0: asistencia, 1: falta
  bool _submitting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = _fetchAttendance();
  }

  Future<List<dynamic>> _fetchAttendance() async {
    final idOpenCourse = widget.courseData['id_open_course'];
    final result = await _controller.listAttendanceStudents(idOpenCourse);
    if (result['status'] == 200 && result['content'] is List) {
      return result['content'];
    } else {
      return [];
    }
  }

  Future<void> _handleSubmitAttendance() async {
    setState(() { _formError = null; });
    if (_selectedDate == null || _selectedEnrollIds.isEmpty) {
      setState(() { _formError = 'Selecciona la fecha y al menos un alumno.'; });
      return;
    }
    setState(() { _submitting = true; });

    // Mandar todos los idEnroll como un array al controlador
    final result = await _controller.attendanceStudents(
      _selectedDate!.toIso8601String().substring(0, 10),
      _selectedEnrollIds,
      _attendanceType,
    );

    setState(() { _submitting = false; });
    if ((result['status'] == 201 || result['status'] == 200) && mounted) {
      Navigator.pop(context, true);
    } else {
      setState(() { _formError = 'Error al registrar alguna asistencia.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Asistencia'),
        backgroundColor: const Color(0xFFF07613),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de Asistencia',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF07613)),
            ),
            const SizedBox(height: 12),
            // Input para seleccionar la fecha
            Row(
              children: [
                const Text('Fecha:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() { _selectedDate = picked; });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                            : 'Seleccionar fecha',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Multi-select alumnos
            const Text('Seleccionar alumnos:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.students.map<Widget>((student) {
                final user = student['student'] ?? student;
                final idEnroll = student['id_enroll_student'] ?? student['id_enroll_student'];
                final name = (user['first_name'] ?? '-') + ' ' + (user['last_name'] ?? '-');
                final selected = _selectedEnrollIds.contains(idEnroll);
                return FilterChip(
                  label: Text(name),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedEnrollIds.add(idEnroll);
                      } else {
                        _selectedEnrollIds.remove(idEnroll);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Tipo de asistencia
            Row(
              children: [
                const Text('Tipo:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _attendanceType,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Asistencia')),
                    DropdownMenuItem(value: 1, child: Text('Falta')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() { _attendanceType = val; });
                  },
                ),
              ],
            ),
            if (_formError != null) ...[
              const SizedBox(height: 8),
              Text(_formError!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _submitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                label: Text(_submitting ? 'Guardando...' : 'Registrar Asistencia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF07613),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitting ? null : _handleSubmitAttendance,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _attendanceFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar asistencias.'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final studentsAttendance = snapshot.data!;
                    return ListView.separated(
                      itemCount: studentsAttendance.length,
                      separatorBuilder: (context, i) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _buildStudentCard(studentsAttendance[i]),
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
    final user = enroll['student'] ?? {};
    final attendanceList = enroll['attendance'] as List? ?? [];
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
            if (attendanceList.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Asistencias:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  ...attendanceList.map<Widget>((att) => _buildAttendanceRow(att)).toList(),
                ],
              )
            else
              const Text('Sin asistencias registradas.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRow(Map<String, dynamic> att) {
    String status;
    Color color;
    switch (att['attendance']) {
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
    return Row(
      children: [
        const Icon(Icons.event, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(att['date'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
} 