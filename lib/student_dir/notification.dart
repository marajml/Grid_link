import 'package:flutter/material.dart';
import 'package:grid_link/student_dir/supervisorresponsepage.dart';

import 'applied_jobs_page.dart';



class NotificationStudent extends StatefulWidget {
  const NotificationStudent({super.key});

  @override
  State<NotificationStudent> createState() => _NotificationStudentState();
}

class _NotificationStudentState extends State<NotificationStudent> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    StudentAppliedJobsScreen(),
     Supervisorresponsepage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pending),
            label: "Pending Applications",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Supervisor Response",
          ),
        ],
      ),
    );
  }
}
