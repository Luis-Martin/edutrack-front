/// Configuración centralizada para las APIs
/// Contiene las variables de conexión y endpoints del backend
class ApiConfig {
  // IP del servidor backend
  static const String serverIP = '127.0.0.1';
  static String cookie = '';
  // Puerto del servidor
  static const int serverPort = 8000;
  
  // URL base del API
  static const String baseUrl = 'http://$serverIP:$serverPort/api';
  
  // Endpoints específicos
  static const String professorRegister = '/professor/register';
  static const String professorLogin = '/professor/login';
  static const String professorProfile = '/professor/profile';
  
  static const String studentRegister = '/student/register';
  static const String studentLogin = '/student/login';
  static const String studentProfile = '/student/profile';
  
  // Headers comunes
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Headers para usuarios autenticados (incluye Authorization con el token)
  static Map<String, String> get authHeaders {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Token $cookie',
    };
  }
  
  /// Construye una URL completa para un endpoint específico
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
} 