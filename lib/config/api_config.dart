/// Configuración centralizada para las APIs
/// Contiene las variables de conexión y endpoints del backend
class ApiConfig {
  // IP del servidor backend
  static const String serverIP = '192.168.54.207';
  
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
  
  /// Construye una URL completa para un endpoint específico
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
} 