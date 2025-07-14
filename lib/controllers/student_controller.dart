import '../models/student_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

/// Controlador para manejar la lógica de negocio de los alumnos
/// Se encarga de recibir las órdenes del usuario y comunicarse con el modelo
class StudentController {
  /// Método para manejar el login del alumno (validar usuario existente)
  /// Recibe email y password para validar credenciales
  Future<Map<String, dynamic>> loginStudent({
    required String email,
    required String password,
  }) async {
    print('=== INICIANDO PROCESO DE LOGIN ALUMNO ===');

    final url = ApiConfig.buildUrl(ApiConfig.studentLogin);
    final studentData = {
      "email": email,
      "password": password,
    };

    print('Enviando datos de login al backend...');
    
    try {
      print("POST to $url");
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(studentData),
      );

      final decoded = jsonDecode(response.body);

      // Guardar el token como cookie en ApiConfig si el login fue exitoso
      if (response.statusCode == 200 && decoded != null && decoded['token'] != null) {
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        ApiConfig.cookie = decoded['token'];
        print('Cookie/token guardado en ApiConfig: ${ApiConfig.cookie}');
      }

      return {
        'status': response.statusCode,
        'content': decoded,
      };
    } catch (error) {
      print('Error durante la conexión al servidor: $error');
      return {
        'status': 500,
        'error': error.toString(),
      };
    }
  }

  /// Método para manejar la actualización (PUT) del perfil del alumno
  /// Recibe todos los datos para actualizar el usuario autenticado
  Future<Map<String, dynamic>> updateStudentProfile({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String career,
    required String yearAdmission,
  }) async {
    print('=== INICIANDO PROCESO DE ACTUALIZACIÓN DE PERFIL ALUMNO ===');

    // Utilizar el modelo de Student existente para crear el objeto
    Student student = Student(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      career: career,
      yearAdmission: yearAdmission,
    );

    // Convertir el modelo a JSON para enviar al backend
    Map<String, dynamic> studentData = student.toJson();

    final url = ApiConfig.buildUrl(ApiConfig.studentProfile);

    print('Enviando datos de actualización al backend...');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: ApiConfig.authHeaders,
        body: jsonEncode(studentData),
      );

      return {
        'status': response.statusCode,
        'content': jsonDecode(response.body),
      };
    } catch (error) {
      print('Error durante la conexión al servidor: $error');
      return {
        'status': 500,
        'content': {'error': error.toString()},
      };
    }
  }

  /// Método para optener a los cursos a los cuales está matriculado
  // Recibe todos los curso en un array
  Future<Map<String, dynamic>> listStudentEnrollsCourses() async {
    final url = ApiConfig.buildUrl(ApiConfig.studentEnrollsCourses);

    print('Enviando datos de actualización al backend...');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders,
      );

      final status = response.statusCode;
      final body = jsonDecode(response.body);

      final int currentYear = DateTime.now().year;
      
      // Filtar los actuales
      final filtered = body.where((course) {
        final year = course['academic_year'];
        return year != null && year.toString() == currentYear.toString();
      }).toList();

      return {
        'status': status,
        'content': filtered,
      };    
    } catch (error) {
      print('Error durante la conexión al servidor: $error');
      return {
        'status': 500,
        'content': {'error': error.toString()},
      };
    }
  }

  /// Método para optener a los cursos a los cuales estaba matriculado
  // Recibe todos los curso en un array
  Future<Map<String, dynamic>> listStudentEnrollsPassCourses() async {
    final url = ApiConfig.buildUrl(ApiConfig.studentEnrollsCourses);

    print('Enviando datos de actualización al backend...');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders,
      );

      final status = response.statusCode;
      final body = jsonDecode(response.body);

      final int currentYear = DateTime.now().year;

      // Filtrar los pasados
      final filtered = body.where((course) {
        final year = course['academic_year'];
        final int? yearInt = year != null ? int.tryParse(year.toString()) : null;
        return yearInt != null && yearInt < currentYear;
      }).toList();

      return {
        'status': status,
        'content': filtered,
      };
    } catch (error) {
      print('Error durante la conexión al servidor: $error');
      return {
        'status': 500,
        'content': {'error': error.toString()},
      };
    }
  }

  /// Método para obtener la nota de los cursos
  /// Recibe las notas del curso indicado por id_enroll_student
  Future<Map<String, dynamic>> listNotesCourse(int id_enroll_student) async {
    // Construir la URL con el parámetro de consulta
    final url = ApiConfig.buildUrl(ApiConfig.studentNotes) + '?id_enroll_student=$id_enroll_student';

    print('Enviando solicitud de notas al backend para id_enroll_student: $id_enroll_student');

    try {
      // Se envía el parámetro como query parameter en la URL
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders,
      );

      final status = response.statusCode;
      final body = jsonDecode(response.body);

      if (status == 200) {
        // Se espera que el backend retorne un objeto con las notas
        return {
          'status': status,
          'content': body,
        };
      } else {
        // Si hay error, retorna el mensaje de error del backend
        return {
          'status': status,
          'content': body,
        };
      }
    } catch (error) {
      print('Error durante la conexión al servidor: $error');
      return {
        'status': 500,
        'content': {'error': error.toString()},
      };
    }
  }

  /// Método para obtener la asistencia del estudiante
  /// Recibe la lista de asistencias del estudiante indicado por id_enroll_student
  Future<Map<String, dynamic>> listAttendanceCourse(int id_enroll_student) async {
    // Construir la URL con el parámetro de consulta usando studentAttendance
    final url = ApiConfig.buildUrl(ApiConfig.studentAttendance) + '?id_enroll_student=$id_enroll_student';

    print('Enviando solicitud de asistencia al backend para id_enroll_student: $id_enroll_student');

    try {
      // Se envía el parámetro como query parameter en la URL
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders,
      );

      final status = response.statusCode;
      final body = jsonDecode(response.body);

      if (status == 200) {
        // Se espera que el backend retorne una lista de asistencias
        return {
          'status': status,
          'content': body,
        };
      } else {
        // Si hay error, retorna el mensaje de error del backend
        return {
          'status': status,
          'content': body,
        };
      }
    } catch (error) {
      print('Error durante la conexión al servidor: $error');
      return {
        'status': 500,
        'content': {'error': error.toString()},
      };
    }
  }
} 