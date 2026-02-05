import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> jobs = [];

  /// maps
  Map<String, int> likeCountMap = {};
  Map<String, bool> userLikedMap = {};
  Map<String, bool> appliedMap = {};
  Map<String, List<Map<String, dynamic>>> commentMap = {};

  /// FETCH ALL JOBS
  Future<void> fetchJobs() async {
    final response = await supabase
        .from('company_post')
        .select('*, userauth(name, company_logo_url)')
        .order('created_at', ascending: false);

    jobs = List<Map<String, dynamic>>.from(response);

    for (var job in jobs) {
      final jobId = job['id'].toString();
      await fetchLikes(jobId);
      await fetchApplied(jobId);
      await fetchComments(jobId);
    }

    notifyListeners();
  }

  /// APPLY JOB ✅
  Future<void> applyJob(String jobId) async {
    final studentId = supabase.auth.currentUser!.id;

    // 🔒 prevent duplicate apply
    if (appliedMap[jobId] == true) return;

    await supabase.from('job_applications').insert({
      'job_id': jobId,
      'student_id': studentId,
      'status': 'pending',
    });

    // ✅ update local state immediately
    appliedMap[jobId] = true;
    notifyListeners();
  }

  /// FETCH APPLIED STATUS
  Future<void> fetchApplied(String jobId) async {
    final res = await supabase
        .from('job_applications') // ✅ SAME table
        .select('id')
        .eq('job_id', jobId)
        .eq('student_id', supabase.auth.currentUser!.id);

    appliedMap[jobId] = (res as List).isNotEmpty;
  }

  /// LIKE POST
  Future<void> fetchLikes(String jobId) async {
    final res = await supabase
        .from('job_like')
        .select('id, student_id')
        .eq('job_id', jobId);

    likeCountMap[jobId] = (res as List).length;
    userLikedMap[jobId] =
        res.any((e) => e['student_id'] == supabase.auth.currentUser!.id);
  }

  Future<void> likePost(String jobId) async {
    if (userLikedMap[jobId] == true) return;

    await supabase.from('job_like').insert({
      'job_id': jobId,
      'student_id': supabase.auth.currentUser!.id,
    });

    await fetchLikes(jobId);
    notifyListeners();
  }

  /// COMMENTS
  Future<void> fetchComments(String jobId) async {
    final res = await supabase
        .from('job_comment')
        .select('comment, userauth(name)')
        .eq('job_id', jobId)
        .order('created_at', ascending: true);

    commentMap[jobId] = List<Map<String, dynamic>>.from(res);
  }

  Future<void> addComment(String postId, String text) async {
    final userId = supabase.auth.currentUser!.id;

    await supabase.from('job_comment').insert({
      'post_id': postId,
      'student_id': userId,
      'comment': text,
    });

    await fetchComments(postId);
    notifyListeners();
  }
}
