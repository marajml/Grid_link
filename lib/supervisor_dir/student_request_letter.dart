import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_link/utils/userauth_display.dart';
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

  /// 🔹 FETCH SUPERVISOR REQUESTS
  Future<void> fetchRequests() async {
    final supervisorId = supabase.auth.currentUser!.id;

    final res = await supabase
        .from('teacher_request')
        .select(
        'id,status,student_id,forwarded_to_office,office_letter_url')
        .eq('supervisor_id', supervisorId)
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
        .select(
            'id,name,arid_no,semester,email,role,profile_image_url,profile_url,company_logo_url')
        .eq('id', id)
        .single();
  }

  /// 🔹 APPROVE / REJECT
  Future<void> updateStatus(String id, String status) async {
    await supabase.from('teacher_request').update({
      'status': status,
      'forwarded_at': DateTime.now().toIso8601String(),
    }).eq('id', id);

    fetchRequests();
  }

  /// 🔹 FORWARD TO STUDENT OFFICE
  Future<void> forwardToOffice(String requestId) async {
    await supabase.from('teacher_request').update({
      'status': 'forwarded',
      'forwarded_to_office': true,
      'forwarded_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);

    fetchRequests();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Request forwarded to Student Office")),
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
              final stAv = userauthAvatarUrl(student);

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                stAv != null ? NetworkImage(stAv) : null,
                            child: stAv == null
                                ? const Icon(Icons.person, size: 32)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student['name']?.toString() ?? '',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text("ARID: ${student['arid_no']}"),
                                Text(
                                    "Semester: ${student['semester']}"),
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

                      const SizedBox(height: 12),

                      /// 🔹 STATUS
                      Text(
                        "Status: ${req['status'].toString().toUpperCase()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 12),

                      /// 🔹 PENDING → APPROVE / REJECT
                      if (req['status'] == 'pending') ...[
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  updateStatus(req['id'], 'approved'),
                              child: const Text("Approve"),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: () =>
                                  updateStatus(req['id'], 'rejected'),
                              child: const Text("Reject"),
                            ),
                          ],
                        ),
                      ],

                      /// 🔹 APPROVED → FORWARD
                      if (req['status'] == 'approved') ...[
                        ElevatedButton(
                          onPressed: () =>
                              forwardToOffice(req['id']),
                          child: const Text(
                              "Forward to Student Office"),
                        ),
                      ],

                      /// 🔹 FORWARDED → WAIT
                      if (req['status'] == 'forwarded' &&
                          req['office_letter_url'] == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "Waiting for Student Office letter...",
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500),
                          ),
                        ),

                      /// 🔹 OFFICE UPLOADED
                      if (req['office_letter_url'] != null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "Office letter uploaded ✔",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
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
