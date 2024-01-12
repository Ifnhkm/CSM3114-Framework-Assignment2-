import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_app/widgets/contact_screen.dart';
import 'package:project_app/widgets/guidelines_screen.dart';
import 'package:project_app/widgets/project_list_screen.dart';
import 'package:project_app/widgets/sign_up_screen.dart';

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hidePassword = true;
  final String _baseUrl =
      'https://projectapp-6f108-default-rtdb.asia-southeast1.firebasedatabase.app';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2E6872),
        title: Text('Project Tracking App'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Card(
                    color: Colors.grey[300],
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Hero(
                            tag: 'logo',
                            child: Image.asset(
                              'images/logo.png',
                              height: 60,
                              width: 100,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          buildTextField(
                            'Username',
                            Icons.person,
                            _usernameController,
                          ),
                          SizedBox(height: 12.0),
                          buildTextField(
                            'Password',
                            Icons.lock,
                            _passwordController,
                            obscureText: _hidePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 20.0),
                          buildElevatedButton(context),
                          SizedBox(height: 8.0),
                          Center(
                            child: buildSignUpLink(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 32, 88, 98),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.help, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GuidelinesScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.contact_mail, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSignUpLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpScreen()),
        );
      },
      child: Text(
        'Don\'t have an account? Sign Up',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TextFormField buildTextField(
    String labelText,
    IconData prefixIcon,
    TextEditingController controller, {
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(prefixIcon, color: Colors.black),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      obscureText: obscureText,
    );
  }

  ElevatedButton buildElevatedButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(0xFF6EACAD),
        padding: EdgeInsets.symmetric(vertical: 14.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: () => onLoginPressed(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 24),
          SizedBox(width: 8.0),
          Text('Log In', style: TextStyle(fontSize: 18.0)),
        ],
      ),
    );
  }

  void onLoginPressed(BuildContext context) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/RegisterUser.json');
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        bool isUserExists = data.values.any((user) =>
            user['username'] == _usernameController.text &&
            user['password'] == _passwordController.text);

        if (isUserExists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProjectListScreen(username: _usernameController.text)),
          );
        } else {
          showLoginError(context);
        }
      } else {
        showLoginError(context);
      }
    } catch (error) {
      showLoginError(context);
    }
  }

  void showLoginError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invalid username or password'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
