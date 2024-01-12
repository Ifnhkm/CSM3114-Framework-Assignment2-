import 'dart:convert';
import 'package:http/http.dart' as http;

class NoteServices {
  final String baseUrl;

  NoteServices({required this.baseUrl});

  Future<List<String>> getNotes(String username, String projectId) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/UserData/$username/projects/$projectId/Notes.json'));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data != null && data is Map<String, dynamic>) {
          List<String> notes = [];
          data.forEach((key, value) {
            if (value is Map<String, dynamic> &&
                value['username'] == username &&
                value['projectId'] == projectId) {
              notes.add(json.encode(value));
            }
          });
          return notes;
        }
      }
    } catch (e) {
      print('Error loading notes: $e');
    }

    throw Exception('Failed to load notes');
  }

  Future<void> addNote(String username, String projectId, String note) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/UserData/$username/projects/$projectId/Notes.json'),
        body: json.encode({
          'username': username,
          'projectId': projectId,
          'note': note,
          'date': DateTime.now().toIso8601String(), // Add the current date
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add note');
      }
    } catch (e) {
      print('Error adding note: $e');
      throw Exception('Failed to add note');
    }
  }

  Future<void> removeAllNotes(String username, String projectId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/UserData/$username/projects/$projectId/Notes.json'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove notes');
      }
    } catch (e) {
      print('Error removing notes: $e');
      throw Exception('Failed to remove notes');
    }
  }
}
