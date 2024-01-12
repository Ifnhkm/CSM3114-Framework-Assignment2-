import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:project_app/widgets/project_services.dart';

class ProjectProgressIndicator extends StatelessWidget {
  final String username;
  final String projectId;

  ProjectProgressIndicator({
    required this.username,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 157, 226, 217),
        borderRadius: BorderRadius.circular(15.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Project Progress',
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          FutureBuilder<double>(
            future: ProjectService().getProjectProgress(username, projectId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading progress',
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                  ),
                );
              } else {
                double progress = snapshot.data ?? 0.0;
                return CircularPercentIndicator(
                  radius: 65.0,
                  lineWidth: 8.0,
                  animation: true,
                  percent: progress / 100.0,
                  center: Text(
                    '${progress.toStringAsFixed(1)}%',
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Color.fromARGB(255, 7, 12, 75),
                );
              }
            },
          ),
          SizedBox(height: 12.0),
          Text(
            'Track the completion of your project',
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
          ),
        ],
      ),
    );
  }
}
