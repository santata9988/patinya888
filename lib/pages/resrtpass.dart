import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:patinya888/config/internal_config.dart';

class Resrtpass extends StatefulWidget {
  const Resrtpass({super.key});

  @override
  State<Resrtpass> createState() => _ResrtpassState();
}

class _ResrtpassState extends State<Resrtpass> {
  var phoneCtl = TextEditingController();
  var passwordCtl = TextEditingController();
  var confirmpasswordCtl = TextEditingController();

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("รีเซ็ตรหัสผ่าน")),
    
    // ✅ สำคัญที่สุด!
    resizeToAvoidBottomInset: true,

    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40), // กันพื้นที่ตอนแป้นพิมพ์ขึ้น
        child: Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          color: Colors.blueAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 25),
                child: Text(
                  'หมายเลขโทรศัพท์',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: TextField(
                  controller: phoneCtl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(left: 16, top: 25),
                child: Text('รหัสผ่าน', style: TextStyle(fontSize: 20)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: TextField(
                  controller: passwordCtl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(left: 16, top: 25),
                child: Text('ยืนยันรหัสผ่าน', style: TextStyle(fontSize: 20)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: TextField(
                  controller: confirmpasswordCtl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: resrtpassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.shade700,
                    ),
                    child: const Text(
                      'ยืนยัน',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}  void resrtpassword() async {
    if (passwordCtl.text != confirmpasswordCtl.text) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('ข้อผิดพลาด'),
          content: Text('รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ตกลง'),
            ),
          ],
        ),
      );
      return;
    }

    if (phoneCtl.text.isEmpty ||
        passwordCtl.text.isEmpty ||
        confirmpasswordCtl.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('กรอกข้อมูลไม่ครบ'),
          content: Text('กรุณากรอกข้อมูลให้ครบทุกช่อง'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ตกลง'),
            ),
          ],
        ),
      );
      return;
    }

    final url = Uri.parse(
      '$API_ENDPOINT/reset-password',
    ); // ✅ เปลี่ยนเป็น URL server ของคุณ
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        "loginTel": phoneCtl.text,
        "newPassword": passwordCtl.text,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["success"] == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('สำเร็จ'),
          content: Text('รีเซ็ตรหัสผ่านเรียบร้อยแล้ว'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // กลับไปหน้า Login
              },
              child: Text('ตกลง'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('ล้มเหลว'),
          content: Text(data["message"] ?? 'เกิดข้อผิดพลาด'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ตกลง'),
            ),
          ],
        ),
      );
    }
  }
}
