import 'package:flutter/material.dart';
import 'package:edutrackf/config/api_config.dart';
import 'main_view.dart';
import 'student_profile_update_view.dart';
import 'student_courses_view.dart';
import 'student_pass_courses_view.dart';
import 'student_bottom_nav_bar.dart';

/// Vista para mostrar el perfil del alumno
/// Muestra toda la información del alumno autenticado
class StudentProfileView extends StatefulWidget {
  final Map<String, dynamic> studentData;
  final String token;

  const StudentProfileView({
    super.key,
    required this.studentData,
    required this.token,
  });

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  int _selectedIndex = 2; // Por defecto Perfil

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentView() {
    if (_selectedIndex == 0) {
      return StudentCoursesView(studentData: widget.studentData);
    } else if (_selectedIndex == 1) {
      return StudentPassCoursesView(studentData: widget.studentData);
    } else {
      return _buildProfileView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Eliminar el appBar de aquí
      body: _getCurrentView(),
      bottomNavigationBar: StudentBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  /// Construye una sección con título
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF07613),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  /// Construye una tarjeta de información
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool isExpandable = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFF07613),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isExpandable)
              IconButton(
                onPressed: () {
                  // TODO: Implementar expansión para mostrar token completo
                },
                icon: const Icon(Icons.visibility),
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  /// Obtiene las iniciales del nombre completo
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

  /// Formatea una fecha ISO a formato legible
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'No disponible';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  Widget _buildProfileView() {
    final studentData = widget.studentData;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Alumno'),
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
                    '${studentData['first_name'] ?? ''} ${studentData['last_name'] ?? ''}',
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
            // Información personal
            _buildSection(
              title: 'Información Personal',
              children: [
                _buildInfoCard(
                  icon: Icons.person,
                  title: 'Nombres',
                  value: (studentData['first_name'] ?? 'No disponible').toString(),
                ),
                _buildInfoCard(
                  icon: Icons.account_circle,
                  title: 'Apellidos',
                  value: (studentData['last_name'] ?? 'No disponible').toString(),
                ),
                _buildInfoCard(
                  icon: Icons.email,
                  title: 'Correo Electrónico',
                  value: (studentData['email'] ?? 'No disponible').toString(),
                ),
                _buildInfoCard(
                  icon: Icons.school,
                  title: 'Carrera Profesional',
                  value: (studentData['career'] ?? 'No disponible').toString(),
                ),
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: 'Año de Admisión',
                  value: (studentData['year_admission'] ?? 'No disponible').toString(),
                ),
                _buildInfoCard(
                  icon: Icons.phone,
                  title: 'Celular',
                  value: (studentData['phone'] ?? 'No disponible').toString(),
                )
              ],
            ),
            const SizedBox(height: 16),
            // Información de fechas
            _buildSection(
              title: 'Información de Cuenta',
              children: [
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: 'Fecha de Creación',
                  value: _formatDate(studentData['created_at']?.toString()),
                ),
                _buildInfoCard(
                  icon: Icons.update,
                  title: 'Última Actualización',
                  value: _formatDate(studentData['updated_at']?.toString()),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Navegar a la vista de edición de perfil
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentProfileUpdateView(studentData: studentData),
                        ),
                      );
                      if (updated == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perfil actualizado, recarga para ver cambios.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF07613),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Implementar cerrar sesión
                      ApiConfig.cookie = '';
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainView()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 