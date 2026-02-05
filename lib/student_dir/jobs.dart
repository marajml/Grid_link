  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:go_router/go_router.dart';
  import 'package:provider/provider.dart';
  import '../provider/job_provider.dart';

  class StudentJobFeed extends StatefulWidget {
    const StudentJobFeed({super.key});

    @override
    State<StudentJobFeed> createState() => _StudentJobFeedState();
  }

  class _StudentJobFeedState extends State<StudentJobFeed> {
    @override
    void initState() {
      super.initState();
      Provider.of<JobProvider>(context, listen: false).fetchJobs();
    }

    @override
    Widget build(BuildContext context) {
      final provider = context.watch<JobProvider>();

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text("Jobs"),
          centerTitle: true,
          actions: [
            IconButton(onPressed: (){
              context.go("/login");
            }, icon: Icon(Icons.logout))
          ],
        ),

        body: provider.jobs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: provider.jobs.length,
          itemBuilder: (context, index) {
            final job = provider.jobs[index];
            final isLiked = provider.userLikedMap[job['id']] ?? false;
            final likeCount = provider.likeCountMap[job['id']] ?? 0;
            final applied = provider.appliedMap[job['id']] ?? false;
            final comments = provider.commentMap[job['id']] ?? [];

            return Card(
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Company info
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: job['userauth']['company_logo_url'] != null
                          ? NetworkImage(job['userauth']['company_logo_url'])
                          : null,
                      child: job['userauth']['company_logo_url'] == null
                          ? const Icon(Icons.business)
                          : null,
                    ),
                    title: Text(job['userauth']['name'] ?? "Company"),
                  ),
                  const Divider(),

                  /// Job Image
                  if (job['image'] != null)
                    Image.network(job['image'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job['title'] ?? "",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(job['description'] ?? ""),
                      ],
                    ),
                  ),
                  const Divider(),

                  /// Actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Like button
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked
                                  ? CupertinoIcons.heart_fill
                                  : CupertinoIcons.heart,
                              color: isLiked ? Colors.red : Colors.grey,
                              size: 28,
                            ),
                            onPressed: () {
                              provider.likePost(job['id']);
                            },
                          ),
                          Text("$likeCount"),
                        ],
                      ),

                      // Comment button
                      IconButton(
                        icon: const Icon(Icons.comment),
                        onPressed: () {
                          final controller = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Add Comment"),
                              content: TextField(controller: controller),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    if (controller.text.trim().isNotEmpty) {
                                      provider.addComment(
                                          job['id'], controller.text);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text("Send"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Apply button
                      ElevatedButton(
                        onPressed: applied
                            ? null // Button is disabled if already applied
                            : () async {
                          // Trigger the provider method
                         await provider.applyJob(job['id']);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Applied Successfully")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: applied ? Colors.grey : Colors.blue,
                        ),
                        child: Text(
                          applied ? "Applied" : "Apply",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),

                  /// Display comments under post
                  if (comments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: comments.map((c) {
                          return ListTile(
                            dense: true,
                            title: Text(c['userauth']['name'] ?? "Student"),
                            subtitle: Text(c['comment'] ?? ""),
                          );
                        }).toList(),
                      ),
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
