import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_link/student_dir/provider/studentappliedjobsprovider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentAppliedJobsScreen extends StatefulWidget {
  const StudentAppliedJobsScreen({super.key});

  @override
  State<StudentAppliedJobsScreen> createState() =>
      _StudentAppliedJobsScreenState();
}

class _StudentAppliedJobsScreenState extends State<StudentAppliedJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentAppliedJobsProvider>().fetchAppliedJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentAppliedJobsProvider>();

    if (provider.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Applied Jobs")),
      body: ListView.builder(
        itemCount: provider.jobs.length,
        itemBuilder: (context, index) {
          final job = provider.jobs[index];
          final company = job['company_post']['userauth'];

          final status = job['status'];

          return Card(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
            backgroundImage: company['company_logo_url'] != null
            ? NetworkImage(company['company_logo_url'])
                : null,
            child: company['company_logo_url'] == null
                ? Icon(Icons.business)
                : null,
          ),

                  title: Text(company['name']),
                  subtitle: Text(job['company_post']['title']),
                ),

                Text(
                  "Status: ${status.toUpperCase()}",
                  style: TextStyle(
                    color: status == 'confirmed'
                        ? Colors.green
                        : status == 'rejected'
                        ? Colors.red
                        : Colors.orange,
                  ),
                ),

                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: status == 'confirmed'
                      ? () {
                    context.go("/letterRequest");
                  }
                      : null,
                  child: const Text("Send Request"),
                ),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
