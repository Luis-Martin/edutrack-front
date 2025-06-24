/// Modelo para representar un alumno en el sistema
/// Se encarga de la estructura de datos del alumno
class Student {
  final String? idStudent;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? phone;

  Student({
    this.idStudent,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  /// Convierte el modelo a un Map para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id_student': idStudent,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    };
  }

  /// Crea un modelo desde un Map recibido del backend
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      idStudent: json['id_student'],
      email: json['email'],
      password: json['password'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
    );
  }
} 