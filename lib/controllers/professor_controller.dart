import '../models/professor_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

/// Controlador para manejar la lógica de negocio de los profesores
/// Se encarga de recibir las órdenes del usuario y comunicarse con el modelo
class ProfessorController {
  
  /// Método para manejar el login del profesor (validar usuario existente)
  /// Recibe email y password para validar credenciales
  Future<Map<String, dynamic>> loginProfessor({
    required String email,
    required String password,
  }) async {
    print('=== INICIANDO PROCESO DE REGISTRO PROFESOR ===');

    final url = ApiConfig.buildUrl(ApiConfig.professorLogin);
    final professorData = {
      "email": email,
      "password": password,
    };

    print('Enviando datos de login al backend...');
    
    try {
      print("POST to $url");
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(professorData),
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
        'content': jsonDecode(response.body),
      };
    } catch (error) {
      print('Error durante la conexión al servidor: $error');
      return {
        'status': 500,
        'error': error.toString(),
      };
    }
  }

  /// Método para manejar el registro (signin) del profesor
  /// Recibe todos los datos para crear un nuevo usuario
  Future<Map<String, dynamic>> signinProfessor({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    print('=== INICIANDO PROCESO DE REGISTRO PROFESOR ===');

    // Utilizar el modelo de Profesor existente para crear el objeto
    Professor professor = Professor(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );

    // Convertir el modelo a JSON para enviar al backend
    Map<String, dynamic> professorData = professor.toJson();

    final url = ApiConfig.buildUrl(ApiConfig.professorRegister);

    print('Enviando datos de registro al backend...');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(professorData),
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

  /// Método para manejar la actualización (PUT) del perfil del profesor
  /// Recibe todos los datos para actualizar el usuario autenticado
  Future<Map<String, dynamic>> updateProfessorProfile({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    print('=== INICIANDO PROCESO DE ACTUALIZACIÓN DE PERFIL PROFESOR ===');

    Professor professor = Professor(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );

    Map<String, dynamic> professorData = professor.toJson();

    final url = ApiConfig.buildUrl(ApiConfig.professorProfile);

    print('Enviando datos de actualización al backend...');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: ApiConfig.authHeaders,
        body: jsonEncode(professorData),
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

  /// Método para optener a los cursos a los aprturados actuales
  // Recibe todos los curso en un array
  Future<Map<String, dynamic>> listProfessorOpenCourses() async {
    final url = ApiConfig.buildUrl(ApiConfig.professorOpenCourse);

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

  /// Método para optener a los cursos a los aprturados pasados
  // Recibe todos los curso en un array
  Future<Map<String, dynamic>> listProfessorPassOpenCourses() async {
    final url = ApiConfig.buildUrl(ApiConfig.professorOpenCourse);
    print(url);
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
        return year != null && year < currentYear;
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

  /// Método para optener a los cursos a los aprturados pasados
  // Recibe todos los curso en un array
  Future<Map<String, dynamic>> listEnrrollStudents(open_course) async {
    final url = ApiConfig.buildUrl(ApiConfig.professorEnrollsCourses) + '?open_course=$open_course';
    print(url);
    print('[listEnrrollStudents] Enviando datos de actualización al backend...');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders,
      );

      final status = response.statusCode;
      final body = jsonDecode(response.body);

      return {
        'status': status,
        'content': body,
      };    
    } catch (error) {
      print('Error durante la conexión al servidor: $error');
      return {
        'status': 500,
        'content': {'error': error.toString()},
      };
    }
  }

  /// Método para obtener los alumnos no matriculados
  // Recibe los alumnos en un array
  Future<Map<String, dynamic>> listNoEnrrollStudents(open_course) async {
    final urlAllStudents = ApiConfig.buildUrl(ApiConfig.professorStudents);
    final urlEnrroledStudents = ApiConfig.buildUrl(ApiConfig.professorEnrollsCourses) + '?open_course=$open_course';
  
    print('[listNoEnrrollStudents] Enviando datos de actualización al backend...');
    try {
      final response = await http.get(
        Uri.parse(urlAllStudents),
        headers: ApiConfig.authHeaders,
      );
      final allStudents = jsonDecode(response.body);

      final responseEnrroll = await http.get(
        Uri.parse(urlEnrroledStudents),
        headers: ApiConfig.authHeaders,
      );
      final allEnrrollStudents = jsonDecode(responseEnrroll.body);

      // Obtener los IDs de los estudiantes ya matriculados
      final Set<int> enrolledIds = <int>{};
      if (allEnrrollStudents is List) {
        for (var enroll in allEnrrollStudents) {
          final id = enroll['student'] != null ? enroll['student']['id_student'] : null;
          if (id != null && id is int) {
            enrolledIds.add(id);
          }
        }
      }

      // Filtrar los estudiantes que NO están matriculados
      final List<dynamic> notEnrolledStudents = allStudents.where((student) {
        final int? id = student['id_student'];
        return id != null && !enrolledIds.contains(id);
      }).toList();

      return {
        'status': 200,
        'content': notEnrolledStudents,
      };    
    } catch (error) {
      print('Error durante la conexión al servidor: $error');
      return {
        'status': 500,
        'content': {'error': error.toString()},
      };
    }
  }

  /// Método para matricula a alumno
  // Recibe todos los curso en un array
  Future<Map<String, dynamic>> enrrollStudent(id_open_course, id_student) async {
    final url = ApiConfig.buildUrl(ApiConfig.professorEnrollsCourses);
    print('[enrrollStudent] Enviando datos de actualización al backend...');
    try {
      final data = {
        "id_student": id_student,
        "id_open_course": id_open_course
      };

      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.authHeaders,
        body: jsonEncode(data),
      );

      final status = response.statusCode;
      final body = jsonDecode(response.body);

      return {
        'status': status,
        'content': body,
      };    
    } catch (error) {
      print('Error durante la conexión al servidor: $error');
      return {
        'status': 500,
        'content': {'error': error.toString()},
      };
    }
  }

  // Método para matricula a alumno
  // Recibe todos los curso en un array
  Future<Map<String, dynamic>> deleteEnrrollStudent(id_open_course, id_student) async {
    final url = ApiConfig.buildUrl(ApiConfig.professorDeleteEnrollsCourses);
    print('[enrrollStudent] Enviando datos de actualización al backend...');
    try {
      final data = {
        "id_student": id_student,
        "id_open_course": id_open_course
      };

      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.authHeaders,
        body: jsonEncode(data),
      );

      final status = response.statusCode;
      final body = jsonDecode(response.body);

      return {
        'status': status,
        'content': body,
      };    
    } catch (error) {
      print('Error durante la conexión al servidor: $error');
      return {
        'status': 500,
        'content': {'error': error.toString()},
      };
    }
  }
} 