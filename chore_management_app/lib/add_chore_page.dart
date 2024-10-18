import 'package:flutter/material.dart';
import 'services/pocketbase_service.dart'; // Import PocketBase service

class AddChorePage extends StatefulWidget {
  @override
  _AddChorePageState createState() => _AddChorePageState();
}

class _AddChorePageState extends State<AddChorePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedUserId; // เก็บค่า User ID ที่เลือก
  List<Map<String, String>> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers(); // ดึงรายชื่อผู้ใช้เมื่อเริ่มหน้า
  }

  // ฟังก์ชันดึงรายชื่อผู้ใช้จาก PocketBase
  void fetchUsers() async {
    List<Map<String, String>> fetchedUsers = await getUsers();
    setState(() {
      users = fetchedUsers;
    });
  }

  // ฟังก์ชันเพิ่มงานบ้าน
  void addChore() async {
    String title = titleController.text;
    String description = descriptionController.text;

    if (selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a user to assign the chore to.')),
      );
      return;
    }

    try {
      await pb.collection('chores').create(body: {
        'title': title,
        'description': description,
        'assigned_to': selectedUserId, // ใช้ User ID ที่ตรงกับ email ที่เลือก
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chore added successfully!')),
      );
      Navigator.pop(context); // กลับไปหน้าก่อนหน้า
    } catch (e) {
      print('Failed to add chore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add chore. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Chore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Chore Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Chore Description'),
            ),
            DropdownButtonFormField<String>(
              value: selectedUserId,
              hint: Text('Select User (Email)'),
              items: users.map((user) {
                return DropdownMenuItem<String>(
                  value: user['id'], // เก็บ User ID ที่เลือก
                  child: Text(user['email'] ?? ''), // แสดงอีเมลของผู้ใช้
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedUserId = value; // เก็บ User ID ที่เลือก
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addChore,
              child: Text('Add Chore'),
            ),
          ],
        ),
      ),
    );
  }
}

// ฟังก์ชันดึงรายชื่อผู้ใช้จาก PocketBase
Future<List<Map<String, String>>> getUsers() async {
  try {
    final result = await pb.collection('users').getList();
    return result.items.map((item) {
      return {
        'id': item.id, // User ID
        'email': item.getStringValue('email'), // Email ของผู้ใช้
      };
    }).toList();
  } catch (e) {
    print('Failed to fetch users: $e');
    return [];
  }
}
