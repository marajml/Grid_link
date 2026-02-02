import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'companyprovider/companyprovider.dart';
import 'dart:io';

class Company_job_post extends StatefulWidget {
  const Company_job_post({super.key});

  @override
  State<Company_job_post> createState() => _Company_job_postState();
}

class _Company_job_postState extends State<Company_job_post> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController titrlecontrol = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Company_postdeta>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Post a Job")),
        body: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titrlecontrol,
                    decoration: InputDecoration(
                      hintText: "Title Job",
                      labelText: "Title Job",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Title Missing";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 5,
                    minLines: 3,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Description of the job',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  Text("Pick an Image"),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          provider.pickImage();
                        },
                        icon: Icon(Icons.image),
                      ),
                      SizedBox(width: 10.w),
                      provider.image != null
                          ? Image.file(
                        File(provider.image!.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                          : Text("No image selected"),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_key.currentState!.validate()) {
                          await provider.addJobPost(
                            titrlecontrol.text.trim(),
                            descriptionController.text.trim(),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Job Posted Successfully")),
                          );


                        }
                      },
                      child: Text("Post Job"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
