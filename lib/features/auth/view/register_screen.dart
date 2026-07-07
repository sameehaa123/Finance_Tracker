
import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  String _selectedRole = 'Student';
  final List<String> _roles = ['Student', 'Professional', 'Senior Citizen'];

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      AuthController controller = AuthController();

    await controller.register(
  _emailController.text.trim(),
  _passwordController.text.trim(),
  _selectedRole,
);
 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Created! Please login.")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF00897B);
    return Scaffold(
      backgroundColor: Colors
          .transparent, // so the gradient behind (if any) doesn't get blocked
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: accent,
      ),
      body: Container(
        // 🌈 Same style as LoginScreen background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8E6CF), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration:
                      const InputDecoration(labelText: "Email"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      decoration:
                      const InputDecoration(labelText: "Password"),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),

                    // 🔽 Role dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items: _roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedRole = val!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Role",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 18),
                    if (_isLoading) const CircularProgressIndicator() else SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(vertical: 14.0)
                        ),
                        child: const Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 12.0),
                        ),
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
