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

  Future<void> fetchRequests() async {
    final supervisorId = supabase.auth.currentUser!.id;

    final res = await supabase
        .from('teacher_request')
        .select(
        'id,student_id,office_status,office_letter_url,supervisor_signed_pdf')
        .eq('supervisor_id', supervisorId)
        .order('forwarded_at', ascending: false);

    setState(() {
      requests = List<Map<String, dynamic>>.from(res);
      loading = false;
    });
  }

  Future<Map<String, dynamic>> getStudent(String id) async {
    return await supabase
        .from('userauth')
        .select('name,arid_no,semester,email')
        .eq('id', id)
        .single();
  }

  Future<void> openFile(String bucket, String path) async {
    final url = supabase.storage.from(bucket).getPublicUrl(path);
    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

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
    }).eq('id', requestId);

    fetchRequests();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PDF sent to student")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Supervisor Requests")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          final officeStatus =
          req['office_status']?.toString().toLowerCase();
          final officeLetter = req['office_letter_url'];
          final signedPdf = req['supervisor_signed_pdf'];

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
                              fontWeight: FontWeight.bold)),
                      Text(
                          "ARID: ${student['arid_no']} | Semester: ${student['semester']}"),
                      Text(student['email']),
                      const Divider(height: 25),

                      /// ❌ OFFICE NOT APPROVED
                      if (officeStatus != 'approved')
                        const Text(
                          "Office Status: PENDING\nWaiting for student office approval...",
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500),
                        ),

                      /// ⏳ APPROVED BUT LETTER NOT UPLOADED
                      if (officeStatus == 'approved' &&
                          officeLetter == null)
                        const Text(
                          "Office approved.\nWaiting for letter upload...",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500),
                        ),

                      /// 📄 LETTER RECEIVED
                      if (officeLetter != null &&
                          signedPdf == null) ...[
                        const Text(
                          "Office Letter Received",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text(
                              "Download Office Letter (Word)"),
                          onPressed: () => openFile(
                              'letters_from_office',
                              officeLetter),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon:
                          const Icon(Icons.upload_file),
                          label:
                          const Text("Upload PDF for Student"),
                          onPressed: () =>
                              uploadSignedPdf(req['id']),
                        ),
                      ],

                      /// ✅ COMPLETED
                      if (signedPdf != null)
                        Row(
                          children: const [
                            Icon(Icons.check_circle,
                                color: Colors.green),
                            SizedBox(width: 6),
                            Text(
                                "Signed PDF sent to student"),
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
