import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class SupervisorHome extends StatefulWidget {
  const SupervisorHome({super.key});

  @override
  State<SupervisorHome> createState() => _SupervisorHomeState();
}

class _SupervisorHomeState extends State<SupervisorHome> {
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
      body: Center(child: Text("Supervisor HOme page")),
    );
  }
}
