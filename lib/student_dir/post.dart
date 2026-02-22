import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grid_link/student_dir/provider/student_post.dart';
import 'package:provider/provider.dart';

class Studentpost extends StatelessWidget {
  Studentpost({super.key});

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentPost>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Post"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 20.h),

              /// TITLE
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

              /// DESCRIPTION
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

              /// IMAGE PICKER
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

              /// POST BUTTON
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
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Post added successfully"),
                      ),
                    );

                    title.clear();
                    description.clear();
                  },
                  child: const Text("Post"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
