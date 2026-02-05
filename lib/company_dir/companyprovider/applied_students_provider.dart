import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppliedStudentsProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> students = [];
  bool loading = false;

  Future<void> fetchStudents(String jobId) async {
    loading = true;
    notifyListeners();

    final response = await supabase
        .from('job_applications')
        .select('''
          id,
          status,
          applied_at,
          userauth (
          id,
            name,
            email,
            arid_no,
            cv_url,
            gpa
          )
        ''')
        .eq('job_id', jobId);

    students = List<Map<String, dynamic>>.from(response);
    loading = false;
    notifyListeners();
  }

  Future<void> updateStatus(String applicationId, String status) async {
    await supabase
        .from('job_applications')
        .update({'status': status})
        .eq('id', applicationId);

    final index = students.indexWhere((e) => e['id'] == applicationId);
    if (index != -1) {
      students[index]['status'] = status;
      notifyListeners();
    }
  }
}
