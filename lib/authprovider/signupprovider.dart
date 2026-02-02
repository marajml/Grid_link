import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart';


class Signupdata with ChangeNotifier {
  File? _image;
  File? get Image=>_image;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signupuser({
    required String? role,
    required String name,
    required String email,
    required String password,

    String? father_name,
    String? arid_no,
    int? semester,
    double? gpa,
    int? start_year,
    int? end_year,
    String? cvFilePath,

    String? registration_no,
    String? location,
    String? city,
  }) async {
    _isLoading = true;
    notifyListeners();
    final imageurl= await  uploadimage();

    try {


      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final userId = authResponse.user!.id;


      String? cvUrl;
      if (role == 'Student' && cvFilePath != null) {
        cvUrl = await uploadCV(
          userId: userId,
          filePath: cvFilePath,
        );
      }


      await _supabase.from('userauth').insert({
        'id': userId,
        'role': role,
        'name': name,
        'email': email,

        'father_name': father_name,
        'arid_no': arid_no,
        'semester': semester,
        'gpa': gpa,
        'start_year': start_year,
        'end_year': end_year,
        'cv_url': cvUrl,

        'registration_no': registration_no,
        'location': location,
        'city': city,
        'image_url':imageurl
      });

      notifyListeners();
    } catch (e) {
      debugPrint("Signup error: $e");
      rethrow;
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }

  }


  Future<String?> uploadCV({
    required String userId,
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      final fileName = basename(file.path);

        final storagePath = 'students/$userId/$fileName';

      await _supabase.storage
          .from('cvs')
          .upload(storagePath, file);

      final publicUrl = _supabase.storage
          .from('cvs')
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      debugPrint("CV upload error: $e");
      return null;
    }
  }
  Future<void> loginuser(String email,String password)async {

    final result=await _supabase.auth.signInWithPassword(email: email,password: password);
    if(result.user !=null){


    }

  }
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    }
  }
  Future<String?> uploadimage() async{
    if(_image == null ) return null;
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    try{
      await _supabase.storage.from('company-images').upload('logo/$fileName.png', _image!);
      final geturl=_supabase.storage.from('company-images').getPublicUrl('logo/$fileName.png');
      return geturl;
    }catch(e){
      print(e);
    }


  }

}
