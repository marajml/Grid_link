import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../authprovider/signupprovider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController name = TextEditingController();
  final TextEditingController fname = TextEditingController();
  final TextEditingController aridno = TextEditingController();
  final TextEditingController gpa = TextEditingController();
  final TextEditingController startdate = TextEditingController();
  final TextEditingController enddate = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController registrationNo = TextEditingController();

  // CV pick variables
  String? cvFileName;
  String? cvFilePath;

  Future<void> pickCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        cvFileName = result.files.single.name;
        cvFilePath = result.files.single.path;
      });
    }
  }

  // Year picker
  Future<void> pickYear(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.year.toString();
      });
    }
  }

  String? selectedRole;
  int? semesterselect;

  final List<String> roles = [
    'Student',
    'Company',
    'Supervisor',
    'Student Office',
  ];
  final List<int> semester = [1, 2, 3, 4, 5, 6, 7, 8];

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Signupdata>(context);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'GridLink',
                      style: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Name
                  TextFormField(
                    controller: name,
                    decoration: inputDecoration('Name', Icons.account_circle),
                    validator: (value) {
                      if (value!.isEmpty) return "Enter The Name";
                      return null;
                    },
                  ),
                  SizedBox(height: 7.h),

                  // Email
                  TextFormField(
                    controller: email,
                    decoration: inputDecoration('Email', Icons.email),
                    validator: (value) {
                      if (value!.isEmpty) return "Enter Email";
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 7.h),

                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: inputDecoration('Select Role', Icons.people),
                    items: roles
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => selectedRole = value),
                    validator: (value) {
                      if (value == null) return 'Select a role';
                      return null;
                    },
                  ),
                  SizedBox(height: 7.h),

                  // Student fields
                  if (selectedRole == 'Student') ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: aridno,
                            decoration: inputDecoration(
                              "Arid No",
                              Icons.numbers,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) return "Enter Arid No";
                              if (!RegExp(
                                r'^[0-9]{2}-[A-Za-z]+-[0-9]{3}$',
                              ).hasMatch(value.trim())) {
                                return 'Format is 22-Arid-123';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: semesterselect,
                            decoration: inputDecoration(
                              "Semester",
                              Icons.numbers,
                            ),
                            items: semester
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.toString()),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => semesterselect = value),
                            validator: (value) {
                              if (value == null) return "Select semester";
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: fname,
                      decoration: inputDecoration("Father Name", Icons.person),
                      validator: (value) {
                        if (value!.isEmpty) return "Enter Father Name";
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Year picker & CV
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: startdate,
                            readOnly: true,
                            decoration: inputDecoration(
                              'Start Year',
                              Icons.date_range,
                            ),
                            onTap: () => pickYear(context, startdate),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Select start year'
                                : null,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextFormField(
                            controller: enddate,
                            readOnly: true,
                            decoration: inputDecoration(
                              'End Year',
                              Icons.date_range,
                            ),
                            onTap: () => pickYear(context, enddate),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Select end year'
                                : null,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    GestureDetector(
                      onTap: pickCV,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          cvFileName ?? 'Upload CV (PDF)',
                          style: TextStyle(
                            color: cvFileName == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],

                  // Supervisor fields
                  if (selectedRole == 'Supervisor') ...[
                    TextFormField(
                      controller: registrationNo,
                      decoration: inputDecoration(
                        'Registration No',
                        Icons.badge,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return "Enter Registration No";
                        if (!RegExp(
                          r'^[0-9]{2}-[A-Za-z]+-[0-9]{3}$',
                        ).hasMatch(value.trim())) {
                          return 'Format is 22-Arid-123';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                  ],

                  // Company fields
                  if (selectedRole == 'Company') ...[
                    TextFormField(
                      controller: location,
                      decoration: inputDecoration(
                        'Location',
                        Icons.location_city,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return "Enter Location";
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: city,
                      decoration: inputDecoration('City', Icons.location_city),
                      validator: (value) {
                        if (value!.isEmpty) return "Enter City";
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    Text("UPload your logo"),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            provider.pickImage();
                          },
                          icon: Icon(Icons.image),
                        ),
                        ?provider.Image != null
                            ? Image.file(
                                File(provider.Image!.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ],
                    ),
                  ],

                  // Password
                  if (selectedRole != null) ...[
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration: inputDecoration('Password', Icons.lock),
                      validator: (value) {
                        if (value!.isEmpty) return "Enter Password";
                        return null;
                      },
                    ),
                    SizedBox(height: 25.h),

                    // Signup button
                    SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();

                                if (!_formkey.currentState!.validate()) return;

                                if (selectedRole == 'Student' &&
                                    cvFilePath == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please upload your CV'),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  await provider.signupuser(
                                    role: selectedRole,
                                    name: name.text,
                                    email: email.text,
                                    password: password.text,
                                    father_name: selectedRole == 'Student'
                                        ? fname.text
                                        : null,
                                    arid_no: selectedRole == 'Student'
                                        ? aridno.text
                                        : null,
                                    semester: selectedRole == 'Student'
                                        ? semesterselect
                                        : null,
                                    gpa: selectedRole == 'Student'
                                        ? double.tryParse(gpa.text)
                                        : null,
                                    start_year: selectedRole == 'Student'
                                        ? int.tryParse(startdate.text)
                                        : null,
                                    end_year: selectedRole == 'Student'
                                        ? int.tryParse(enddate.text)
                                        : null,
                                    cvFilePath: selectedRole == 'Student'
                                        ? cvFilePath
                                        : null,
                                    registration_no:
                                        selectedRole == 'Supervisor'
                                        ? registrationNo.text
                                        : null,
                                    location: selectedRole == 'Company'
                                        ? location.text
                                        : null,
                                    city: selectedRole == 'Company'
                                        ? city.text
                                        : null,
                                  );

                                  if (selectedRole == 'Student')
                                    context.go("/Studentdashboard");
                                  if (selectedRole == 'Supervisor')
                                    context.go("/supervisorhome");
                                  if (selectedRole == 'Company')
                                    context.go("/companydashboard");
                                  if (selectedRole == 'Student Office')
                                    context.go("/officehome");
                                } catch (e) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Signup error: $e'),
                                      ),
                                    );
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),

                    // Login redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("I already have an account!"),
                        TextButton(
                          onPressed: () {
                            context.go("/login");
                          },
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
