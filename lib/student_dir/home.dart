import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_link/student_dir/student_post_feed_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            final id = Supabase.instance.client.auth.currentUser?.id;
            if (id != null) context.push('/studentprofile/$id');
          },
          icon: const Icon(Icons.account_circle_sharp),
          tooltip: 'My profile',
        ),
        title: const Text('Post'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: const StudentPostFeedView(),
    );
  }
}
