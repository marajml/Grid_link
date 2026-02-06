import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  List<Map<String, dynamic>> supervisors = [];
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

    /// student data
    final studentRes = await supabase
        .from('userauth')
        .select('id,name,arid_no,semester,email')
        .eq('id', userId)
        .single();

    /// supervisors list
    final supervisorRes = await supabase
        .from('userauth')
        .select('id,name,email')
        .eq('role', 'Supervisor');

    /// already requested?
    final reqCheck = await supabase
        .from('teacher_request')
        .select()
        .eq('student_id', userId)
        .maybeSingle();

    setState(() {
      student = studentRes;
      supervisors = List<Map<String, dynamic>>.from(supervisorRes);
      alreadyRequested = reqCheck != null;
      loading = false;
    });
  }

  Future<void> submitRequest() async {
    final userId = supabase.auth.currentUser!.id;

    await supabase.from('teacher_request').insert({
      'student_id': userId,
      'supervisor_id': selectedSupervisor,
      'status': 'pending', // ❗ MUST
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request Sent Successfully")),
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
      appBar: AppBar(title: const Text("Supervisor Request"),
        actions: [
          IconButton(onPressed: (){
            context.go  ("/login");
          }, icon: Icon(Icons.logout))
        ],),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// STUDENT INFO
            const Text("Student Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Text("Name: ${student!['name']}"),
            Text("ARID No: ${student!['arid_no']}"),
            Text("Semester: ${student!['semester']}"),
            Text("Email: ${student!['email']}"),

            const Divider(height: 30),

            /// SUPERVISOR DROPDOWN
            const Text("Select Supervisor"),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedSupervisor,
              items: supervisors.map((sup) {
                return DropdownMenuItem<String>(
                  value: sup['id'],
                  child: Text(sup['name']),
                );
              }).toList(),
              onChanged: alreadyRequested
                  ? null
                  : (value) {
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
                onPressed:
                (selectedSupervisor == null || alreadyRequested)
                    ? null
                    : submitRequest,
                child: Text(
                  alreadyRequested ? "Request Sent" : "Submit Request",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
