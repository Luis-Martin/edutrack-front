import 'package:flutter/material.dart';
import '../controllers/professor_controller.dart';

class ProfessorProfileUpdateView extends StatefulWidget {
  final Map<String, dynamic> professorData;
  const ProfessorProfileUpdateView({super.key, required this.professorData});

  @override
  State<ProfessorProfileUpdateView> createState() => _ProfessorProfileUpdateViewState();
}

class _ProfessorProfileUpdateViewState extends State<ProfessorProfileUpdateView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ProfessorController();

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.professorData['email'] ?? '');
    _passwordController = TextEditingController();
    _firstNameController = TextEditingController(text: widget.professorData['first_name'] ?? '');
    _lastNameController = TextEditingController(text: widget.professorData['last_name'] ?? '');
    _phoneController = TextEditingController(text: widget.professorData['phone'] ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final response = await _controller.updateProfessorProfile(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (response['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response['content']['error'] ?? 'No se pudo actualizar'}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil Profesor'),
        backgroundColor: const Color(0xFFF07613),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña (dejar en blanco para no cambiar)'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF07613),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 