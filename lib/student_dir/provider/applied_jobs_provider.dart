import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppliedJobsProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  bool loading = false;
  List<Map<String, dynamic>> appliedJobs = [];

  Future<void> fetchAppliedJobs() async {
    loading = true;
    notifyListeners();

    final userId = supabase.auth.currentUser!.id;

    final response = await supabase
        .from('job_applications')
        .select('status, job:job_id(title, description)')
        .eq('student_id', userId)
        .order('created_at', ascending: false);

    appliedJobs = List<Map<String, dynamic>>.from(response);

    loading = false;
    notifyListeners();
  }
}
