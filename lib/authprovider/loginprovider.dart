import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class Loginuser with ChangeNotifier{
  final supabase=Supabase.instance.client;
  bool _loading=false;
  bool get loading=>_loading;
  Future<void> loginuser(
  {
    required String email,
    required String password
})async{
    try {
      _loading=true;
      final _response=await supabase.auth.signInWithPassword(email: email,password: password);
      if(_response.user != null){
        final roleData=supabase.from("userauth").select(
          '*'
        ).eq('id', _response.user!.id).single();
        final role = roleData['role'];


      }




    }catch(e){

    }

  }
}

extension on PostgrestTransformBuilder<PostgrestMap> {
  operator [](String other) {}
}