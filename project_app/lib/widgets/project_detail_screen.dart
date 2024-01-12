import 'package:flutter/material.dart';
import 'package:project_app/models/project.dart';
import 'package:project_app/widgets/notes_screen.dart';
import 'package:project_app/widgets/project_progress_indicator.dart';
import 'package:project_app/widgets/project_services.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  final Function onDeleteProject;
  final Function onAddActivity;
  final String username;

  ProjectDetailScreen({
    required this.project,
    required this.onDeleteProject,
    required this.onAddActivity,
    required this.username,
  });

  @override
  _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<String> _activities = [];
  List<String> _filteredActivities = [];
  Map<String, bool> _activityStatusMap = {};
  bool _showProjectDetails = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final activities = await ProjectService()
          .getActivitiesForProject(widget.username, widget.project.id);
      final activityStatuses = await ProjectService()
          .getActivityStatusesForProject(widget.username, widget.project.id);

      setState(() {
        _activities = activities;
        _filteredActivities = _activities;
        _activityStatusMap = Map.fromIterable(
          _activities,
          key: (activity) => activity,
          value: (activity) => activityStatuses[activity] ?? false,
        );
      });
    } catch (e) {
      print('Error loading activities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        backgroundColor: Color.fromARGB(255, 46, 104, 114),
        title: Text(
          'Project Details',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteProjectDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.note),
            onPressed: () => _openNotesScreen(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
            ),
          ),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Color(0xFFD2D6D6),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Project Information',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 4, 41, 71),
                            ),
                          ),
                          Switch(
                            value: _showProjectDetails,
                            onChanged: (value) =>
                                setState(() => _showProjectDetails = value),
                            activeColor: Colors.green,
                            activeTrackColor: Colors.lightGreenAccent,
                          ),
                        ],
                      ),
                      if (_showProjectDetails) ...[
                        SizedBox(height: 10.0),
                        _buildProjectInfoItem('Name ', widget.project.name),
                        SizedBox(height: 8.0),
                        _buildProjectInfoItem(
                            'Description ', widget.project.description),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Color(0xFF88D0BF),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(fontSize: 16.0),
                              decoration: InputDecoration(
                                labelText: 'Search Activity',
                                contentPadding: EdgeInsets.all(14.0),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      color: Colors.blue, width: 2.0),
                                ),
                              ),
                              onChanged: _filterActivities,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () =>
                                _filterActivities(_searchController.text),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle),
                            onPressed: () => _showAddActivityDialog(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Center(
                        child: Text(
                          'Activities',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      _buildActivitiesList(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ProjectProgressIndicator(
                  username: widget.username,
                  projectId: widget.project.id,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesList() {
    return _filteredActivities.isEmpty
        ? Text('No matching activities found.')
        : Container(
            height: 150.0,
            child: ListView.builder(
              itemCount: _filteredActivities.length,
              itemBuilder: _buildActivityItem,
            ),
          );
  }

  Widget _buildActivityItem(BuildContext context, int index) {
    final activityName = _filteredActivities[index];
    return ListTile(
      title: Row(
        children: [
          Checkbox(
            value: _getActivityStatus(activityName),
            onChanged: (value) =>
                _saveActivityStatus(activityName, value ?? false),
          ),
          Text(activityName),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _editActivity(activityName),
            icon: Icon(Icons.edit),
            color: Color(0xFF293881),
          ),
          IconButton(
            onPressed: () => _removeActivity(activityName),
            icon: Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  void _filterActivities(String query) {
    setState(() {
      _filteredActivities = _activities
          .where((activity) =>
              activity.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _removeActivity(String removedActivity) {
    setState(() {
      final int index = _filteredActivities.indexOf(removedActivity);

      if (index != -1) {
        final String removedActivityName = _filteredActivities[index];
        _removeActivityFromDatabase(removedActivityName);
      }
    });
  }

  Future<void> _removeActivityFromDatabase(String activityName) async {
    try {
      final int index = _activities.indexOf(activityName);

      if (index != -1) {
        final String activityId = await ProjectService().getActivityId(
          widget.username,
          widget.project.id,
          _activities[index],
        );

        await ProjectService().removeActivityFromProject(
          widget.username,
          widget.project.id,
          activityId,
        );

        setState(() {
          _activities.removeAt(index);
          _filteredActivities = List.from(_activities);
        });
      }
    } catch (e) {
      print('Error removing activity from database: $e');
    }
  }

  void _showAddActivityDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16.0),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Add Activity',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 12.0),
                TextField(
                  controller: _activityController,
                  style: TextStyle(fontSize: 14.0),
                  decoration: InputDecoration(
                    labelText: 'Activity Name',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _addActivity();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 88, 137, 155),
                    primary: Color.fromARGB(255, 0, 0, 0),
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.all(12.0),
                  ),
                  child: Text(
                    'Add Activity',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addActivity() async {
    try {
      if (_activityController.text.isNotEmpty) {
        await ProjectService().addActivityToProject(
          widget.username,
          widget.project.id,
          _activityController.text,
        );

        _activityController.clear();
        _loadActivities();
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error adding activity: $e');
    }
  }

  void _showDeleteProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Do you really want to delete the project?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              _deleteProject(widget.project.id);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _deleteProject(String projectId) async {
    await widget.onDeleteProject(projectId);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _editActivity(String activityName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.all(16.0),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Edit Activity',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _activityController,
                style: TextStyle(fontSize: 14.0),
                decoration: InputDecoration(
                  labelText: 'New Activity Name',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _updateActivity(activityName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 88, 137, 155),
                  primary: Color.fromARGB(255, 20, 65, 81),
                  padding: EdgeInsets.all(12.0),
                ),
                child: Text(
                  'Update Activity',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateActivity(String oldActivityName) async {
    try {
      final int index = _activities.indexOf(oldActivityName);

      if (index != -1) {
        final String activityId = await ProjectService().getActivityId(
          widget.username,
          widget.project.id,
          _activities[index],
        );

        final bool currentStatus = _activityStatusMap[oldActivityName] ?? false;

        await ProjectService().updateActivityInProject(
          widget.username,
          widget.project.id,
          activityId,
          _activityController.text,
          DateTime.now(),
        );

        await _loadActivities();

        setState(() {
          _activityStatusMap.remove(oldActivityName);
          _activityStatusMap[_activityController.text] = currentStatus;
          _filteredActivities = List.from(_activities);
        });

        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating activity: $e');
    }
  }

  bool _getActivityStatus(String activityName) {
    return _activityStatusMap[activityName] ?? false;
  }

  Future<void> _saveActivityStatus(String activityName, bool status) async {
    try {
      final String activityId = await ProjectService().getActivityId(
        widget.username,
        widget.project.id,
        activityName,
      );

      await ProjectService().saveActivityStatus(
        widget.username,
        widget.project.id,
        activityId,
        status,
      );

      setState(() {
        _activityStatusMap[activityName] = status;
      });

      print('Activity status saved: $activityName - $status');
    } catch (e) {
      print('Error saving activity status: $e');
    }
  }

  void _openNotesScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotesScreen(
          projectId: widget.project.id,
          username: widget.username,
        ),
      ),
    );
  }
}
