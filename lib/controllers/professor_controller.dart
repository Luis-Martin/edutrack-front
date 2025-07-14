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

  /// Método privado para enviar datos al backend (futura implementación)
  // void _sendToBackend(Map<String, dynamic> data) {
  //   // Implementación de la llamada HTTP al backend
  // }
} 