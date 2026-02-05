import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  String name="";
  String logoUrl="";
  final supabase= Supabase.instance.client;


  Future<void> companydata()async{

    final user=supabase.auth.currentUser;
    final data = await supabase
        .from('userauth')
        .select("name,company_logo_url")
        .eq('id', user!.id)
        .single();
    setState(() {
      name = data['name'] ?? "";
      logoUrl = data['company_logo_url'] ?? "";
    });


  }
  logiout() async {
    await supabase.auth.signOut();
    context.go("/login");
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
        // company logo show ho  aur company ka anme b
        backgroundColor: Colors.blueAccent,

        title: Row(
          children: [
            // Company Logo
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: logoUrl.isNotEmpty
                  ? NetworkImage(logoUrl)
                  : null,
              child: logoUrl.isEmpty
                  ? Icon(Icons.business, color: Colors.blueAccent)
                  : null,
            ),

            const SizedBox(width: 10),

            // Company Name
            Expanded(
              child: Text(
                name.isEmpty ? "Loading..." : name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: (){
            logiout();

          }, icon: Icon(Icons.logout))
        ],
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
