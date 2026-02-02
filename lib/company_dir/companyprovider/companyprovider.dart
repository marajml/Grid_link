import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Company_postdeta with ChangeNotifier {
  File? _image; // picked image
  final SupabaseClient supabase = Supabase.instance.client;

  File? get image => _image;

  // Pick image from gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    }
  }

  // Upload image to Supabase Storage and get public URL
  Future<String?> uploadImage() async {
    if (_image == null) return null;

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      await supabase.storage
          .from('company-images') // your bucket name
          .upload('public/$fileName.png', _image!);

      final publicUrl = supabase.storage
          .from('company-images')
          .getPublicUrl('public/$fileName.png');

      return publicUrl;
    } catch (e) {
      print("Image upload error: $e");
      return null;
    }
  }

  // Insert job post into Supabase table
  Future<void> addJobPost(String title, String description) async {
    final imageUrl = await uploadImage();

    final response = await supabase.from('company_post').insert({
      'title': title,
      'description': description,
      'image': imageUrl,
    }).select();

  }
}
