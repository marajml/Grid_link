import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentRequestStatusScreen extends StatefulWidget {
  const StudentRequestStatusScreen({super.key});

  @override
  State<StudentRequestStatusScreen> createState() =>
      _StudentRequestStatusScreenState();
}

class _StudentRequestStatusScreenState
    extends State<StudentRequestStatusScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? request;
  Map<String, dynamic>? supervisor;
  List<Map<String, dynamic>> confirmedJobs = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    final studentId = supabase.auth.currentUser!.id;

    /// 🔹 FETCH REQUEST
    request = await supabase
        .from('teacher_request')
        .select('status,supervisor_id,supervisor_signed_pdf')
        .eq('student_id', studentId)
        .single();

    /// 🔹 FETCH SUPERVISOR
    if (request!['supervisor_id'] != null) {
      supervisor = await supabase
          .from('userauth')
          .select('name,email')
          .eq('id', request!['supervisor_id'])
          .single();
    }

    /// 🔹 FETCH CONFIRMED JOBS
    confirmedJobs = List<Map<String, dynamic>>.from(
      await supabase
          .from('job_applications')
          .select(
          'id,job_id,company_post(title,company_id)')
          .eq('student_id', studentId)
          .eq('status', 'confirmed'),
    );

    setState(() => loading = false);
  }

  Future<void> openPdf(String path) async {
    final url = supabase.storage
        .from('signed_letters')
        .getPublicUrl(path);

    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

  /// 🔹 SEND LETTER TO COMPANY
  Future<void> forwardToCompany(
      String companyId) async {
    await supabase.from('company_recommendations').insert({
      'student_id': supabase.auth.currentUser!.id,
      'company_id': companyId,
      'recommendation_pdf':
      request!['supervisor_signed_pdf'],
      'supervisor_id': request!['supervisor_id'],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              "Recommendation sent to company")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Request Status")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            /// 🔹 STATUS
            Text(
              request!['status'] == 'rejected'
                  ? "❌ Supervisor rejected your request"
                  : request!['supervisor_signed_pdf'] ==
                  null
                  ? "Waiting for signed letter"
                  : "📄 Recommendation letter ready",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                  request!['supervisor_signed_pdf'] !=
                      null
                      ? Colors.green
                      : Colors.orange),
            ),

            const SizedBox(height: 16),

            /// 🔹 SUPERVISOR INFO
            if (supervisor != null)
              Card(
                child: ListTile(
                  leading:
                  const Icon(Icons.person),
                  title:
                  Text(supervisor!['name']),
                  subtitle:
                  Text(supervisor!['email']),
                  trailing:
                  const Text("Supervisor"),
                ),
              ),

            const SizedBox(height: 20),

            /// 📄 DOWNLOAD PDF
            if (request!['supervisor_signed_pdf'] !=
                null)
              ElevatedButton.icon(
                icon:
                const Icon(Icons.download),
                label: const Text(
                    "Download Recommendation Letter"),
                onPressed: () => openPdf(
                    request![
                    'supervisor_signed_pdf']),
              ),

            const SizedBox(height: 30),

            /// 🏢 CONFIRMED COMPANIES
            if (request!['supervisor_signed_pdf'] !=
                null &&
                confirmedJobs.isNotEmpty) ...[
              const Text(
                "Forward to Confirmed Companies",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...confirmedJobs.map((job) {
                final company =
                job['company_post'];

                return Card(
                  child: ListTile(
                    title: Text(company['title']),
                    subtitle: const Text(
                        "Status: Confirmed"),
                    trailing: ElevatedButton(
                      onPressed: () =>
                          forwardToCompany(
                              company['company_id']),
                      child:
                      const Text("Send"),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
