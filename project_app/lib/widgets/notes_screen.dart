import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_app/widgets/note_services.dart';

class NotesScreen extends StatefulWidget {
  final String username;
  final String projectId;

  NotesScreen({required this.username, required this.projectId});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _noteController = TextEditingController();
  List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await NoteServices(
              baseUrl:
                  'https://projectapp-6f108-default-rtdb.asia-southeast1.firebasedatabase.app')
          .getNotes(widget.username, widget.projectId);

      setState(() {
        _notes = notes;
      });
    } catch (e) {
      print('Error loading notes: $e');
    }
  }

  Future<void> _saveNote() async {
    try {
      if (_noteController.text.isNotEmpty) {
        await NoteServices(
                baseUrl:
                    'https://projectapp-6f108-default-rtdb.asia-southeast1.firebasedatabase.app')
            .addNote(widget.username, widget.projectId, _noteController.text);

        _noteController.clear();
        _loadNotes();
      }
    } catch (e) {
      print('Error saving note: $e');
    }
  }

  Future<void> _removeAllNotes() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete All Notes"),
          content: Text("Are you sure you want to delete all notes?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAllNotes();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllNotes() async {
    try {
      await NoteServices(
        baseUrl:
            'https://projectapp-6f108-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).removeAllNotes(widget.username, widget.projectId);

      setState(() {
        _notes.clear();
      });
    } catch (e) {
      print('Error removing notes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Notes'),
        backgroundColor: Color(0xFF2E6872),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _removeAllNotes,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/background.jpg"),
            fit: BoxFit.cover,
          ),
          color: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildNotesList(),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      style: TextStyle(fontSize: 16.0),
                      decoration: InputDecoration(
                        labelText: 'Leave a Note',
                        contentPadding: EdgeInsets.all(14.0),
                        filled: true,
                        fillColor: Color.fromARGB(255, 250, 250, 250),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.white,
                    onPressed: _saveNote,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    return _notes.isEmpty
        ? Center(
            child: Text(
              'No notes available.',
              style: TextStyle(color: Colors.white),
            ),
          )
        : ListView.builder(
            itemCount: _notes.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> noteData = json.decode(_notes[index]);
              DateTime date = DateTime.parse(noteData['date']);

              return Card(
                color:
                    const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
                elevation: 4.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(noteData['note']),
                      SizedBox(height: 8.0),
                    ],
                  ),
                  subtitle: Text(DateFormat.yMd().add_jm().format(date)),
                ),
              );
            },
          );
  }
}
