import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    await Future.delayed(const Duration(seconds: 3));

    final user = supabase.auth.currentUser;

    if (!mounted) return;


    if (user == null) {
      context.go('/login');
      return;
    }

    try {

      final data = await supabase
          .from('userauth')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = data['role'];

      // 🟢 Role based routing
      if (role == 'Student') {
        context.go('/Studentdashboard');
      } else if (role == 'Company') {
        context.go('/companydashboard');
      } else if (role == 'Supervisor') {
        context.go('/supervisorhome');
      }

      else if (role == 'Student Office') {
        context.go('/officehome');
      }


      else {
        context.go("/login"); // fallback
      }
    } catch (e) {
      debugPrint("Role fetch error: $e");
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Icon(
          Icons.school,
          size: 200,
          color: Colors.blue,
        ),
      ),
    );
  }
}
