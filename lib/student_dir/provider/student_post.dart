import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentPost with ChangeNotifier {
  static const String postTypeJob = 'job';
  static const String postTypeInternship = 'internship';

  final supabase = Supabase.instance.client;
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




    
    

  Future<void> addpost(
    String title,
    String description,
    String postType,
  ) async {
    final imageurl = await uploadimage();

    await supabase.from("student_post").insert({
      "student_id": supabase.auth.currentUser!.id,
      "title": title,
      "description": description,
      "image_url": imageurl,
      "post_type": postType,
    });

    _image = null;
    notifyListeners();
    await fetchPosts();
  }
  bool isLoading = false;

  /// False until the first [fetchPosts] completes (success or error).
  bool hasLoadedOnce = false;

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
      post_type,
      created_at,
      student_id,
      userauth:student_id (
        name,
        profile_image_url,
        profile_url,
        role,
        company_logo_url
      )
    ''')
          .order('created_at', ascending: false);


      posts = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Fetch post error: $e");
    } finally {
      isLoading = false;
      hasLoadedOnce = true;
      notifyListeners();
    }
  }

  /// Removes a post owned by the current user. Returns an error message on failure.
  Future<String?> deletePost(String postId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return 'Not signed in';

    try {
      await supabase
          .from('student_post')
          .delete()
          .eq('id', postId)
          .eq('student_id', uid);

      posts.removeWhere((p) => p['id'].toString() == postId.toString());
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Delete post error: $e');
      return e.toString();
    }
  }
}
