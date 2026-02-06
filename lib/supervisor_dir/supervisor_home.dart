import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_link/supervisor_dir/student_request_letter.dart';
import 'package:grid_link/supervisor_dir/waiting_letter.dart';
class SupervisorHome extends StatefulWidget {
  const SupervisorHome({super.key});

  @override
  State<SupervisorHome> createState() => _SupervisorHomeState();
}

class _SupervisorHomeState extends State<SupervisorHome> {
  int _currentstate=0;
  List<Widget> _page=[
    SupervisorForwardedRequestsScreen(),
    SupervisorRequestsScreen (),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          IconButton(onPressed: (){
            context.go("/login");
          }, icon: Icon(Icons.logout))
        ],
      ),
      body:
          _page[_currentstate],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentstate,
          onTap: (val){
          _currentstate=val;
          setState(() {

          });

          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled,),label: "Home",),
        BottomNavigationBarItem(icon: Icon(Icons.perm_contact_calendar_outlined,),label: "Pending",)
      ]),
    );
  }
}
