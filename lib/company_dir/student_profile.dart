import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:grid_link/utils/userauth_display.dart';

/// Profile for any [userauth] row (student, company, supervisor, office).
class StudentProfile extends StatefulWidget {
  final String studentId;

  const StudentProfile({super.key, required this.studentId});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile(widget.studentId);
  }

  Future<void> fetchProfile(String userId) async {
    try {
      final data = await supabase
          .from('userauth')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        user = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> _openCv(String? cvUrl) async {
    if (cvUrl == null || cvUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CV not available')),
      );
      return;
    }
    final uri = Uri.tryParse(cvUrl);
    if (uri == null || !(await launchUrl(uri, mode: LaunchMode.externalApplication))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open CV link')),
      );
    }
  }

  String _gpaLabel() {
    final u = user;
    if (u == null) return 'N/A';
    final cgpa = u['cgpa'];
    final gpa = u['gpa'];
    if (cgpa != null) return cgpa.toString();
    if (gpa != null) return gpa.toString();
    return 'N/A';
  }

  List<Widget> _detailRows(BuildContext context) {
    final u = user!;
    final role = u['role']?.toString() ?? 'User';
    final rows = <Widget>[
      _row(Icons.badge_outlined, 'Role', role),
      _row(Icons.email_outlined, 'Email', u['email']?.toString() ?? '—'),
    ];

    switch (role) {
      case 'Student':
        rows.addAll([
          if (u['arid_no'] != null)
            _row(Icons.numbers, 'ARID', u['arid_no'].toString()),
          if (u['semester'] != null)
            _row(Icons.school_outlined, 'Semester', u['semester'].toString()),
          _row(Icons.grade_outlined, 'GPA / CGPA', _gpaLabel()),
          if (u['father_name'] != null &&
              u['father_name'].toString().trim().isNotEmpty)
            _row(Icons.family_restroom, 'Father name', u['father_name'].toString()),
          if (u['start_year'] != null || u['end_year'] != null)
            _row(
              Icons.date_range,
              'Batch',
              '${u['start_year'] ?? '—'} – ${u['end_year'] ?? '—'}',
            ),
        ]);
        break;
      case 'Company':
        rows.addAll([
          if (u['registration_no'] != null)
            _row(Icons.app_registration, 'Registration', u['registration_no'].toString()),
          if (u['city'] != null)
            _row(Icons.location_city, 'City', u['city'].toString()),
          if (u['location'] != null)
            _row(Icons.place_outlined, 'Location', u['location'].toString()),
        ]);
        break;
      case 'Supervisor':
      case 'Student Office':
        break;
    }

    return rows;
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Profile not found')),
      );
    }

    final name = user!['name']?.toString() ?? 'Profile';
    final avatarUrl = userauthAvatarUrl(user);
    final role = user!['role']?.toString();
    final showCv = role == 'Student' &&
        user!['cv_url'] != null &&
        user!['cv_url'].toString().trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Icon(Icons.person, size: 56, color: Colors.grey.shade600)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _detailRows(context),
                  ),
                ),
                if (showCv) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openCv(user!['cv_url'] as String?),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('View CV'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
