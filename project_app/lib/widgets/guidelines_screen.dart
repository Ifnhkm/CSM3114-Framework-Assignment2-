import 'package:flutter/material.dart';

class GuidelinesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guidelines'),
        centerTitle: true,
        backgroundColor: Color(0xFF2E6872),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 4.0,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Project Tracking and Monitoring App Guidelines',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ListTile(
                      leading: Icon(Icons.check, color: Colors.green),
                      title: Text(
                        'Log in to your account using your username and password.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.check, color: Colors.green),
                      title: Text(
                        'Once logged in, you will be directed to the project list screen.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.check, color: Colors.green),
                      title: Text(
                        'View and manage your projects from the project list screen.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.check, color: Colors.green),
                      title: Text(
                        'Add new projects or edit existing ones using the provided features.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.check, color: Colors.green),
                      title: Text(
                        'Stay organized by updating project details and progress regularly.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.check, color: Colors.green),
                      title: Text(
                        'Use the app\'s notification features to stay informed about deadlines.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4.0,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Additional Tips',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ListTile(
                      leading: Icon(Icons.lightbulb, color: Colors.yellow),
                      title: Text(
                        'Explore advanced features by accessing the app settings.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.lightbulb, color: Colors.yellow),
                      title: Text(
                        'Collaborate with team members by sharing project updates.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
