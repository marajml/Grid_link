import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class LetterProvider with ChangeNotifier{
  final supabase=Supabase.instance.client;
  Future<void> fatchdatastudent()async
  {
    final user=supabase.auth.currentUser;
    if(user==null)return;
    await supabase
        .from("userauth")
        .select("name,arid_no,semester,email")
        .eq('id', user.id)
        .single();

  }
}