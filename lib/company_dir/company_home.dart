import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_link/student_dir/student_post_feed_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompanyHomescreen extends StatefulWidget {
  const CompanyHomescreen({super.key});

  @override
  State<CompanyHomescreen> createState() => _CompanyHomescreenState();
}

class _CompanyHomescreenState extends State<CompanyHomescreen> {
  String name = "";
  String logoUrl = "";
  final supabase = Supabase.instance.client;

  // Fetch company posts
  Future<List<Map<String, dynamic>>> getCompanyPosts() async {
    final user = supabase.auth.currentUser;

    final response = await supabase
        .from('company_post')
        .select()
        .eq('company_id', user!.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch company info
  Future<void> companydata()async{

    final user=supabase.auth.currentUser;
    final data = await supabase
        .from('userauth')
        .select("name,company_logo_url")
        .eq('id', user!.id)
        .single();
    setState(() {
      name = data['name'] ?? "";
      logoUrl = data['company_logo_url'] ?? "";
    });


  }

  @override
  void initState() {
    companydata();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'My posts'),
                Tab(text: 'Student posts'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getCompanyPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final posts = snapshot.data ?? [];

                  if (posts.isEmpty) {
                    return const Center(child: Text('No posts found'));
                  }

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      int likesCount = post['likes_count'] ?? 0;

                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          context.push('/Studentlist/${post['id']}');
                        },
                        child: Card(
                          margin: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: logoUrl.isNotEmpty
                                          ? NetworkImage(logoUrl)
                                          : null,
                                      child: logoUrl.isEmpty
                                          ? const Icon(
                                              Icons.business,
                                              color: Colors.blueAccent,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        name.isEmpty ? 'Loading...' : name,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  post['title'] ?? 'No Title',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  post['description'] ?? 'No Description',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                if ((post['image'] ?? '')
                                    .toString()
                                    .trim()
                                    .isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      post['image'],
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: const Center(
                                              child:
                                                  Icon(Icons.image, size: 50)),
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.thumb_up_alt_outlined,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () async {
                                        likesCount++;
                                        setState(() {});

                                        await supabase
                                            .from('company_post')
                                            .update({'likes_count': likesCount})
                                            .eq('id', post['id']);
                                      },
                                    ),
                                    Text('$likesCount likes'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const StudentPostFeedView(),
            ],
          ),
        ),
      ),
    );
  }
}
