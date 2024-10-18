import 'package:flutter/material.dart';
import 'services/pocketbase_service.dart'; // Import PocketBase service
import 'login_page.dart'; // Import หน้า LoginPage สำหรับนำผู้ใช้กลับไปที่หน้า login
import 'add_chore_page.dart'; // นำเข้าหน้า AddChorePage
import 'edit_chore_page.dart'; // นำเข้าหน้า AddChorePage


class ChoresPage extends StatefulWidget {
  @override
  _ChoresPageState createState() => _ChoresPageState();
}

class _ChoresPageState extends State<ChoresPage> {
  List<Map<String, dynamic>> chores = []; // รายการงานบ้าน

  // ฟังก์ชันตรวจสอบว่าผู้ใช้เป็น admin หรือไม่
  bool isAdmin() {
    return pb.authStore.model?.getStringValue('role') == 'admin';
  }

  @override
  void initState() {
    super.initState();
    fetchChores(); // ดึงข้อมูลงานบ้านเมื่อเปิดหน้า
  }

  // ฟังก์ชันดึงรายการงานบ้านจาก PocketBase
  Future<List<Map<String, dynamic>>> getChores() async {
    try {
      if (pb.authStore.model != null) {
        final userId = pb.authStore.model.id;

        final result = await pb.collection('chores').getList(
          filter: 'assigned_to.id = "$userId"',  // กรองตามผู้ใช้ที่ล็อกอิน
        );

        print("Raw API result: ${result.items}");

        List<Map<String, dynamic>> chores = result.items.map((item) {
          return {
            'id': item.id,
            'title': item.getStringValue('title'),
            'description': item.getStringValue('description'),
          };
        }).toList();

        return chores;
      } else {
        print('User is not logged in or authStore is null.');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  void fetchChores() async {
    List<Map<String, dynamic>> fetchedChores = await PocketBaseService().getChores();
    setState(() {
      chores = fetchedChores;
    });
  }

  // ฟังก์ชัน logout
  void logout() {
    pb.authStore.clear(); // ล้างข้อมูล authStore

    // นำผู้ใช้กลับไปที่หน้า login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Chores List'),
      actions: [
        // ปุ่ม Logout
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: logout, // เรียกฟังก์ชัน logout เมื่อกดปุ่ม
        ),
        if (isAdmin()) // ถ้าเป็น admin จะแสดงปุ่ม Add Chore
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddChorePage()),
              );
            },
          ),
      ],
    ),
    body: chores.isEmpty
        ? Center(child: Text('No chores found.'))
        : ListView.builder(
            itemCount: chores.length,
            itemBuilder: (context, index) {
              final chore = chores[index];
              return ListTile(
                title: Text(chore['title']),
                subtitle: Text(chore['description']),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditChorePage(choreId: chore['id']),
                      ),
                    );
                },
              );
            },
          ),
  );
}

}
