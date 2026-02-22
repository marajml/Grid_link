import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyRecommendationsScreen extends StatefulWidget {
  const CompanyRecommendationsScreen({super.key});

  @override
  State<CompanyRecommendationsScreen> createState() =>
      _CompanyRecommendationsScreenState();
}

class _CompanyRecommendationsScreenState
    extends State<CompanyRecommendationsScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> letters = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchLetters();
  }

  Future<void> fetchLetters() async {
    final companyId = supabase.auth.currentUser!.id;

    final res = await supabase
        .from('company_recommendations')
        .select(
        'recommendation_pdf,sent_at,student_id,supervisor_id')
        .eq('company_id', companyId)
        .order('sent_at', ascending: false);

    letters = List<Map<String, dynamic>>.from(res);

    setState(() => loading = false);
  }

  Future<void> openPdf(String path) async {
    final url = supabase.storage
        .from('signed_letters')
        .getPublicUrl(path);

    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

  Future<Map<String, dynamic>> getUser(
      String id) async {
    return await supabase
        .from('userauth')
        .select('name,email')
        .eq('id', id)
        .single();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text("Recommendation Letters"),
      ),
      body: loading
          ? const Center(
          child: CircularProgressIndicator())
          : letters.isEmpty
          ? const Center(
        child:
        Text("No recommendation letters"),
      )
          : ListView.builder(
        itemCount: letters.length,
        itemBuilder: (context, index) {
          final letter = letters[index];

          return FutureBuilder(
            future: Future.wait([
              getUser(letter['student_id']),
              getUser(letter['supervisor_id']),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding:
                  EdgeInsets.all(12),
                  child:
                  LinearProgressIndicator(),
                );
              }

              final student =
              snapshot.data![0]
              as Map<String, dynamic>;
              final supervisor =
              snapshot.data![1]
              as Map<String, dynamic>;

              return Card(
                margin:
                const EdgeInsets.all(12),
                child: ListTile(
                  leading: const Icon(
                      Icons.picture_as_pdf),
                  title:
                  Text(student['name']),
                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                          "Supervisor: ${supervisor['name']}"),
                      Text(
                          supervisor['email']),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                        Icons.download),
                    onPressed: () =>
                        openPdf(letter[
                        'recommendation_pdf']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
