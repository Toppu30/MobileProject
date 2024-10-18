import 'package:flutter/material.dart'; // Import หน้า ChoresPage
import 'login_page.dart'; // Import หน้า LoginPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // หน้าเริ่มต้นเป็นหน้า Login
    );
  }
}
