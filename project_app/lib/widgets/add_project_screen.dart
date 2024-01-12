import 'package:flutter/material.dart';
import 'package:project_app/models/project.dart';
import 'package:intl/intl.dart';

class AddProjectForm extends StatefulWidget {
  final Function(Project) onAddProject;
  final String initialName;
  final String initialDescription;
  final DateTime? initialDeadline;
  final bool isEditing;
  final String username;

  AddProjectForm({
    required this.onAddProject,
    this.initialName = '',
    this.initialDescription = '',
    this.initialDeadline,
    required this.isEditing,
    required this.username,
  });

  @override
  _AddProjectFormState createState() => _AddProjectFormState();
}

class _AddProjectFormState extends State<AddProjectForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _descriptionController.text = widget.initialDescription;
    _selectedDeadline = widget.initialDeadline;
  }

  Widget _buildDeadlinePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deadline',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () => _pickDeadline(context),
          child: Text(
            _selectedDeadline != null
                ? 'Selected: ${DateFormat.yMd().add_Hm().format(_selectedDeadline!)}'
                : 'Pick a Deadline',
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime combined = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedDeadline = combined;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Add Project',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _nameController,
                style: TextStyle(fontSize: 16.0),
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
              TextField(
                controller: _descriptionController,
                style: TextStyle(fontSize: 16.0),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 19, 157, 157), width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _pickDeadline(context);
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
                  'Pick Deadline',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
              SizedBox(height: 8.0),
              if (_selectedDeadline != null)
                Text(
                  'Selected Deadline: ${_selectedDeadline!.toString()}',
                  style: TextStyle(fontSize: 16.0),
                ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    if (_selectedDeadline == null) {
                      return;
                    }

                    Project newProject = Project(
                      id: DateTime.now().toString(),
                      name: _nameController.text,
                      description: _descriptionController.text,
                      activities: [],
                      deadline: _selectedDeadline!,
                      status: 'Incompleted',
                    );

                    widget.onAddProject(newProject);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Project added successfully!',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    _nameController.clear();
                    _descriptionController.clear();
                    _selectedDeadline = null;
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 82, 197, 217),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.all(12.0),
                ),
                child: Text(
                  'Create Project',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
