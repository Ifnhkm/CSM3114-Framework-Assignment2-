import 'package:flutter/material.dart';
import 'package:project_app/models/project.dart';
import 'package:intl/intl.dart';
import 'package:project_app/widgets/add_project_screen.dart';
import 'package:project_app/widgets/log_in_screen.dart';
import 'package:project_app/widgets/project_detail_screen.dart';
import 'package:project_app/widgets/project_services.dart';

class ProjectListScreen extends StatefulWidget {
  final String username;

  const ProjectListScreen({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  _ProjectListScreenState createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final ProjectService _projectService = ProjectService();
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, String> _statusMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 46, 104, 114),
        foregroundColor: Colors.white,
        title: _buildAppBarTitle(),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _confirmLogout(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => _showUserProfile(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchProjectsAndStatuses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Project> projects = snapshot.data!['projects'];
              _statusMap = snapshot.data!['statuses'];

              projects = _filterProjects(projects);

              return projects.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No projects available.\nClick the + button to add a new project.',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(16.0),
                      itemCount: projects.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.0),
                      itemBuilder: (context, index) {
                        return Card(
                          color: Color.fromARGB(255, 197, 246, 235)
                              .withOpacity(0.9),
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      projects[index].name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.show_chart,
                                            color: const Color.fromARGB(
                                                255, 28, 100, 30),
                                            size: 24.0,
                                          ),
                                          onPressed: () => _showProjectProgress(
                                            widget.username,
                                            projects[index].id,
                                            projects[index].name,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color:
                                                Color.fromARGB(255, 3, 28, 77),
                                            size: 18.0,
                                          ),
                                          onPressed: () => _editProjectDetails(
                                            context,
                                            projects[index],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 18.0,
                                          ),
                                          onPressed: () =>
                                              _showDeleteConfirmationDialog(
                                            widget.username,
                                            projects[index].id,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Deadline: ${DateFormat.yMd().add_Hm().format(projects[index].deadline)}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  projects[index].description,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.black87),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 120.0,
                                  child: DropdownButton<String>(
                                    value: _statusMap
                                            .containsKey(projects[index].id)
                                        ? _statusMap[projects[index].id]!
                                        : projects[index].statusId,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _statusMap[projects[index].id] =
                                            newValue ?? '';
                                      });
                                      _updateProjectStatus(
                                        context,
                                        widget.username,
                                        projects[index].id,
                                        newValue ?? '',
                                      );
                                    },
                                    items: <DropdownMenuItem<String>>[
                                      DropdownMenuItem<String>(
                                        value: '1',
                                        child: Text('Incomplete'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: '2',
                                        child: Text('In Progress'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: '3',
                                        child: Text('Completed'),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProjectDetailScreen(
                                        username: widget.username,
                                        project: projects[index],
                                        onAddActivity: _addActivityToProject,
                                        onDeleteProject: _deleteProject,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(),
        tooltip: 'Add Project',
        child: Icon(Icons.add, size: 36.0),
        backgroundColor: Color.fromARGB(255, 37, 116, 116),
        elevation: 8.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBarTitle() {
    return _searchQuery.isEmpty
        ? Text('Project List')
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () {
                      setState(() {
                        _searchQuery = "";
                        _searchController.clear();
                      });
                    },
                  ),
                  SizedBox(width: 8.0),
                ],
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Search Results',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
  }

  Future<void> _showProjectProgress(
      String username, String projectId, String projectName) async {
    try {
      final progress =
          await _projectService.getProjectProgress(username, projectId);

      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Color.fromARGB(255, 200, 230, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Project Progress',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 16, 34, 49)),
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${progress.toStringAsFixed(2)}%',
                      style: TextStyle(
                          fontSize: 16.0,
                          color: const Color.fromARGB(255, 16, 34, 49)),
                    ),
                    SizedBox(width: 6.0),
                    SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        value: progress / 100,
                        strokeWidth: 3.0,
                        color: Color.fromARGB(255, 16, 34, 49),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 16, 34, 49),
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error loading project progress: $e');
    }
  }

  Future<void> _showAddProjectDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.all(0),
        content: AddProjectForm(
          username: widget.username,
          onAddProject: (project) async {
            await _addProject(widget.username, project);
            Navigator.pop(context);
          },
          isEditing: true,
        ),
      ),
    );
    _refreshProjects();
  }

