


import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class StudentAppliedJobsProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List jobs = [];
  bool loading = false;

  Future<void> fetchAppliedJobs() async {
    loading = true;
    notifyListeners();

    final userId = supabase.auth.currentUser!.id;

    final res = await supabase
        .from('job_applications')
        .select('''
          id,
          status,
          company_post (
            title,
            image,
            userauth( name, company_logo_url )
          )
        ''')
        .eq('student_id', userId);

    jobs = res;
    loading = false;
    notifyListeners();
  }
}
