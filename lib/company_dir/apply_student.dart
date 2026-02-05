import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'companyprovider/applied_students_provider.dart';

class AppliedStudentsScreen extends StatefulWidget {
  final String jobId;
  const AppliedStudentsScreen({super.key, required this.jobId});

  @override
  State<AppliedStudentsScreen> createState() => _AppliedStudentsScreenState();
}

class _AppliedStudentsScreenState extends State<AppliedStudentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppliedStudentsProvider>(context, listen: false)
          .fetchStudents(widget.jobId);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),


        title: const Text("Applied Students"),
      ),
      body: Consumer<AppliedStudentsProvider>(
        builder: (_, provider, __) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.students.isEmpty) {
            return const Center(child: Text("No students applied"));
          }

          return ListView.builder(
            itemCount: provider.students.length,
            itemBuilder: (context, index) {
              final app = provider.students[index];
              final student = app['userauth'];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: student['profile_url'] != null && student['profile_url'].isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        student['profile_url'],
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ),
                    )
                        : Icon(Icons.account_circle_sharp),
                  ),


                  title: Text(student['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text("ARID: ${student['arid_no']}"),
                      // Text("GPA: ${student['gpa'] ?? 'N/A'}"),
                      Text("Status: ${app['status']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          provider.updateStatus(app['id'], 'confirmed');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          provider.updateStatus(app['id'], 'rejected');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.red),
                        onPressed: () {
                          context.go('/studentprofile/${student['id']}');
                        },
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
