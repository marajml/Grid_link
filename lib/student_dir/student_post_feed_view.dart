import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_link/student_dir/provider/student_post.dart';
import 'package:grid_link/utils/userauth_display.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
/// Read-only student post feed (same cards as student home). Used by company home.
class StudentPostFeedView extends StatefulWidget {
  const StudentPostFeedView({super.key});

  @override
  State<StudentPostFeedView> createState() => _StudentPostFeedViewState();
}

class _StudentPostFeedViewState extends State<StudentPostFeedView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<StudentPost>().fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentPost>();

    // Avoid showing "empty" before the first fetch runs (scheduled in initState).
    if (provider.isLoading || !provider.hasLoadedOnce) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<StudentPost>().fetchPosts(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: Text('No student posts yet')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<StudentPost>().fetchPosts(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: provider.posts.length,
        itemBuilder: (context, index) {
          final post = provider.posts[index];
          final user = post['userauth'] as Map<String, dynamic>?;
          final avatarUrl = userauthAvatarUrl(user);
          final postType =
              post['post_type'] as String? ?? StudentPost.postTypeJob;
          final isInternship =
              postType == StudentPost.postTypeInternship;
          final myId = Supabase.instance.client.auth.currentUser?.id;
          final authorId = post['student_id']?.toString();
          final isOwnPost =
              myId != null && authorId != null && myId == authorId;

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
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: authorId != null
                            ? () => context.push('/studentprofile/$authorId')
                            : null,
                        borderRadius: BorderRadius.circular(28),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl == null
                                  ? const Icon(Icons.person, size: 28)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  post['created_at'] != null
                                      ? post['created_at']
                                          .toString()
                                          .substring(0, 10)
                                      : '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (isOwnPost)
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                          onSelected: (value) async {
                            if (value != 'delete') return;
                            final id = post['id']?.toString();
                            if (id == null) return;

                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete post?'),
                                content: const Text(
                                  'This cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm != true || !context.mounted) return;

                            final err = await context
                                .read<StudentPost>()
                                .deletePost(id);
                            if (!context.mounted) return;
                            if (err != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(err)),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Post deleted'),
                                ),
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      color: Colors.red, size: 22),
                                  SizedBox(width: 10),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox(width: 8),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      avatar: Icon(
                        isInternship
                            ? Icons.school_outlined
                            : Icons.work_outline,
                        size: 18,
                        color: isInternship
                            ? Colors.deepPurple
                            : Colors.blue.shade700,
                      ),
                      label: Text(
                        isInternship ? 'Internship' : 'Job',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isInternship
                              ? Colors.deepPurple.shade800
                              : Colors.blue.shade800,
                        ),
                      ),
                      backgroundColor: isInternship
                          ? Colors.deepPurple.shade50
                          : Colors.blue.shade50,
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
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
                if (post['description'] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      post['description'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 12),
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.thumb_up_alt_outlined),
                        label: const Text('Like'),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.comment_outlined),
                        label: const Text('Comment'),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share'),
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
