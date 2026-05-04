import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_link/utils/userauth_display.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupervisorRequestScreen extends StatefulWidget {
  const SupervisorRequestScreen({super.key});

  @override
  State<SupervisorRequestScreen> createState() =>
      _SupervisorRequestScreenState();
}

class _SupervisorRequestScreenState extends State<SupervisorRequestScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? student;
  List<Map<String, dynamic>> supervisors = [];
  List<Map<String, dynamic>> myRequests = [];
  String? selectedSupervisor;
  bool loading = true;

  Set<String> get _requestedSupervisorIds => myRequests
      .map((r) => r['supervisor_id'] as String?)
      .whereType<String>()
      .toSet();

  List<Map<String, dynamic>> get _availableSupervisors =>
      supervisors.where((s) => !_requestedSupervisorIds.contains(s['id'] as String)).toList();

  Map<String, dynamic>? get _selectedSupervisorRow {
    final id = selectedSupervisor;
    if (id == null) return null;
    for (final s in supervisors) {
      if (s['id'] == id) return s;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final userId = supabase.auth.currentUser!.id;

    final studentRes = await supabase
        .from('userauth')
        .select(
            'id,name,arid_no,semester,email,role,profile_image_url,profile_url,company_logo_url')
        .eq('id', userId)
        .single();

    final supervisorRes = await supabase
        .from('userauth')
        .select(
            'id,name,email,role,profile_image_url,profile_url,company_logo_url')
        .eq('role', 'Supervisor');

    final requestsRes = await supabase
        .from('teacher_request')
        .select(
            'id,status,supervisor_id,supervisor:supervisor_id ( name, email, role, profile_image_url, profile_url, company_logo_url )')
        .eq('student_id', userId)
        .order('created_at', ascending: false);

    if (!mounted) return;
    setState(() {
      student = studentRes;
      supervisors = List<Map<String, dynamic>>.from(supervisorRes);
      myRequests = List<Map<String, dynamic>>.from(requestsRes);
      if (selectedSupervisor != null &&
          _requestedSupervisorIds.contains(selectedSupervisor)) {
        selectedSupervisor = null;
      }
      loading = false;
    });
  }

  Future<void> submitRequest() async {
    final userId = supabase.auth.currentUser!.id;
    final supId = selectedSupervisor;
    if (supId == null) return;
    if (_requestedSupervisorIds.contains(supId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You have already sent a request to this teacher.')),
      );
      return;
    }

    try {
      await supabase.from('teacher_request').insert({
        'student_id': userId,
        'supervisor_id': supId,
        'status': 'pending',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent successfully')),
      );
      setState(() => selectedSupervisor = null);
      await loadData();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      final isUnique = e.code == '23505' || e.message.contains('unique');
      final msg = isUnique
          ? 'You can only send one request per teacher.'
          : (e.message.isEmpty ? 'Could not send request' : e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final studentRow = student!;
    final studentAvatar = userauthAvatarUrl(studentRow);
    final selectedSup = _selectedSupervisorRow;
    final selectedSupAvatar = userauthAvatarUrl(selectedSup);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor request'),
        actions: [
          IconButton(
            onPressed: () {
              final id = supabase.auth.currentUser?.id;
              if (id != null) context.push('/studentprofile/$id');
            },
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'My profile',
          ),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const Text(
              'Your profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: studentAvatar != null
                      ? NetworkImage(studentAvatar)
                      : null,
                  child: studentAvatar == null
                      ? const Icon(Icons.person, size: 36)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentRow['name']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('ARID: ${studentRow['arid_no']}'),
                      Text('Semester: ${studentRow['semester']}'),
                      Text('Email: ${studentRow['email']}'),
                      TextButton(
                        onPressed: () => context
                            .push('/studentprofile/${studentRow['id']}'),
                        child: const Text('View full profile'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            const Text(
              'Your requests',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (myRequests.isEmpty)
              Text(
                'No requests yet. Choose a teacher below.',
                style: TextStyle(color: Colors.grey.shade700),
              )
            else
              ...myRequests.map((r) {
                final sup = r['supervisor'] as Map<String, dynamic>?;
                final name = sup?['name'] ?? 'Teacher';
                final reqStatus = (r['status'] as String?) ?? 'pending';
                final supId = r['supervisor_id'] as String?;
                final supAvatar = userauthAvatarUrl(sup);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: supId != null
                        ? () => context.push('/studentprofile/$supId')
                        : null,
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: supAvatar != null
                          ? NetworkImage(supAvatar)
                          : null,
                      child: supAvatar == null
                          ? const Icon(Icons.person_outline)
                          : null,
                    ),
                    title: Text(name),
                    subtitle: Text('Status: ${reqStatus.toUpperCase()}'),
                  ),
                );
              }),
            const Divider(height: 30),
            const Text(
              'New request',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_availableSupervisors.isEmpty)
              Text(
                supervisors.isEmpty
                    ? 'No supervisors are registered yet.'
                    : 'You have already requested all available teachers.',
                style: TextStyle(color: Colors.grey.shade700),
              )
            else ...[
              const Text('Select teacher'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                // Controlled selection; `initialValue` does not update on rebuild.
                // ignore: deprecated_member_use
                value: selectedSupervisor,
                items: _availableSupervisors.map((sup) {
                  return DropdownMenuItem<String>(
                    value: sup['id'] as String,
                    child: Text(sup['name'] as String? ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedSupervisor = value);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              if (selectedSup != null) ...[
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: selectedSupAvatar != null
                        ? NetworkImage(selectedSupAvatar)
                        : null,
                    child: selectedSupAvatar == null
                        ? const Icon(Icons.school_outlined)
                        : null,
                  ),
                  title: Text(selectedSup['name']?.toString() ?? ''),
                  subtitle: Text(
                    selectedSup['email']?.toString() ?? '',
                  ),
                  trailing: TextButton(
                    onPressed: () => context.push(
                      '/studentprofile/${selectedSup['id']}',
                    ),
                    child: const Text('Profile'),
                  ),
                ),
              ],
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      selectedSupervisor == null ? null : submitRequest,
                  child: const Text('Submit request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
