import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class JobsList with ChangeNotifier{
  final supabase = Supabase.instance.client;

  bool isLoading = false;
  List<Map<String, dynamic>> jobs = [];
  Future<void> fetchJobs() async {
    isLoading = true;
    notifyListeners();

    final response = await supabase
        .from('company_post')
        .select()
        .order('created_at', ascending: false);

    jobs = List<Map<String, dynamic>>.from(response);

    isLoading = false;
    notifyListeners();
  }

}