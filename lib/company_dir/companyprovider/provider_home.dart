import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class Companydata with ChangeNotifier{
    String _name='';
    String get name=>_name;
   Future<void> companydata()async{
     final supabase= Supabase.instance.client;
     final user=supabase.auth.currentUser;
     final data = await supabase
         .from('userauth')
         .select('role')
         .eq('id', user!.id)
         .single();
     _name=data['name'] ?? " ";
     notifyListeners();
   }


}