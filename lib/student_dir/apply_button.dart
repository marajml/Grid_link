import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/job_provider.dart';



class ApplyButton extends StatelessWidget {
  final String jobId;

  ApplyButton({required this.jobId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<JobProvider>().applyJob(jobId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Applied Successfully")),
        );
      },
      child: Text("Apply"),
    );
  }
}
