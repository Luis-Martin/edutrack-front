import 'package:flutter/material.dart';
import 'professor_login_view.dart';
import 'student_login_view.dart';

/// Vista principal de la aplicación
/// Contiene los botones para navegar a los diferentes tipos de login
class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduTrack'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Encabezado
            Column(
              children: [
                Text(
                  'BIENVENIDO A...\nEDUTRACK FIEI UNFV',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Image.asset(
                    'assets/logo-unfv.png',
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),

            // Botón para login de Profesor
            Container(
              width: 200,
              height: 50,
              margin: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la vista de login de profesor
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfessorLoginView(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF07613),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Profesor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Botón para login de Alumno
            Container(
              width: 200,
              height: 50,
              margin: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la vista de login de alumno
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentLoginView(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF07613),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Alumno',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 