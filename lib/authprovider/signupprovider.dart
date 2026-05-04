import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart';


class Signupdata with ChangeNotifier {
  File? _profileImage;
  File? get profileImage => _profileImage;
  File? _companyLogo;
  File? get companyLogo => _companyLogo;
  File? _supervisorSignature;
  File? get supervisorSignature => _supervisorSignature;
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
    final profileImageUrl = await uploadProfileImage();
    final companyLogoUrl = role == 'Company' ? await uploadCompanyLogo() : null;

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

      String? supervisorSignaturePath;
      if (role == 'Supervisor' && _supervisorSignature != null) {
        supervisorSignaturePath = await uploadSupervisorSignature(
          userId: userId,
          file: _supervisorSignature!,
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
        'profile_image_url': profileImageUrl,
        'company_logo_url': companyLogoUrl,
        'supervisor_signature_path': supervisorSignaturePath,
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

        final storagePath ='students/$userId/$fileName';

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
  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _profileImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> pickCompanyLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _companyLogo = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> pickSupervisorSignature() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _supervisorSignature = File(pickedFile.path);
      notifyListeners();
    }
  }

  void clearSupervisorSignature() {
    _supervisorSignature = null;
    notifyListeners();
  }

  Future<String> uploadSupervisorSignature({
    required String userId,
    required File file,
  }) async {
    final ext = extension(file.path).toLowerCase();
    final safeExt = (ext == '.png' || ext == '.jpg' || ext == '.jpeg')
        ? ext
        : '.png';
    final storagePath = '$userId/signature$safeExt';

    try {
      await _supabase.storage.from('supervisor_signatures').upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );
    } catch (e) {
      final s = e.toString();
      if (s.contains('Bucket not found') || s.contains('404')) {
        throw Exception(
          'Supabase bucket "supervisor_signatures" is missing. '
          'Create it: Dashboard → Storage → New bucket → name supervisor_signatures (private). '
          'Then run storage policies from supabase/migrations/20260419000000_supervisor_signature.sql',
        );
      }
      rethrow;
    }

    return storagePath;
  }

  Future<String?> uploadProfileImage() async {
    if (_profileImage == null) return null;
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final storagePath = 'profile/$fileName.png';
      await _supabase.storage.from('company-images').upload(storagePath, _profileImage!);
      return _supabase.storage.from('company-images').getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('Profile image upload error: $e');
      return null;
    }
  }

  Future<String?> uploadCompanyLogo() async {
    if (_companyLogo == null) return null;
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final storagePath = 'logo/$fileName.png';
      await _supabase.storage.from('company-images').upload(storagePath, _companyLogo!);
      return _supabase.storage.from('company-images').getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('Company logo upload error: $e');
      return null;
    }
  }

}
