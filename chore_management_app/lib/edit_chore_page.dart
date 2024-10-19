import 'package:flutter/material.dart';
import 'services/pocketbase_service.dart';

class EditChorePage extends StatefulWidget {
  final String choreId;
  final String initialTitle;
  final String initialDescription;

  EditChorePage({required this.choreId, required this.initialTitle, required this.initialDescription});

  @override
  _EditChorePageState createState() => _EditChorePageState();
}

class _EditChorePageState extends State<EditChorePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _descriptionController.text = widget.initialDescription;
  }

  void updateChore() async {
    try {
      await pb.collection('chores').update(widget.choreId, body: {
        'title': _titleController.text,
        'description': _descriptionController.text,
      });
      Navigator.pop(context); // กลับไปหน้าก่อนหน้าเมื่อบันทึกเสร็จ
    } catch (e) {
      print('Failed to update chore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Chore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Chore Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Chore Description'),
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
