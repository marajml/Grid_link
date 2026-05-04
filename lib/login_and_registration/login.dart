import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _loading = false;
  bool _resetLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController editingController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    editingController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _showAlert(String title, String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<String?> _promptEmailForReset() async {
    final controller = TextEditingController(
      text: editingController.text.trim(),
    );

    String? result;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                result = controller.text.trim();
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<void> _handleForgotPassword() async {
    final email = await _promptEmailForReset();
    if (!mounted) return;

    final normalized = (email ?? '').trim();
    if (normalized.isEmpty) {
      return;
    }

    if (!_isValidEmail(normalized)) {
      await _showAlert('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    final supabase = Supabase.instance.client;
    setState(() {
      _resetLoading = true;
    });

    try {
      await supabase.auth.resetPasswordForEmail(
        normalized,
        redirectTo: 'io.supabase.flutter://reset-password',
      );
      await _showAlert(
        'Reset Link Sent',
        'We sent a password reset link to your email. Open that link to set a new password.',
      );
    } catch (e) {
      await _showAlert('Reset Failed', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _resetLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.r),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'GridLink',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 50.h),

                TextFormField(
                  controller: editingController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Please enter email';
                    final isValidEmail = RegExp(
                      r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(email);
                    if (!isValidEmail) return 'Please enter a valid email';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    final password = value ?? '';
                    if (password.isEmpty) return 'Please enter password';
                    if (password.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetLoading ? null : _handleForgotPassword,
                    child: _resetLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                  ),
                ),

                SizedBox(height: 40.h),

                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            final router = GoRouter.of(context);
                            FocusScope.of(context).unfocus();
                            if (!_formKey.currentState!.validate()) return;

                            setState(() {
                              _loading = true;
                            });

                            try {
                              final result = await supabase.auth
                                  .signInWithPassword(
                                    email: editingController.text.trim(),
                                    password: passwordController.text,
                                  );

                              if (result.user == null) {
                                await _showAlert(
                                  'Login Failed',
                                  'User not found. Please try again.',
                                );
                                return;
                              }

                              final roleData = await supabase
                                  .from('userauth')
                                  .select('role')
                                  .eq('id', result.user!.id)
                                  .single();

                              final role = roleData['role'] as String?;
                              if (!mounted) return;
                              if (role == 'Student') router.go('/Studentdashboard');
                              if (role == 'Supervisor') router.go('/supervisorhome');
                              if (role == 'Company') router.go('/companydashboard');
                              if (role == 'Student Office') router.go('/officehome');
                              if (role == null ||
                                  (role != 'Student' &&
                                      role != 'Supervisor' &&
                                      role != 'Company' &&
                                      role != 'Student Office')) {
                                await _showAlert(
                                  'Role Error',
                                  'Invalid role assigned to this account.',
                                );
                              }
                            } catch (e) {
                              await _showAlert(
                                'Login Error',
                                e.toString(),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _loading = false;
                                });
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Login',
                            style: TextStyle(fontSize: 18.sp),
                          ),
                  ),
                ),

                SizedBox(height: 20.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        context.go("/signup");
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
