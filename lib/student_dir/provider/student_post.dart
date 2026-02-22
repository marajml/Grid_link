import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class StudentPost with ChangeNotifier{
  final supabase=Supabase.instance.client;
  File? _image;
  List<Map<String,dynamic>> post=[];

  File? get image=>_image;
  Future<void> imagepicker()async{
    final picker=ImagePicker();
    final ImageFile= await picker.pickImage(source: ImageSource.gallery);
    if(ImageFile != null){
      // _image=File(ImageFile.path);
      _image = File(ImageFile.path);
      notifyListeners();
    }
  }
  Future<String?> uploadimage() async {
    if (_image == null) return null;

    final filename = DateTime.now().microsecondsSinceEpoch.toString();

    try {
      await supabase.storage
          .from("Student_post")
          .upload("studentpost/$filename.png", _image!);

      final url = supabase.storage
          .from("Student_post")
          .getPublicUrl("studentpost/$filename.png");

      return url;
    } catch (e) {
      print(e);
      return null;
    }
    notifyListeners();
  }




    
    

  Future<void> addpost(String title, String description) async {
    final imageurl = await uploadimage();

    await supabase.from("student_post").insert({
      "student_id": supabase.auth.currentUser!.id,
      "title": title,
      "description": description,
      "image_url": imageurl
    });
  }
  bool isLoading = false;

  List<Map<String, dynamic>> posts = [];

  /// FETCH POSTS WITH USER DATA
  Future<void> fetchPosts() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('student_post')
          .select('''
      id,
      title,
      description,
      image_url,
      created_at,
      student_id,
      userauth:student_id (
        name,
        profile_url
      )
    ''')
          .order('created_at', ascending: false);


      posts = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Fetch post error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


}
