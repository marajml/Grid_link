import 'package:flutter/material.dart';
class Studentpost extends StatefulWidget {
  const Studentpost({super.key});

  @override
  State<Studentpost> createState() => _StudentpostState();
}

class _StudentpostState extends State<Studentpost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student post "),
        backgroundColor: Colors.blueAccent,
        centerTitle:true,
      ),

    );
  }
}
