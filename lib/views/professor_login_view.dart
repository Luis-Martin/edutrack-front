import 'package:flutter/material.dart';
import 'package:edutrackf/controllers/professor_controller.dart';
import 'package:edutrackf/views/professor_profile_view.dart';
import 'professor_singin_view.dart';

/// Vista para el login de profesores
/// Contiene el formulario de login y se comunica con el controlador
class ProfessorLoginView extends StatefulWidget {
  const ProfessorLoginView({super.key});

  @override
  State<ProfessorLoginView> createState() => _ProfessorLoginViewState();
}

class _ProfessorLoginViewState extends State<ProfessorLoginView> {
  // Controladores para los campos de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instancia del controlador
  final _professorController = ProfessorController();

  @override
  void dispose() {
    // Limpiar los controladores cuando se destruya el widget
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Método para manejar el envío del formulario
  void _handleLogin() async {
    // Validar que todos los campos estén llenos
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Llamar al controlador con los datos del formulario
    final response = await _professorController.loginProfessor(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (response['status'] == 200) {
      // Login exitoso
      final content = response['content'];
      final token = content['token'];
      final professor = content['professor'];

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login exitoso'),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar al perfil del profesor
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfessorProfileView(
              professorData: professor,
              token: token,
            ),
          ),
        );
      }
    } else {
      // Login fallido
      String errorMsg = 'Error en el login';
      if (response['content'] != null && response['content']['error'] != null) {
        errorMsg = response['content']['error'].toString();
      } else if (response['content'] != null && response['content'] is Map && response['content'].containsKey('detail')) {
        errorMsg = response['content']['detail'].toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Profesor'),
        backgroundColor: const Color(0xFFF07613),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header con gradiente y avatar
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
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 48, color: Color(0xFFF07613)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bienvenido Profesor',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Acceso a tu cuenta',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Card con el formulario
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Campo Email
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.email, color: Color(0xFFF07613)),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo Password
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock, color: Color(0xFFF07613)),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Botón de Login
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF07613),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Link a registro
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfessorSinginView(),
                            ),
                          );
                        },
                        child: const Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            color: Color(0xFFF07613),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFF07613),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 