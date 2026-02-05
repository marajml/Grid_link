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
  bool _loading=false;
  final TextEditingController editingController=TextEditingController();
  final TextEditingController passwordController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    final supabase=Supabase.instance.client;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 24.r),
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

              // Email TextField
              TextField(
                controller: editingController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 20.h),

              // Password TextField
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),


              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {

                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _loading = true;
                    });
                    try {

                      final result = await supabase.auth.signInWithPassword(
                        email: editingController.text,
                        password: passwordController.text,
                      );

                      if (result.user != null) {
                        // Fetch role from DB
                        final roleData = await supabase
                            .from('userauth') // ya jahan role store hai
                            .select('role')
                            .eq('id', result.user!.id)
                            .single();

                        final role = roleData['role'];

                        // Navigate based on role
                        if (role == 'Student') context.go('/Studentdashboard');
                        if (role == 'Supervisor') context.go('/supervisorhome');
                        if (role == 'Company') context.go('/companydashboard');
                        if (role == 'Student Office') context.go('/Office_page');
                      }




                    }catch(e){
                      print(e);
                    }finally{
                      setState(() {
                        _loading=false;
                      });
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: _loading? CircularProgressIndicator(): Text(
                    'Login',
                    style: TextStyle(fontSize: 18.sp),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // No Account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      context.go("/signup");
                    },
                    child: Text(
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
    );
  }
}
