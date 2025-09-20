import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:patinya888/config/internal_config.dart';
import 'package:patinya888/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProAdmin extends StatelessWidget {
  final int userId; // รับ userId

  const ProAdmin({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Profile"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ยินดีต้อนรับ Admin ID: $userId",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => resetLotto(context),
              label: const Text('รีเซ็ตล็อตเตอรี่(ลบเลขทั้งหมด)'),
              icon: const Icon(Icons.refresh),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => deletLotto(context),
              label: const Text('รีเซ็ตเลขที่ถกรางวัล(ลบเลขที่ถูกรางวัลทั้งหมด)'),
              icon: const Icon(Icons.refresh),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => resetSystem(context),
              icon: const Icon(Icons.restart_alt),
              label: const Text("รีเซ็ตระบบ (ล้างข้อมูล)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(250, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                // Clear token หรือทำ logout logic ได้ตรงนี้
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("ออกจากระบบ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void resetSystem(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ยืนยันการรีเซ็ตระบบ"),
        content: const Text(
          "คุณแน่ใจหรือไม่ว่าต้องการลบข้อมูลทั้งหมดและรีเซ็ตระบบ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ยืนยัน", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return; // ถ้าไม่ได้กด "ยืนยัน" ให้จบฟังก์ชันเลย

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    try {
      final res = await http.post(
        Uri.parse("$API_ENDPOINT/reset"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final msg = jsonDecode(res.body)['message'];
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('สำเร็จ'),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      } else {
        throw Exception("Reset ล้มเหลว: ${res.statusCode}");
      }
    } catch (e) {
      log("❌ Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  Future<void> resetLotto(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("รีเซ็ตล็อตเตอรี่"),
        content: const Text("คุณต้องการรีเซ็ตล็อตเตอรี่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              // Logic รีเซ็ตล็อตเตอรี่ที่นี่
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ รีเซ็ตล็อตเตอรี่เรียบร้อย')),
              );
            },
            child: const Text("รีเซ็ต", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    try {
      final res = await http.post(
        Uri.parse("$API_ENDPOINT/reset-lotto"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final msg = jsonDecode(res.body)['message'];
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('สำเร็จ'),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      } else {
        throw Exception("Reset ล้มเหลว: ${res.statusCode}");
      }
    } catch (e) {
      log("❌ Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }
  
  Future<void> deletLotto(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("รีเซ็ตล็อตเตอรี่ที่ถูกรางวัล"),
        content: const Text("คุณต้องการรีเซ็ตล็อตเตอรี่ที่ถูกรางวัลหรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              // Logic รีเซ็ตล็อตเตอรี่ที่นี่
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ รีเซ็ตล็อตเตอรี่เรียบร้อย')),
              );
            },
            child: const Text("รีเซ็ต", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    try {
      final res = await http.post(
        Uri.parse("$API_ENDPOINT/reset-winners"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final msg = jsonDecode(res.body)['message'];
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('สำเร็จ'),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      } else {
        throw Exception("Reset ล้มเหลว: ${res.statusCode}");
      }
    } catch (e) {
      log("❌ Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

}
