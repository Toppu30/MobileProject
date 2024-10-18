import 'package:flutter/material.dart';
import 'services/pocketbase_service.dart';

class EditChorePage extends StatefulWidget {
  final String choreId;

  EditChorePage({required this.choreId});

  @override
  _EditChorePageState createState() => _EditChorePageState();
}

class _EditChorePageState extends State<EditChorePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchChoreData();
  }

  // ฟังก์ชันดึงข้อมูลงานบ้านจาก PocketBase
  void fetchChoreData() async {
    final chore = await PocketBaseService().getChoreById(widget.choreId);
    setState(() {
      titleController.text = chore['title'];
      descriptionController.text = chore['description'];
    });
  }

  // ฟังก์ชันอัปเดตงานบ้านใน PocketBase
  void updateChore() async {
    await PocketBaseService().updateChore(widget.choreId, {
      'title': titleController.text,
      'description': descriptionController.text,
    });
    Navigator.pop(context); // กลับไปหน้าก่อนหลังจากอัปเดตเสร็จ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Chore'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateChore,
              child: Text('Update Chore'),
            ),
          ],
        ),
      ),
    );
  }
}
