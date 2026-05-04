import 'package:flutter/material.dart';
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
      notifyListeners();
      final _response=await supabase.auth.signInWithPassword(email: email,password: password);
      if(_response.user != null){
        final roleData = await supabase
            .from("userauth")
            .select('role')
            .eq('id', _response.user!.id)
            .single();
        final role = roleData['role'];
        debugPrint("Logged in role: $role");
      }
    }catch(e){
      debugPrint("Login error: $e");
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}