import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'companyprovider/applied_students_provider.dart';
import 'package:grid_link/utils/userauth_display.dart';

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
              final raw = app['userauth'];
              if (raw is! Map) {
                return const SizedBox.shrink();
              }
              final student = Map<String, dynamic>.from(raw);

              final avatar = userauthAvatarUrl(student);
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  onTap: () {
                    context.push('/studentprofile/${student['id']}');
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        avatar != null ? NetworkImage(avatar) : null,
                    child: avatar == null
                        ? const Icon(Icons.account_circle_sharp)
                        : null,
                  ),
                  title: Text(student['name'] ?? ''),
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
                      if (app['status'] == 'confirmed')
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.red),
                          onPressed: () {
                            context.push('/studentprofile/${student['id']}');
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
