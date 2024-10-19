import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('http://127.0.0.1:8090'); // URL ของ PocketBase ที่ใช้

class PocketBaseService {
  // ฟังก์ชันสำหรับการล็อกอินผู้ใช้
  Future<void> loginUser(String email, String password) async {
    try {
      final authData =
          await pb.collection('users').authWithPassword(email, password);

      // ตรวจสอบว่ามีข้อมูล authData จริง ๆ
      if (authData.record != null) {
        print('User logged in successfully: ${authData.record?.id}');
        print('Token: ${authData.token}');
      } else {
        print('Login failed: No auth data received.');
      }
    } catch (e) {
      print('Login failed: $e');
      throw e; // ส่งข้อผิดพลาดกลับไป
    }
  }

  // ฟังก์ชันตรวจสอบว่าเป็น admin หรือไม่
  Future<bool> isAdmin() async {
    try {
      final user = pb.authStore.model; // ดึงข้อมูลผู้ใช้ที่ล็อกอินอยู่
      return user?.getStringValue('role') == 'admin'; // ตรวจสอบบทบาท admin
    } catch (e) {
      print('Failed to check admin role: $e');
      return false; // ถ้าเกิดข้อผิดพลาดถือว่าไม่ใช่ admin
    }
  }

  // ฟังก์ชันสำหรับการสมัครสมาชิกผู้ใช้ใหม่
  Future<void> registerUser(String email, String password, String role) async {
    try {
      await pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'role': role,
      });
      print('User registered successfully');
    } catch (e) {
      print('Registration failed: $e');
      throw e;
    }
  }
  
  // ฟังก์ชันดึงรายชื่อผู้ใช้ทั้งหมด
  Future<List<Map<String, String>>> getUsers() async {
    try {
      // ดึงข้อมูลผู้ใช้ทั้งหมดจาก PocketBase
      final result =
          await pb.collection('users').getList(); // ดึงข้อมูลจากทุกคน

      if (result.items.isNotEmpty) {
        return result.items.map((item) {
          return {
            'id': item.id, // User ID
            'email': item.getStringValue('email'), // Email ของผู้ใช้
          };
        }).toList();
      } else {
        print('No users found.');
        return [];
      }
    } catch (e) {
      print('Failed to fetch users: $e');
      return [];
    }
  }

  // ฟังก์ชันดึงงานบ้านทั้งหมด (สำหรับ Admin)
  Future<List<Map<String, dynamic>>> getChores() async {
    try {
      final result = await pb.collection('chores').getList();
      return result.items.map((item) {
        
        return {
          'id': item.id,
          'title': item.getStringValue('title'),
          'description': item.getStringValue('description'),
          'assigned_to': item.getStringValue('assigned_to'),
        };
      }).toList();
    } catch (e) {
      print('Failed to fetch chores: $e');
      return [];
    }
  }

  // ฟังก์ชันดึงงานบ้านเฉพาะที่ assigned ให้ผู้ใช้ที่ล็อกอินอยู่ (สำหรับ Member)
  Future<List<Map<String, dynamic>>> getUserChores(String userId) async {
    try {
      final result = await pb.collection('chores').getList(
        filter: 'assigned_to.id = "$userId"',
      );
      return result.items.map((item) {
        return {
          'id': item.id,
          'title': item.getStringValue('title'),
          'description': item.getStringValue('description'),
          'assigned_to': item.getStringValue('assigned_to'),
        };
      }).toList();
    } catch (e) {
      print('Failed to fetch user chores: $e');
      return [];
    }
  }

  // ฟังก์ชัน logout
  void logout() {
    pb.authStore.clear(); // ล้างข้อมูลการล็อกอิน
  }
  Future<Map<String, dynamic>> getChoreById(String choreId) async {
    try {
      final result = await pb.collection('chores').getOne(choreId);
      return {
        'id': result.id,
        'title': result.getStringValue('title'),
        'description': result.getStringValue('description'),
      };
    } catch (e) {
      print('Error fetching chore: $e');
      throw e;
    }
  }

  // อัปเดตข้อมูลงานบ้านใน PocketBase
  Future<void> updateChore(String choreId, Map<String, dynamic> updatedData) async {
    try {
      await pb.collection('chores').update(choreId, body: updatedData);
      print('Chore updated successfully');
    } catch (e) {
      print('Error updating chore: $e');
      throw e;
    }
  }
}
