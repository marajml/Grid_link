import 'package:flutter/material.dart';
import 'package:grid_link/student_dir/provider/student_post.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StudentPost>().fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentPost>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.account_circle_sharp)),
        title: const Text("Post "),
      centerTitle: true,
      backgroundColor: Colors.red,),
      body:ListView.builder(
        itemCount: provider.posts.length,
        itemBuilder: (context, index) {
          final post = provider.posts[index];
          final user = post['userauth'];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔹 HEADER (Profile + Name)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: user?['profile_url'] != null
                            ? NetworkImage(user!['profile_url'])
                            : null,
                        child: user?['profile_url'] == null
                            ? const Icon(Icons.person, size: 28)
                            : null,
                      ),
                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?['name'] ?? "Unknown",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            post['created_at'] != null
                                ? post['created_at'].toString().substring(0, 10)
                                : "",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Icon(Icons.more_vert, color: Colors.grey.shade600),
                    ],
                  ),
                ),

                /// 🔹 TITLE
                if (post['title'] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      post['title'],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 6),

                /// 🔹 DESCRIPTION
                if (post['description'] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      post['description'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                const SizedBox(height: 12),

                /// 🔹 IMAGE
                if (post['image_url'] != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    child: Image.network(
                      post['image_url'],
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),

                /// 🔹 ACTION BUTTONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.thumb_up_alt_outlined),
                        label: const Text("Like"),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.comment_outlined),
                        label: const Text("Comment"),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        label: const Text("Share"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

    );
  }
}
