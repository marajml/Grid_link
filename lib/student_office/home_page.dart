import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class StudentOfficeRequestsScreen extends StatefulWidget {
  const StudentOfficeRequestsScreen({super.key});

  @override
  State<StudentOfficeRequestsScreen> createState() =>
      _StudentOfficeRequestsScreenState();
}

class _StudentOfficeRequestsScreenState
    extends State<StudentOfficeRequestsScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final res = await supabase
        .from('teacher_request')
        .select('id,status,student_id,supervisor_id,forwarded_at')
        .eq('status', 'forwarded')
        .eq('forwarded_to_office', true);

    setState(() {
      requests = List<Map<String, dynamic>>.from(res);
      loading = false;
    });
  }

  Future<Map<String, dynamic>> getUser(String id) async {
    return await supabase
        .from('userauth')
        .select('name, arid_no, email')
        .eq('id', id)
        .single();
  }

  /// 📄 UPLOAD WORD LETTER
  Future<void> uploadLetter(String requestId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final filePath = 'office_letters/$requestId.docx';

    await supabase.storage
        .from('letters_from_office')
        .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

    await supabase.from('teacher_request').update({
      'office_letter_url': filePath,
      'office_status': 'prepared',
      'office_processed_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);

    fetchRequests();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Letter uploaded for supervisor")),
    );
  }

  Future<void> officeDecision(String requestId, String decision) async {
    await supabase.from('teacher_request').update({
      'office_status': decision,
      'office_processed_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);

    fetchRequests();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request $decision")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Office Requests"),
        actions: [
          IconButton(
            onPressed: () => context.go("/login"),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text("No pending office requests"))
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];

          return FutureBuilder(
            future: Future.wait([
              getUser(req['student_id']),
              getUser(req['supervisor_id']),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: LinearProgressIndicator(),
                );
              }

              final student = snapshot.data![0];
              final supervisor = snapshot.data![1];

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Student",
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                      Text("Name: ${student['name']}"),
                      Text("ARID: ${student['arid_no']}"),
                      Text("Email: ${student['email']}"),

                      const Divider(),

                      const Text("Supervisor",
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                      Text("Name: ${supervisor['name']}"),
                      Text("Email: ${supervisor['email']}"),

                      const SizedBox(height: 15),

                      /// 📄 LETTER UPLOAD
                      ElevatedButton.icon(
                        onPressed: () =>
                            uploadLetter(req['id']),
                        icon: const Icon(Icons.upload_file),
                        label:
                        const Text("Upload Letter (Word)"),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                officeDecision(req['id'], 'approved'),
                            child: const Text("Approve"),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                officeDecision(req['id'], 'rejected'),
                            child: const Text("Reject"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
