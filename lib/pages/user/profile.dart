
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:patinya888/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:patinya888/config/internal_config.dart';
import 'package:patinya888/model/tesponse/customer_idx_get_res.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  late Future<CustomerIdxGetResponse> loadData;

  @override
  void initState() {
    super.initState();
    loadData = fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    log('Customer id: ${widget.userId}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลส่วนตัว'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<CustomerIdxGetResponse>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('ไม่พบข้อมูลผู้ใช้'));
          }

          final user = snapshot.data!;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ชื่อ-นามสกุล:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(user.name),
                  const SizedBox(height: 16),

                  const Text(
                    'หมายเลขโทรศัพท์:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(user.loginTel),
                  const SizedBox(height: 100),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('ออกจากระบบ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<CustomerIdxGetResponse> fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) throw Exception("Token not found");

      final res = await http.get(
        Uri.parse('$API_ENDPOINT/users/${widget.userId}'),
        headers: {"Authorization": "Bearer $token"},
      );

      log("Profile API response: ${res.body}");

      if (res.statusCode == 200) {
        return customerIdxGetResponseFromJson(res.body);
      } else {
        throw Exception("โหลดข้อมูลไม่สำเร็จ (${res.statusCode})");
      }
    } catch (e) {
      log("Error: $e");
      rethrow;
    }
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
