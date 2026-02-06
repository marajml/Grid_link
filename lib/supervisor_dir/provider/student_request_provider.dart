import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class Student_Letter_Request with ChangeNotifier{
  final supabase=Supabase.instance.client;

  List<Map<String, dynamic>> students=[];
  bool loading = false;
   Future<void> fatchrequest()async{
     final userid=supabase.auth.currentUser!.id;
     loading = true;
     notifyListeners();
     final response=await supabase.from("teacher_request").select(
       '''
       id,
       status,
       userauth(
       id,
       email,
      arid_no,
      profile_url,
      gpa
       ) 
       '''

     ).eq("supervisor_id",userid );
     students = List<Map<String, dynamic>>.from(response);
     loading = false;
     notifyListeners();
   }
  
}