  Future<void> _addProject(String username, Project project) async {
    try {
      await _projectService.addProject(username, project);
      await Future.delayed(Duration(seconds: 1));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Project added successfully!',
            style: TextStyle(fontSize: 16.0),
          ),
          duration: Duration(seconds: 2),
        ),
      );

      _refreshProjects();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error adding project: $error',
            style: TextStyle(fontSize: 16.0),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  List<Project> _filterProjects(List<Project> projects) {
    return projects
        .where((project) =>
            project.name.toLowerCase().contains(_searchQuery) ||
            project.description.toLowerCase().contains(_searchQuery))
        .toList();
  }

  void _addActivityToProject(
      String username, Project project, String activity) async {
    await _projectService.addActivityToProject(
        widget.username, project as String, activity);
    _refreshProjects();
  }

  void _deleteProject(String username, String projectId) async {
    await _projectService.deleteProject(widget.username, projectId);
    _refreshProjects();
  }

  void _refreshProjects() {
    setState(() {});
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.all(16.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Search Project',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _searchController,
              style: TextStyle(fontSize: 14.0),
              decoration: InputDecoration(
                labelText: 'Project Name',
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
                setState(() {
                  _searchQuery = _searchController.text.toLowerCase();
                  Navigator.pop(context);
                });
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.all(12.0),
              ),
              child: Text(
                'Search',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      String username, String projectId) async {
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Project'),
        content: Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (deleteConfirmed == true) {
      _deleteProject(username, projectId);
    }
  }

  Future<void> _editProjectDetails(
      BuildContext context, Project project) async {
    TextEditingController nameController = TextEditingController()
      ..text = project.name;
    TextEditingController descriptionController = TextEditingController()
      ..text = project.description;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.all(0),
        content: AddProjectForm(
          username: widget.username,
          onAddProject: (editedProject) async {
            await _updateProjectDetails(
              context,
              widget.username,
              project.id,
              editedProject,
            );
            Navigator.pop(context);
          },
          initialName: nameController.text,
          initialDescription: descriptionController.text,
          initialDeadline: project.deadline,
          isEditing: true,
        ),
      ),
    );
    _refreshProjects();
  }

  Future<void> _updateProjectDetails(BuildContext context, String username,
      String projectId, Project updatedProject) async {
    try {
      await _projectService.updateProject(
        username,
        projectId,
        updatedProject,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Project details updated successfully!',
            style: TextStyle(fontSize: 16.0),
          ),
          duration: Duration(seconds: 2),
        ),
      );

      _refreshProjects();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating project details: $error',
            style: TextStyle(fontSize: 16.0),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateProjectStatus(BuildContext context, String username,
      String projectId, String status) async {
    try {
      await _projectService.updateProjectStatus(
        username,
        projectId,
        status,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Project status updated successfully!',
            style: TextStyle(fontSize: 16.0),
          ),
          duration: Duration(seconds: 2),
        ),
      );

      Map<String, dynamic> data = await _fetchProjectsAndStatuses();
      setState(() {
        _statusMap = data['statuses'];
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating project status: $error',
            style: TextStyle(fontSize: 16.0),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _fetchProjectsAndStatuses() async {
    try {
      List<Project> projects = await _projectService.getProjects(
        username: widget.username,
      );

      Map<String, String> statuses = {};

      for (Project project in projects) {
        String status = await _projectService.getProjectStatus(
          widget.username,
          project.id,
        );
        statuses[project.id] = status;
      }

      return {'projects': projects, 'statuses': statuses};
    } catch (error) {
      throw 'Error fetching projects and statuses: $error';
    }
  }

  Future<void> _showUserProfile(BuildContext context) async {
    try {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 50, 101, 99),
              borderRadius: BorderRadius.circular(45.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30.0,
                  child: Icon(
                    Icons.person,
                    size: 30.0,
                    color: Color.fromARGB(255, 30, 126, 123),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Hello,',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '${widget.username}!',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 13.0),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (error) {
      print('Error fetching user profile: $error');
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    bool logoutConfirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Out'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LogInScreen()),
              );
            },
            child: Text('Log Out'),
          ),
        ],
      ),
    );

    if (logoutConfirmed == true) {
      Navigator.of(context).pop();
    }
  }
}
