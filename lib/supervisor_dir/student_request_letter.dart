import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupervisorRequestsScreen extends StatefulWidget {
  const SupervisorRequestsScreen({super.key});

  @override
  State<SupervisorRequestsScreen> createState() =>
      _SupervisorRequestsScreenState();
}

class _SupervisorRequestsScreenState extends State<SupervisorRequestsScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  /// 🔹 FETCH PENDING + APPROVED REQUESTS
  Future<void> fetchRequests() async {
    final supervisorId = supabase.auth.currentUser!.id;

    final res = await supabase
        .from('teacher_request')
        .select('id,status,student_id')
        .eq('supervisor_id', supervisorId)
        .or('status.eq.pending,status.eq.approved')
        .order('created_at', ascending: true);

    setState(() {
      requests = List<Map<String, dynamic>>.from(res);
      loading = false;
    });
  }

  /// 🔹 FETCH STUDENT DETAILS
  Future<Map<String, dynamic>> getStudent(String id) async {
    return await supabase
        .from('userauth')
        .select('name,arid_no,semester,email')
        .eq('id', id)
        .single();
  }

  /// 🔹 APPROVE OR REJECT
  Future<void> updateStatus(String id, String status) async {
    await supabase
        .from('teacher_request')
        .update({'status': status})
        .eq('id', id);

    fetchRequests();
  }

  /// 🔹 FORWARD TO STUDENT OFFICE (ONLY AFTER APPROVE)
  Future<void> forwardToOffice(String requestId) async {
    await supabase
        .from('teacher_request')
        .update({
      'status': 'forwarded',
      'forwarded_to_office': true,
      'forwarded_at': DateTime.now().toIso8601String(),
    })
        .eq('id', requestId);

    fetchRequests();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request forwarded to Student Office")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Requests")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text("No Requests Available"))
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

                      /// 🔹 STATUS BADGE
                      Text(
                        "Status: ${req['status'].toString().toUpperCase()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 12),

                      /// 🔹 BUTTON LOGIC
                      if (req['status'] == 'pending') ...[
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => updateStatus(
                                  req['id'], 'approved'),
                              child: const Text("Approve"),
                            ),
                            OutlinedButton(
                              onPressed: () => updateStatus(
                                  req['id'], 'rejected'),
                              child: const Text("Reject"),
                            ),
                          ],
                        ),
                      ],

                      if (req['status'] == 'approved') ...[
                        ElevatedButton(
                          onPressed: () =>
                              forwardToOffice(req['id']),
                          child: const Text(
                              "Forward to Student Office"),
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
