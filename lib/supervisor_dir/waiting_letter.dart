import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class SupervisorForwardedRequestsScreen extends StatefulWidget {
  const SupervisorForwardedRequestsScreen({super.key});

  @override
  State<SupervisorForwardedRequestsScreen> createState() =>
      _SupervisorForwardedRequestsScreenState();
}

class _SupervisorForwardedRequestsScreenState
    extends State<SupervisorForwardedRequestsScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  // 🔹 FETCH ALL REQUESTS OF SUPERVISOR
  Future<void> fetchRequests() async {
    final supervisorId = supabase.auth.currentUser!.id;

    final res = await supabase
        .from('teacher_request')
        .select(
        'id,student_id,office_response,office_letter_url,supervisor_signed_pdf,forwarded_at')
        .eq('supervisor_id', supervisorId)
        .order('forwarded_at', ascending: false);

    setState(() {
      requests = List<Map<String, dynamic>>.from(res);
      loading = false;
    });
  }

  // 🔹 STUDENT INFO
  Future<Map<String, dynamic>> getStudent(String id) async {
    return await supabase
        .from('userauth')
        .select('name,arid_no,semester,email')
        .eq('id', id)
        .single();
  }

  // 🔹 OPEN FILE
  Future<void> openFile(String bucket, String path) async {
    final url = supabase.storage.from(bucket).getPublicUrl(path);
    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

  // 🔹 UPLOAD SIGNED PDF
  Future<void> uploadSignedPdf(String requestId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final path = 'signed_letters/$requestId.pdf';

    await supabase.storage.from('signed_letters').upload(
      path,
      file,
      fileOptions:
      const FileOptions(contentType: 'application/pdf'),
    );

    await supabase.from('teacher_request').update({
      'supervisor_signed_pdf': path,
      'signed_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);

    fetchRequests();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signed PDF uploaded")),
    );
  }

  Color statusColor(String? status) {
    if (status == 'approved') return Colors.green;
    if (status == 'rejected') return Colors.red;
    return Colors.orange;
  }

  String statusText(String? status) {
    if (status == 'approved') return "APPROVED";
    if (status == 'rejected') return "REJECTED";
    return "WAITING FOR STUDENT OFFICE";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Supervisor Requests Status")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text("No requests found"))
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];

          return FutureBuilder<Map<String, dynamic>>(
            future: getStudent(req['student_id']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: LinearProgressIndicator(),
                );
              }

              final student = snapshot.data!;
              final officeStatus = req['office_response'];

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(student['name'],
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold)),
                      Text(
                          "ARID: ${student['arid_no']} | Semester: ${student['semester']}"),
                      Text(student['email']),

                      const Divider(height: 20),

                      Text(
                        "STATUS: ${statusText(officeStatus)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                          statusColor(officeStatus),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// 🔹 ONLY WHEN APPROVED
                      if (officeStatus == 'approved') ...[
                        if (req['office_letter_url'] !=
                            null)
                          ElevatedButton.icon(
                            icon: const Icon(
                                Icons.download),
                            label: const Text(
                                "Download Office Letter (Word)"),
                            onPressed: () => openFile(
                              'office_letters',
                              req['office_letter_url'],
                            ),
                          ),

                        if (req['supervisor_signed_pdf'] == null)
                          ElevatedButton.icon(
                            icon: const Icon(
                                Icons.upload_file),
                            label: const Text(
                                "Upload Signed PDF"),
                            onPressed: () =>
                                uploadSignedPdf(req['id']),
                          ),

                        if (req['supervisor_signed_pdf'] !=
                            null)
                          const Padding(
                            padding:
                            EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(
                                    Icons
                                        .check_circle,
                                    color:
                                    Colors.green),
                                SizedBox(width: 6),
                                Text(
                                    "Signed PDF sent to student"),
                              ],
                            ),
                          ),
                      ],
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
