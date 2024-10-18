import 'package:flutter/material.dart';
import 'chores_page.dart'; // Import หน้า ChoresPage
import 'register_page.dart'; // Import หน้า ChoresPage
import 'services/pocketbase_service.dart'; // Import PocketBase service

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      // ล็อกอินผู้ใช้
      await PocketBaseService().loginUser(email, password);

      // ตรวจสอบว่าล็อกอินสำเร็จ
      if (pb.authStore.isValid) {
        print('User logged in: ${pb.authStore.model?.id}');
        
        // เปลี่ยนหน้าไปที่หน้าแสดงงานบ้านหลังล็อกอินสำเร็จ
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChoresPage()));
      } else {
        print('Login failed: User is not authenticated.');
      }
    } catch (e) {
      // แสดงข้อผิดพลาดถ้าเกิดปัญหาในการล็อกอิน
      print('Login failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed! Please check your credentials.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // ไปที่หน้า Register
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: Text('Don\'t have an account? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}
