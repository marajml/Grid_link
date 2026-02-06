import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Supervisorresponsepage extends StatefulWidget {
  const Supervisorresponsepage({super.key});

  @override
  State<Supervisorresponsepage> createState() =>
      _SupervisorresponsepageState();
}

class _SupervisorresponsepageState extends State<Supervisorresponsepage> {
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
        .select('''
        id,
        status,
        created_at,
        userauth!teacher_request_student_id_fkey(
          name,
          arid_no,
          semester,
          email
        )
      ''')
        .eq('supervisor_id', supervisorId)
        .eq('status', 'pending');

    setState(() {
      requests = List<Map<String, dynamic>>.from(res);
      loading = false;
    });
  }

  Future<void> updateStatus(String requestId, String status) async {
    await supabase
        .from('teacher_request')
        .update({'status': status})
        .eq('id', requestId);

    fetchRequests(); // refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Student Requests")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text("No Pending Requests"))
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          final student = req['Student'];

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: ${student['name']}"),
                  Text("ARID No: ${student['arid_no']}"),
                  Text("Semester: ${student['semester']}"),
                  Text("Email: ${student['email']}"),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            updateStatus(req['id'], 'approved'),
                        child: const Text("Approve"),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            updateStatus(req['id'], 'rejected'),
                        child: const Text("Reject"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

