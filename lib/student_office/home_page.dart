import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
        .select(
        'id,student_id,supervisor_id,office_status,office_letter_name,office_letter_url')
        .eq('status', 'forwarded')
        .eq('forwarded_to_office', true)
        .order('created_at');

    setState(() {
      requests = List<Map<String, dynamic>>.from(res);
      loading = false;
    });
  }

  Future<Map<String, dynamic>> getUser(String id) async {
    return await supabase
        .from('userauth')
        .select('name,arid_no,email')
        .eq('id', id)
        .single();
  }

  /// 📄 Upload Word Letter
  Future<void> uploadLetter(String requestId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;
    final storagePath = 'office_letters/$requestId-$fileName';

    await supabase.storage
        .from('letters_from_office')
        .upload(
      storagePath,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    await supabase.from('teacher_request').update({
      'office_letter_url': storagePath,
      'office_letter_name': fileName,
    }).eq('id', requestId);

    fetchRequests();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Letter uploaded successfully")),
    );
  }

  /// ✅ Approve / Reject
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

  Color statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
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
          ? const Center(child: Text("No office requests"))
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          final officeStatus = req['office_status'] ?? 'pending';

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
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// STUDENT
                      Text("Student",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey)),
                      Text("${student['name']} (${student['arid_no']})"),
                      Text(student['email']),

                      const Divider(),

                      /// SUPERVISOR
                      Text("Supervisor",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey)),
                      Text(supervisor['name']),
                      Text(supervisor['email']),

                      const Divider(height: 25),

                      /// STATUS
                      Row(
                        children: [
                          const Text("Status: "),
                          Text(
                            officeStatus.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor(officeStatus)),
                          )
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// FILE INFO
                      if (req['office_letter_name'] != null)
                        Row(
                          children: [
                            const Icon(Icons.description,
                                color: Colors.blue),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                req['office_letter_name'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 10),

                      /// UPLOAD BUTTON
                      ElevatedButton.icon(
                        onPressed: () => uploadLetter(req['id']),
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Upload Word Letter"),
                      ),

                      const SizedBox(height: 10),

                      /// APPROVE / REJECT
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: officeStatus == 'approved'
                                ? null
                                : () => officeDecision(
                                req['id'], 'approved'),
                            child: const Text("Approve"),
                          ),
                          OutlinedButton(
                            onPressed: officeStatus == 'rejected'
                                ? null
                                : () => officeDecision(
                                req['id'], 'rejected'),
                            child: const Text("Reject"),
                          ),
                        ],
                      ),
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
