/// Modelo para representar un profesor en el sistema
/// Se encarga de la estructura de datos del profesor
class Professor {
  final String email;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String? phone;


  /// Constructor completo (para datos del backend)
  Professor({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  /// Convierte el modelo a un Map para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    };
  }

  /// Crea un modelo desde un Map recibido del backend
  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      email: json['email'],
      password: json['password'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
    );
  }
} 