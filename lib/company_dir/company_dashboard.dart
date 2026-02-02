import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'company_home.dart';
import 'companyprovider/provider_home.dart';
import 'jobpost.dart';
class CompanyHome extends StatefulWidget {
  const CompanyHome({super.key});

  @override
  State<CompanyHome> createState() => _CompanyHomeState();
}

class _CompanyHomeState extends State<CompanyHome> {
  String name = "";

  Future<void> companydata()async{
    final supabase= Supabase.instance.client;
    final user=supabase.auth.currentUser;
    final data = await supabase
        .from('userauth')
        .select('role')
        .eq('id', user!.id)
        .single();
    final name=data['name'] ?? " ";


  }
  @override
  void initState() {
    // TODO: implement initState
    companydata();
    super.initState();
  }


   int _curretnindex=0;
  final List<Widget> _page=[
    CompanyHomescreen(),
    Company_job_post()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(name),
      ),
      body:
      _page[_curretnindex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _curretnindex,
          onTap: (index){
          _curretnindex=index;
          setState(() {

          });

          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,

          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home,size: 20,),label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.add_card,size: 20,),label: "Jobs"),


          ]),

    );
  }
}
