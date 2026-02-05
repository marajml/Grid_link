import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupervisorRequestScreen extends StatefulWidget {
  const SupervisorRequestScreen({super.key});

  @override
  State<SupervisorRequestScreen> createState() =>
      _SupervisorRequestScreenState();
}

class _SupervisorRequestScreenState extends State<SupervisorRequestScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? student;
  List supervisors = [];
  String? selectedSupervisor;
  bool loading = true;
  bool alreadyRequested = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final userId = supabase.auth.currentUser!.id;

    /// Student info
    final studentRes = await supabase
        .from('userauth')
        .select('id, name, arid_no, semester, email')
        .eq('id', userId)
        .single();

    /// Supervisors (ROLE BASED)
    final supervisorRes = await supabase
        .from('userauth')
        .select('id, name, email')
        .eq('role', 'supervisor');

    /// Check if request already sent
    final checkReq = await supabase
        .from('teacher_request')
        .select()
        .eq('student_id', userId)
        .maybeSingle();

    setState(() {
      student = studentRes;
      supervisors = supervisorRes;
      alreadyRequested = checkReq != null;
      loading = false;
    });
  }

  Future<void> submitRequest() async {
    final userId = supabase.auth.currentUser!.id;

    await supabase.from('teacher_request').insert({
      'student_id': userId,
      'supervisor_id': selectedSupervisor,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request sent")),
    );

    setState(() {
      alreadyRequested = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Supervisor Request")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// STUDENT PROFILE
            const Text("Student Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Text("Name: ${student!['name']}"),
            Text("ARID No: ${student!['arid_no']}"),
            Text("Semester: ${student!['semester']}"),
            Text("Email: ${student!['email']}"),

            const Divider(height: 30),

            /// SUPERVISOR LIST
            const Text("Select Supervisor",
                style: TextStyle(fontSize: 16)),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedSupervisor,
              items: supervisors.map<DropdownMenuItem<String>>((sup) {
                return DropdownMenuItem<String>(
                  value: sup['id'] as String,
                  child: Text(sup['name']),
                );
              }).toList(),

              onChanged: alreadyRequested
                  ? null
                  : (String? value) {
                setState(() {
                  selectedSupervisor = value;
                });
              },

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),


            const SizedBox(height: 25),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedSupervisor == null || alreadyRequested)
                    ? null
                    : submitRequest,
                child: Text(
                  alreadyRequested ? "Request Sent" : "Submit Request",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
