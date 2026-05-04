import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_link/supervisor_dir/student_request_letter.dart';
import 'package:grid_link/supervisor_dir/waiting_letter.dart';
import 'package:grid_link/utils/userauth_display.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupervisorHome extends StatefulWidget {
  const SupervisorHome({super.key});

  @override
  State<SupervisorHome> createState() => _SupervisorHomeState();
}

class _SupervisorHomeState extends State<SupervisorHome> {
  final supabase = Supabase.instance.client;
  int _currentstate = 0;
  String _name = '';
  String? _avatarUrl;

  final List<Widget> _page = [
    SupervisorForwardedRequestsScreen(),
    SupervisorRequestsScreen(),
  ];

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final data = await supabase
        .from('userauth')
        .select(
            'name,role,profile_image_url,profile_url,company_logo_url')
        .eq('id', user.id)
        .maybeSingle();
    if (!mounted || data == null) return;
    setState(() {
      _name = data['name']?.toString() ?? '';
      _avatarUrl = userauthAvatarUrl(Map<String, dynamic>.from(data));
    });
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    context.go("/login");
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage:
                  _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
              child: _avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.blue, size: 22)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _name.isEmpty ? 'Supervisor' : _name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              final id = supabase.auth.currentUser?.id;
              if (id != null) context.push('/studentprofile/$id');
            },
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'My profile',
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _page[_currentstate],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentstate,
        onTap: (val) {
          _currentstate = val;
          setState(() {});
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_contact_calendar_outlined),
            label: "Pending",
          ),
        ],
      ),
    );
  }
}
