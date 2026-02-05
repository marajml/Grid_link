import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentProfile extends StatefulWidget {
  final String studentId;
  const StudentProfile({super.key, required this.studentId});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? student;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentProfile(widget.studentId);
  }

  Future<void> fetchStudentProfile(String userId) async {
    try {
      final data = await supabase
          .from('userauth')
          .select()
          .eq('id', userId)
          .maybeSingle(); // latest way, no execute()

      setState(() {
        student = data as Map<String, dynamic>?;
        loading = false;
      });

      if (student != null) {
        print('Student Data: $student');
      } else {
        print('No student found.');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('Error fetching student: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (student == null) {
      return const Scaffold(
        body: Center(child: Text("Student not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
          title: Text(student!['name'] ?? 'Student Profile'),
        centerTitle: true,
      ),

      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: student!['profile_url'] != null
                      ? NetworkImage(student!['profile_url'])
                      : null,
                  child: student!['profile_url'] == null
                      ? const Icon(Icons.account_circle, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  student!['name'] ?? 'No Name',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(student!['email'] ?? 'No Email'),
                const SizedBox(height: 8),
                Text('CGPA: ${student!['cgpa'] ?? 'N/A'}'),
                const SizedBox(height: 4),
                Text('Semester: ${student!['semester'] ?? 'N/A'}'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final cvUrl = student!['cv_url'];
                    if (cvUrl != null && cvUrl.isNotEmpty) {
                      // TODO: Open CV link with url_launcher
                      // launchUrl(Uri.parse(cvUrl));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('CV not available')),
                      );
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('View CV'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
