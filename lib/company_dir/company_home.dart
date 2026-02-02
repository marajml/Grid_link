import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompanyHomescreen extends StatefulWidget {
  const CompanyHomescreen({super.key});

  @override
  State<CompanyHomescreen> createState() => _CompanyHomescreenState();
}

class _CompanyHomescreenState extends State<CompanyHomescreen> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCompanyPosts() async {
    final response = await supabase
        .from('company_post')
        .select()
        .order('created_at', ascending: false); // latest posts first
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Company Posts"),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: getCompanyPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final posts = snapshot.data ?? [];

            if (posts.isEmpty) {
              return const Center(child: Text("No posts found"));
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                        (post['image'] ?? '').toString().trim().isNotEmpty
                            ? post['image'].toString().trim()
                            : 'https://via.placeholder.com/150',

                      ),

                    ),


                    title: Text(post['title'] ?? 'No Title'),
                    subtitle: Text(post['description'] ?? 'No Description'),
                  ),


                );
              },
            );
          },

        ),
      ),
    );
  }
}
