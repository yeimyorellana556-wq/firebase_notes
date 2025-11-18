import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _remember = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Simular autenticación (reemplaza por lógica real)
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inicio de sesión exitoso')),
    );

    // Navegar a la pantalla de notas (definida en main.dart via rutas)
    Navigator.of(context).pushReplacementNamed('/notes');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5B2C83), Color(0xFF7B61FF)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
            child: Card(
              elevation: 16,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(Icons.note_alt_rounded, size: 36, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text('Bienvenido', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Inicia sesión para administrar tus notas', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 18),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _userCtrl,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              labelText: 'Usuario',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu usuario' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passCtrl,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              labelText: 'Contraseña',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Checkbox(
                                value: _remember,
                                onChanged: (v) => setState(() => _remember = v ?? false),
                              ),
                              const Expanded(child: Text('Recordarme')),
                              TextButton(
                                onPressed: () {},
                                child: const Text('¿Olvidaste la contraseña?'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              onPressed: _isLoading ? null : _submit,
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Iniciar sesión'),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('¿No tienes cuenta?'),
                              TextButton(onPressed: () {}, child: const Text('Regístrate')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}