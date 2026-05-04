import 'package:flutter/material.dart';
import 'package:grid_link/student_dir/post.dart';

import 'home.dart';
import 'jobs.dart';
import 'letter_request.dart';
import 'notification.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {

  int _currentIndex = 0;
  final List<Widget> _page = [
    HomeScreen(),
    const Studentpost(),
    const SupervisorRequestScreen(),
    NotificationStudent(),
    StudentJobFeed(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body:
        _page[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
          onTap: (index){
          _currentIndex = index;
          setState(() {

          });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,


          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled,size: 20,),label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded,size: 20,),label: "Post"),
            BottomNavigationBarItem(icon: Icon(Icons.mail_outline,size: 20,),label: "Request"),
            BottomNavigationBarItem(icon: Icon(Icons.notification_add,size: 20,),label: "Notification"),
            BottomNavigationBarItem(icon: Icon(Icons.work_outline,size: 20,),label: "Jobs"),
          ]),
    );
  }
}
