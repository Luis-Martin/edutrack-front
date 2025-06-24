import 'package:flutter/material.dart';

/// Vista para mostrar el perfil del alumno
/// Muestra toda la información del alumno autenticado
class StudentProfileView extends StatelessWidget {
  final Map<String, dynamic> studentData;
  final String token;

  const StudentProfileView({
    super.key,
    required this.studentData,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
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
                  // Avatar circular
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
                  // Nombre completo
                  Text(
                    '${studentData['first_name']} ${studentData['last_name']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Rol
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Alumno',
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
                  icon: Icons.email,
                  title: 'Correo Electrónico',
                  value: studentData['email'] ?? 'No disponible',
                ),
                _buildInfoCard(
                  icon: Icons.phone,
                  title: 'Celular',
                  value: studentData['phone'] ?? 'No disponible',
                ),
                _buildInfoCard(
                  icon: Icons.person,
                  title: 'ID de Alumno',
                  value: studentData['id_student']?.toString() ?? 'No disponible',
                ),
                _buildInfoCard(
                  icon: Icons.account_circle,
                  title: 'Nombre de Usuario',
                  value: studentData['username'] ?? 'No disponible',
                ),
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
                  value: _formatDate(studentData['created_at']),
                ),
                _buildInfoCard(
                  icon: Icons.update,
                  title: 'Última Actualización',
                  value: _formatDate(studentData['updated_at']),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementar edición de perfil
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de edición en desarrollo'),
                          backgroundColor: Colors.orange,
                        ),
                      );
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
                      // TODO: Implementar cerrar sesión
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de cerrar sesión en desarrollo'),
                          backgroundColor: Colors.orange,
                        ),
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
    final firstName = studentData['first_name'] ?? '';
    final lastName = studentData['last_name'] ?? '';
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
    if (dateString == null) return 'No disponible';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }
} 