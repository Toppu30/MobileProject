import 'package:flutter/material.dart';
import 'services/pocketbase_service.dart';
import 'login_page.dart';
import 'add_chore_page.dart';
import 'edit_chore_page.dart';

class ChoresPage extends StatefulWidget {
  @override
  _ChoresPageState createState() => _ChoresPageState();
}

class _ChoresPageState extends State<ChoresPage> {
  List<Map<String, dynamic>> chores = [];

  @override
  void initState() {
    super.initState();
    fetchChores(); // ดึงข้อมูลงานบ้านเมื่อเปิดหน้า
  }

  void fetchChores() async {
    List<Map<String, dynamic>> fetchedChores;
    if (await PocketBaseService().isAdmin()) {
      fetchedChores = await PocketBaseService().getChores();
    } else {
      final userId = pb.authStore.model?.id;
      fetchedChores = await PocketBaseService().getUserChores(userId ?? '');
    }
    setState(() {
      chores = fetchedChores;
    });
  }

  void logout() {
    pb.authStore.clear();
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
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
          if (pb.authStore.model?.getStringValue('role') == 'admin')
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddChorePage()),
                ).then((value) => fetchChores());
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
                  subtitle: Text(
                    '${chore['description']} - Assigned to: ${chore['assigned_to'] ?? 'N/A'}',
                  ),
                  trailing: Icon(Icons.edit),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditChorePage(
                          choreId: chore['id'],
                          initialTitle: chore['title'],
                          initialDescription: chore['description'],
                        ),
                      ),
                    ).then((value) => fetchChores());
                  },
                );
              },
            ),
    );
  }
}
