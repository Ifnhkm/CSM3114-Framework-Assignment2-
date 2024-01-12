import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_app/models/project.dart';

class ProjectService {
  final String _baseUrl =
      'https://projectapp-6f108-default-rtdb.asia-southeast1.firebasedatabase.app';

  Future<List<Project>> getProjects({required String username}) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/UserData/${username}/projects.json'));

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);

      if (data == null) {
        return [];
      }

      final List<Project> projects = [];

      data.forEach((projectId, projectData) {
        final project = Project(
          id: projectId,
          name: projectData['name'],
          description: projectData['description'],
          activities: [],
          deadline: projectData['deadline'] != null
              ? DateTime.parse(projectData['deadline'])
              : DateTime.now(),
          status: '',
        );
        projects.add(project);
      });

      return projects;
    } else {
      throw Exception('Failed to load projects');
    }
  }

  Future<String> addProject(String username, Project project) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/UserData/${username}/projects.json'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': project.name,
        'description': project.description,
        'activities': project.activities,
        'deadline': project.deadline.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['name'];
    } else {
      throw Exception('Failed to add project');
    }
  }

  Future<void> updateProject(
      String username, String projectId, Project updatedProject) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/UserData/${username}/projects/$projectId.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': updatedProject.name,
          'description': updatedProject.description,
          'deadline': updatedProject.deadline.toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update project');
      }
    } catch (error) {
      print('Error updating project: $error');
      throw Exception('Failed to update project');
    }
  }

  Future<void> deleteProject(String username, String projectId) async {
    final response = await http.delete(
        Uri.parse('$_baseUrl/UserData/${username}/projects/$projectId.json'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete project');
    }
  }

  Future<void> addActivityToProject(
      String username, String projectId, String activity) async {
    final response = await http.post(
      Uri.parse(
          '$_baseUrl/UserData/${username}/projects/$projectId/activities.json'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'activity': activity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add activity to project');
    }
  }

  Future<void> removeActivityFromProject(
      String username, String projectId, String activityId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$_baseUrl/UserData/${username}/projects/$projectId/activities/$activityId.json'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print(
            'Removed activity from project: $projectId, activityId: $activityId');
      } else {
        print(
            'Failed to remove activity from project: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error removing activity from project: $e');
    }
  }

  Future<List<String>> getActivitiesForProject(
      String username, String projectId) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/UserData/${username}/projects/$projectId/activities.json'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);

      if (data == null) {
        return [];
      }

      final List<String> activities = [];

      data.forEach((activityId, activityData) {
        activities.add(activityData['activity']);
      });

      return activities;
    } else {
      throw Exception('Failed to load activities for project');
    }
  }

  Future<String> getActivityId(
      String username, String projectId, String activityName) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/UserData/${username}/projects/$projectId/activities.json'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);

      if (data != null) {
        for (final activityId in data.keys) {
          if (data[activityId]['activity'] == activityName) {
            return activityId;
          }
        }
      }
    } else {
      throw Exception('Failed to get activity ID for project');
    }

    throw Exception('Activity not found');
  }

  Future<void> updateActivityInProject(String username, String projectId,
      String activityId, String newActivity, DateTime newDeadline) async {
    try {
      final response = await http.patch(
        Uri.parse(
            '$_baseUrl/UserData/${username}/projects/$projectId/activities/$activityId.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'activity': newActivity,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update activity in project');
      }
    } catch (e) {
      print('Error updating activity in project: $e');
      throw Exception('Failed to update activity in project');
    }
  }

  Future<void> saveActivityStatus(
      String username, String projectId, String activityId, bool status) async {
    try {
      final response = await http.patch(
        Uri.parse(
            '$_baseUrl/UserData/${username}/projects/$projectId/activities/$activityId.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save activity status');
      }
    } catch (e) {
      print('Error saving activity status: $e');
      throw Exception('Failed to save activity status');
    }
  }

  Future<Map<String, bool>> getActivityStatusesForProject(
      String username, String projectId) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/UserData/${username}/projects/$projectId/activities.json'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);

      if (data == null) {
        return {};
      }

      final Map<String, bool> activityStatuses = {};

      data.forEach((activityId, activityData) {
        activityStatuses[activityData['activity']] =
            activityData['status'] ?? false;
      });

      return activityStatuses;
    } else {
      throw Exception('Failed to load activity statuses for project');
    }
  }

  Future<double> getProjectProgress(String username, String projectId) async {
    try {
      final activityStatuses =
          await getActivityStatusesForProject(username, projectId);
      final totalActivities = activityStatuses.length;

      if (totalActivities == 0) {
        return 0.0;
      }

      final completedActivities =
          activityStatuses.values.where((status) => status).length;

      final progressPercentage =
          (completedActivities / totalActivities) * 100.0;

      return progressPercentage;
    } catch (e) {
      print('Error calculating project progress: $e');
      throw Exception('Failed to calculate project progress');
    }
  }

  Future<void> updateProjectStatus(
      String username, String projectId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/UserData/${username}/projects/$projectId.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': status,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update project status');
      }
    } catch (error) {
      print('Error updating project status: $error');
      throw Exception('Failed to update project status');
    }
  }

  Future<String> getProjectStatus(String username, String projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/UserData/${username}/projects/$projectId.json'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String status = data['status'];
        return status;
      } else {
        throw 'Failed to get project status. Status code: ${response.statusCode}';
      }
    } catch (error) {
      throw 'Error getting project status: $error';
    }
  }
}
