import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_link/utils/userauth_display.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


import '../services/letter_pdf_service.dart';

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
  bool forwarding = false;

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
          'id,student_id,office_status,office_letter_url,office_letter_name,supervisor_signed_pdf',
        )
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
        .select(
            'id,name,arid_no,semester,email,role,profile_image_url,profile_url,company_logo_url')
        .eq('id', id)
        .single();
  }

  Future<void> openFile(String bucket, String path) async {
    final url = supabase.storage.from(bucket).getPublicUrl(path);
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  bool _isPdfOfficeLetter(Map<String, dynamic> req) {
    final name = (req['office_letter_name'] as String?)?.toLowerCase() ?? '';
    if (name.endsWith('.pdf')) return true;
    final path = (req['office_letter_url'] as String?)?.toLowerCase() ?? '';
    return path.endsWith('.pdf');
  }

  /// Merges the office PDF with this supervisor's saved signature and uploads
  /// to [signed_letters]. Word letters are not supported until a server
  /// docx→PDF conversion (Phase 2) exists.
  Future<void> forwardSignedPdfToStudent(
    String requestId,
    Map<String, dynamic> req,
  ) async {
    if (!_isPdfOfficeLetter(req)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Office must upload a PDF letter for automatic signature. '
            'Word (.doc/.docx) needs a server conversion step (Phase 2).',
          ),
          duration: Duration(seconds: 6),
        ),
      );
      return;
    }

    final officePath = req['office_letter_url'] as String?;
    if (officePath == null || officePath.isEmpty) return;

    setState(() => forwarding = true);
    try {
      final supervisorId = supabase.auth.currentUser!.id;
      final profile = await supabase
          .from('userauth')
          .select('supervisor_signature_path')
          .eq('id', supervisorId)
          .single();

      final sigPath = profile['supervisor_signature_path'] as String?;
      if (sigPath == null || sigPath.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No signature on file. Ask an admin to set supervisor_signature_path '
              'or register a new supervisor account with a signature image.',
            ),
            duration: Duration(seconds: 6),
          ),
        );
        return;
      }

      final officeBytes = await supabase.storage
          .from('letters_from_office')
          .download(officePath);

      final sigBytes = await supabase.storage
          .from('supervisor_signatures')
          .download(sigPath);

      final merged = mergeSignatureOntoPdfLastPage(
        pdfBytes: Uint8List.fromList(officeBytes),
        signatureImageBytes: Uint8List.fromList(sigBytes),
      );

      final storagePath = 'signed_letters/$requestId.pdf';
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/signed_$requestId.pdf');
      await tempFile.writeAsBytes(merged);

      await supabase.storage.from('signed_letters').upload(
            storagePath,
            tempFile,
            fileOptions: const FileOptions(
              contentType: 'application/pdf',
              upsert: true,
            ),
          );
      await tempFile.delete();

      await supabase.from('teacher_request').update({
        'supervisor_signed_pdf': storagePath,
      }).eq('id', requestId);

      await fetchRequests();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed PDF sent to student')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => forwarding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supervisor requests')),
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
                    final stAv = userauthAvatarUrl(student);

                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: stAv != null
                                      ? NetworkImage(stAv)
                                      : null,
                                  child: stAv == null
                                      ? const Icon(Icons.person, size: 36)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student['name']?.toString() ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'ARID: ${student['arid_no']} | Semester: ${student['semester']}',
                                      ),
                                      Text(student['email']?.toString() ?? ''),
                                      TextButton(
                                        onPressed: () => context.push(
                                          '/studentprofile/${student['id']}',
                                        ),
                                        child: const Text('View full profile'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 25),

                            if (officeStatus != 'approved')
                              const Text(
                                'Office status: PENDING\n'
                                'Waiting for student office approval...',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            if (officeStatus == 'approved' &&
                                officeLetter == null)
                              const Text(
                                'Office approved.\nWaiting for letter upload...',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            if (officeLetter != null && signedPdf == null) ...[
                              const Text(
                                'Office letter received',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.download),
                                label: Text(
                                  _isPdfOfficeLetter(req)
                                      ? 'Download office letter (PDF)'
                                      : 'Download office letter (Word)',
                                ),
                                onPressed: () => openFile(
                                  'letters_from_office',
                                  officeLetter as String,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                icon: forwarding
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.forward_to_inbox),
                                label: const Text('Forward to student (PDF)'),
                                onPressed: forwarding
                                    ? null
                                    : () => forwardSignedPdfToStudent(
                                          req['id'] as String,
                                          req,
                                        ),
                              ),
                            ],

                            if (signedPdf != null)
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 6),
                                  Text('Signed PDF sent to student'),
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
