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

  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> confirmedJobs = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    final studentId = supabase.auth.currentUser!.id;

    final res = await supabase
        .from('teacher_request')
        .select('''
          id,
          status,
          supervisor_id,
          supervisor_signed_pdf,
          supervisor:supervisor_id ( name, email )
        ''')
        .eq('student_id', studentId)
        .order('created_at', ascending: false);

    confirmedJobs = List<Map<String, dynamic>>.from(
      await supabase
          .from('job_applications')
          .select('id,job_id,company_post(title,company_id)')
          .eq('student_id', studentId)
          .eq('status', 'confirmed'),
    );

    if (!mounted) return;
    setState(() {
      requests = List<Map<String, dynamic>>.from(res);
      loading = false;
    });
  }

  Future<void> openPdf(String path) async {
    final url =
        supabase.storage.from('signed_letters').getPublicUrl(path);

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> forwardToCompany(
    String companyId,
    Map<String, dynamic> req,
  ) async {
    final pdf = req['supervisor_signed_pdf'];
    if (pdf == null) return;

    await supabase.from('company_recommendations').insert({
      'student_id': supabase.auth.currentUser!.id,
      'company_id': companyId,
      'recommendation_pdf': pdf,
      'supervisor_id': req['supervisor_id'],
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recommendation sent to company')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request status')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchAll,
              child: requests.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 48),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'No supervisor requests yet. Use the Request tab to send one.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final req in requests) ...[
                          _RequestCard(
                            request: req,
                            confirmedJobs: confirmedJobs,
                            onOpenPdf: openPdf,
                            onForwardToCompany: forwardToCompany,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
            ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.confirmedJobs,
    required this.onOpenPdf,
    required this.onForwardToCompany,
  });

  final Map<String, dynamic> request;
  final List<Map<String, dynamic>> confirmedJobs;
  final Future<void> Function(String path) onOpenPdf;
  final Future<void> Function(String companyId, Map<String, dynamic> req)
      onForwardToCompany;

  @override
  Widget build(BuildContext context) {
    final sup = request['supervisor'] as Map<String, dynamic>?;
    final status = request['status'] as String? ?? 'pending';
    final pdfPath = request['supervisor_signed_pdf'] as String?;
    final hasPdf = pdfPath != null;

    final statusText = status == 'rejected'
        ? 'Supervisor rejected this request'
        : !hasPdf
            ? 'Waiting for signed letter'
            : 'Recommendation letter ready';

    final statusColor = status == 'rejected'
        ? Colors.red
        : hasPdf
            ? Colors.green
            : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              statusText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 12),
            if (sup != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person),
                title: Text(sup['name'] as String? ?? ''),
                subtitle: Text(sup['email'] as String? ?? ''),
                trailing: const Text('Teacher'),
              ),
            if (hasPdf) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Download signed letter (PDF)'),
                onPressed: () => onOpenPdf(pdfPath),
              ),
            ],
            if (hasPdf && confirmedJobs.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Forward to confirmed companies',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...confirmedJobs.map((job) {
                final company = job['company_post'] as Map<String, dynamic>?;
                if (company == null) return const SizedBox.shrink();
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(company['title'] as String? ?? ''),
                    subtitle: const Text('Status: Confirmed'),
                    trailing: ElevatedButton(
                      onPressed: () => onForwardToCompany(
                        company['company_id'] as String,
                        request,
                      ),
                      child: const Text('Send'),
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
