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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        centerTitle: true,
        title: const Text(
          "Job Feed",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                context.go("/login");
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: provider.jobs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        itemCount: provider.jobs.length,
        itemBuilder: (context, index) {
          final job = provider.jobs[index];
          final isLiked =
              provider.userLikedMap[job['id']] ?? false;
          final likeCount =
              provider.likeCountMap[job['id']] ?? 0;
          final applied =
              provider.appliedMap[job['id']] ?? false;
          final comments =
              provider.commentMap[job['id']] ?? [];

          return Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                /// 🔹 Company Header
                Padding(
                  padding:
                  const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                        Colors.grey.shade200,
                        backgroundImage: job[
                        'userauth']
                        [
                        'company_logo_url'] !=
                            null
                            ? NetworkImage(job[
                        'userauth']
                        [
                        'company_logo_url'])
                            : null,
                        child: job['userauth'][
                        'company_logo_url'] ==
                            null
                            ? const Icon(Icons.business)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['userauth']['name'] ??
                                "Company",
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Hiring Now",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.more_vert,
                          color:
                          Colors.grey.shade600),
                    ],
                  ),
                ),

                /// 🔹 Job Image
                if (job['image'] != null)
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(16),
                    child: Image.network(
                      job['image'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                /// 🔹 Job Info
                Padding(
                  padding:
                  const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'] ?? "",
                        style:
                        const TextStyle(
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job['description'] ?? "",
                        style:
                        const TextStyle(
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                /// 🔹 Action Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: [


                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked
                                  ? Icons.thumb_up_alt_outlined
                                  : Icons.thumb_up_alt_outlined,
                              color: isLiked
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              provider.likePost(
                                  job['id']);
                            },
                          ),
                          Text(
                            "$likeCount",
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      /// 💬 Comment
                      IconButton(
                        icon: const Icon(
                            Icons
                                .mode_comment_outlined),
                        onPressed: () {
                          final controller =
                          TextEditingController();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled:
                            true,
                            shape:
                            const RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.vertical(
                                  top:
                                  Radius.circular(
                                      20)),
                            ),
                            builder: (_) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                        context)
                                        .viewInsets
                                        .bottom,
                                    left: 16,
                                    right: 16,
                                    top: 16),
                                child: Column(
                                  mainAxisSize:
                                  MainAxisSize
                                      .min,
                                  children: [
                                    const Text(
                                      "Add Comment",
                                      style: TextStyle(
                                          fontSize:
                                          18,
                                          fontWeight:
                                          FontWeight
                                              .bold),
                                    ),
                                    const SizedBox(
                                        height:
                                        12),
                                    TextField(
                                      controller:
                                      controller,
                                      decoration:
                                      InputDecoration(
                                        hintText:
                                        "Write something...",
                                        border:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                        12),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (controller
                                            .text
                                            .trim()
                                            .isNotEmpty) {
                                          provider.addComment(
                                              job[
                                              'id'],
                                              controller
                                                  .text);
                                          Navigator.pop(
                                              context);
                                        }
                                      },
                                      child:
                                      const Text(
                                          "Send"),
                                    ),
                                    const SizedBox(
                                        height:
                                        20),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),

                      /// 🚀 Apply Button
                      ElevatedButton(
                        onPressed: applied
                            ? null
                            : () async {
                          await provider
                              .applyJob(
                              job[
                              'id']);
                          ScaffoldMessenger.of(
                              context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Applied Successfully"),
                            ),
                          );
                        },
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor: applied
                              ? Colors.grey
                              : Colors.blueAccent,
                          padding:
                          const EdgeInsets
                              .symmetric(
                              horizontal:
                              24,
                              vertical:
                              12),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                30),
                          ),
                        ),
                        child: Text(
                          applied
                              ? "Applied"
                              : "Apply Now",
                          style:
                          const TextStyle(
                              color:
                              Colors.white,
                              fontWeight:
                              FontWeight
                                  .bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          );
        },
      ),
    );
  }
}
