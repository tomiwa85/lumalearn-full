import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _accessCodeController = TextEditingController(); // Class Code
  final _studentCodeController =
      TextEditingController(); // Student Code (for Scouts)

  bool _isLoading = false;
  bool _isLoginMode = true; // True for Login, False for Sign Up
  String _selectedRole = 'student'; // Default role for signup

  // Handle Form Submission
  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final authService = ref.read(authServiceProvider);

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter both email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLoginMode) {
        // === LOG IN ===
        await authService.signIn(email, password);

        // Check Role
        final role = await ref.refresh(userRoleProvider.future);

        if (mounted) {
          if (role == 'scout') {
            context.go('/scout-dashboard');
          } else {
            context.go('/home');
          }
        }
      } else {
        // === SIGN UP ===
        if (_nameController.text.trim().isEmpty) {
          throw Exception('Please enter your full name.');
        }

        await authService.signUpAndProfile(
          email: email,
          password: password,
          fullName: _nameController.text.trim(),
          role: _selectedRole,
          accessCode: (_selectedRole == 'student' || _selectedRole == 'scout')
              ? _accessCodeController.text.trim()
              : null,
          studentCode: _selectedRole == 'scout'
              ? _studentCodeController.text.trim()
              : null,
        );

        if (mounted) {
          _showSnackBar(
            _selectedRole == 'teacher'
                ? 'Teacher account created! You can now log in.'
                : 'Student account created and enrolled! You can now log in.',
            isError: false,
          );
          setState(() {
            _isLoginMode = true;
            _passwordController.clear();
          }); // Switch to login after signup
        }
      }
    } catch (e) {
      String errorMessage = e.toString().contains('AuthApiError')
          ? "Error: Check credentials or account is pending confirmation."
          : e.toString().split(':').last.trim();
      _showSnackBar(errorMessage, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppTheme.neonGreen,
        duration: const Duration(milliseconds: 3000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.school_outlined,
                  size: 60, color: AppTheme.neonGreen),
              const SizedBox(height: 20),
              Text(
                _isLoginMode ? 'Welcome Back' : 'Create Account',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // Name Field (Only on Sign Up)
              if (!_isLoginMode) ...[
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon:
                        Icon(Icons.person_outline, color: AppTheme.textGrey),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Email Field
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon:
                      Icon(Icons.email_outlined, color: AppTheme.textGrey),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon:
                      Icon(Icons.key_outlined, color: AppTheme.textGrey),
                ),
              ),
              const SizedBox(height: 30),

              // Role Selector (Only on Sign Up)
              if (!_isLoginMode)
                _RoleSelector(
                  selectedRole: _selectedRole,
                  onRoleChanged: (newRole) =>
                      setState(() => _selectedRole = newRole),
                ),

              // Access Code (Student & Scout)
              if (!_isLoginMode &&
                  (_selectedRole == 'student' || _selectedRole == 'scout')) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _accessCodeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: _selectedRole == 'student'
                        ? 'Class Access Code (LRN-XXXX)'
                        : 'Teacher\'s Class Code (LRN-XXXX)',
                    prefixIcon: const Icon(Icons.group_add_outlined,
                        color: AppTheme.textGrey),
                    hintText: 'Code from teacher',
                  ),
                ),
              ],

              // Student Code (Only for Scout)
              if (!_isLoginMode && _selectedRole == 'scout') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _studentCodeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Student Code (STU-XXXX)',
                    prefixIcon:
                        Icon(Icons.badge_outlined, color: AppTheme.textGrey),
                    hintText: 'Code from your child',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter the unique code from your child's profile.",
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                      : Text(_isLoginMode ? 'Sign In' : 'Sign Up'),
                ),
              ),

              const SizedBox(height: 20),

              // Toggle Mode
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                    // Clear fields when switching modes
                    _nameController.clear();
                    _accessCodeController.clear();
                  });
                },
                child: RichText(
                  text: TextSpan(
                    text: _isLoginMode
                        ? "Don't have an account? "
                        : "Already have an account? ",
                    style: const TextStyle(color: AppTheme.textGrey),
                    children: [
                      TextSpan(
                        text: _isLoginMode ? 'Sign Up' : 'Log In',
                        style: const TextStyle(
                          color: AppTheme.neonGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Widget for Role Selection
class _RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const _RoleSelector({
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _RoleButton(
            label: 'Student',
            role: 'student',
            selectedRole: selectedRole,
            onTap: onRoleChanged,
          ),
          _RoleButton(
            label: 'Teacher',
            role: 'teacher',
            selectedRole: selectedRole,
            onTap: onRoleChanged,
          ),
          _RoleButton(
            label: 'Parent', // Scout
            role: 'scout',
            selectedRole: selectedRole,
            onTap: onRoleChanged,
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final String role;
  final String selectedRole;
  final ValueChanged<String> onTap;

  const _RoleButton({
    required this.label,
    required this.role,
    required this.selectedRole,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = role == selectedRole;
    return GestureDetector(
      onTap: () => onTap(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neonGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.neonGreen : Colors.white10,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
