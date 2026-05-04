import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_link/student_dir/provider/student_post.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Studentpost extends StatefulWidget {
  const Studentpost({super.key});

  @override
  State<Studentpost> createState() => _StudentpostState();
}

class _StudentpostState extends State<Studentpost> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();

  String _postType = StudentPost.postTypeJob;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentPost>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Post"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              final id = Supabase.instance.client.auth.currentUser?.id;
              if (id != null) context.push('/studentprofile/$id');
            },
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'My profile',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                Text(
                  "Post for",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 8.h),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: StudentPost.postTypeJob,
                      label: Text("Job"),
                      icon: Icon(Icons.work_outline, size: 18),
                    ),
                    ButtonSegment<String>(
                      value: StudentPost.postTypeInternship,
                      label: Text("Internship"),
                      icon: Icon(Icons.school_outlined, size: 18),
                    ),
                  ],
                  selected: {_postType},
                  onSelectionChanged: (set) {
                    setState(() => _postType = set.first);
                  },
                ),

                SizedBox(height: 20.h),

                TextFormField(
                  controller: title,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Title is required";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter title",
                    labelText: "Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                TextFormField(
                  controller: description,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Description is required";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter description",
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        provider.imagepicker();
                      },
                      icon: const Icon(Icons.image),
                    ),
                    SizedBox(width: 8.w),
                    provider.image != null
                        ? Image.file(
                            provider.image!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : const Text("Image not selected"),
                  ],
                ),

                SizedBox(height: 20.h),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_key.currentState!.validate()) return;

                      if (provider.image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select an image"),
                          ),
                        );
                        return;
                      }

                      await provider.addpost(
                        title.text.trim(),
                        description.text.trim(),
                        _postType,
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Post added successfully"),
                        ),
                      );

                      title.clear();
                      description.clear();
                      setState(() => _postType = StudentPost.postTypeJob);
                    },
                    child: const Text("Post"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
