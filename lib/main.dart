import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_link/authprovider/loginprovider.dart';
import 'package:grid_link/provider/job_provider.dart';
import 'package:grid_link/splashscreen.dart';
import 'package:grid_link/company_dir/companyprovider/companyprovider.dart';
import 'package:grid_link/student_dir/provider/applied_jobs_provider.dart';
import 'package:grid_link/student_dir/provider/jobsprovider.dart';
import 'package:grid_link/student_dir/provider/studentappliedjobsprovider.dart';
import 'package:grid_link/student_dir/student_dashboard.dart';
import 'package:grid_link/student_office/home_page.dart';
import 'package:grid_link/supervisor_dir/supervisor_home.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'authprovider/signupprovider.dart';
import 'company_dir/apply_student.dart';
import 'company_dir/company_dashboard.dart';
import 'company_dir/companyprovider/applied_students_provider.dart' show AppliedStudentsProvider;
import 'company_dir/companyprovider/provider_home.dart';
import 'company_dir/letter_request.dart';
import 'company_dir/student_profile.dart';
import 'login_and_registration/login.dart';
import 'login_and_registration/signup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: "https://jtzzumanwoqglupegwgp.supabase.co",
      anonKey: "sb_publishable_Z4dtlF1naUZEVVQ9iHNQhQ_pJbH9euK");
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();



  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
       child:  MultiProvider(
          providers: [

            ChangeNotifierProvider(create: (_) => Signupdata()),
            ChangeNotifierProvider(create: (_) => Loginuser()),
            ChangeNotifierProvider(create: (_) => Company_postdeta()),
            ChangeNotifierProvider(create: (_) => Companydata()),
            ChangeNotifierProvider(create: (_) => JobsList()),
            ChangeNotifierProvider(create: (_) => JobProvider()),
            ChangeNotifierProvider(create: (_) => AppliedStudentsProvider()),
            ChangeNotifierProvider(create: (_) => AppliedJobsProvider()),
            ChangeNotifierProvider(create: (_) => StudentAppliedJobsProvider()),

          ],
          child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
        )
       ),

    );
  }
  final GoRouter _router=GoRouter(

      routes:
  [
    GoRoute(path: ("/"),builder: (context,state)=>SplashScreen()),
    GoRoute(path: "/login",builder: (context,state)=>Login()),
    GoRoute(path: '/signup',builder: (context,state)=>Signup()),

    GoRoute(path: '/officehome',builder: (context,state)=>Office_page()),
    GoRoute(path: '/supervisorhome',builder: (context,state)=>SupervisorHome()),
    GoRoute(path: '/companydashboard',builder: (context,state)=>CompanyHome()),
    GoRoute(path: '/Studentdashboard',builder: (context,state)=>StudentHome()),
    GoRoute(
      path: '/Studentlist/:jobId', // <-- notice the ":jobId"
      builder: (context, state) {
        final jobId = state.pathParameters['jobId']!;
        return AppliedStudentsScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: '/studentprofile/:id',  // id is passed in the URL
      builder: (context, state) {
        final studentId = state.pathParameters['id']!; // get the ID
        return StudentProfile(studentId: studentId);
      },
    ),
    GoRoute(path: '/letterRequest',builder: (context,state)=>SupervisorRequestScreen()),


  ]);
}
