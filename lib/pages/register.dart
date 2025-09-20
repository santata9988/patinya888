import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:patinya888/config/internal_config.dart';
import 'package:patinya888/model/request/customer_register_post_res.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  var fullnameCtl = TextEditingController();
  var phoneCtl = TextEditingController();
  var walletCtl = TextEditingController();
  var passwordCtl = TextEditingController();
  var confirmpasswordCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ลงทะเบียนสมาชิกใหม่')),
      backgroundColor: Colors.blueAccent.shade700,
      body: SizedBox(
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.all(16),
            elevation: 4,
            color: Colors.blueAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 25),
                  child: Text('ชื่อ-นามสกุล', style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: TextField(
                    controller: fullnameCtl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16),
                  child: Text(
                    "หมายเลขโทรศัพท์",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: TextField(
                    controller: phoneCtl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16),
                  child: Text("รหัสผ่าน", style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: TextField(
                    controller: passwordCtl,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16),
                  child: Text("ยืนยันรหัสผ่าน", style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: TextField(
                    controller: confirmpasswordCtl,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text("จำนวนเงิน", style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: TextField(
                    controller: walletCtl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(300, 50),
                            backgroundColor: Colors.black,
                          ),
                          onPressed: create,
                          child: const Text(
                            'ลงทะเบียน',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void create() {
    if (fullnameCtl.text.isEmpty ||
        phoneCtl.text.isEmpty ||
        walletCtl.text.isEmpty ||
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
    if (int.tryParse(walletCtl.text) == null || int.parse(walletCtl.text) < 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('ข้อผิดพลาด'),
          content: Text('จำนวนเงินต้องเป็นตัวเลขเท่านั้นและต้องไม่ติดลบ'),
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
    if (phoneCtl.text.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(phoneCtl.text)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('ข้อผิดพลาด'),
          content: Text('หมายเลขโทรศัพท์ต้องเป็นตัวเลข 10 หลัก'),
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

    CustomerRegisterPostRequest req = CustomerRegisterPostRequest(
      id: 0,
      name: fullnameCtl.text,
      loginTel: phoneCtl.text,
      role: "user",
      password: passwordCtl.text,
      wallet: int.parse(walletCtl.text),
    );

    http
        .post(
          Uri.parse("$API_ENDPOINT/register"),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: customerRegisterPostRequestToJson(req),
        )
        .then((value) {
          log("STATUS: ${value.statusCode}");
          log("BODY: ${value.body}");

          // ✅ Decode JSON ก่อน ไม่พังแน่นอน
          final json = jsonDecode(value.body);

          // ✅ ตรวจว่ามี id/message จริงไหม
          final id = json["id"];
          final message = json["message"] ?? "สมัครสมาชิกสำเร็จ";

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('สมัครสมาชิกสำเร็จ'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // ปิด dialog
                    Navigator.pop(context); // กลับหน้า login
                  },
                  child: Text('ตกลง'),
                ),
              ],
            ),
          );
        })
        .catchError((error) {
          log("❌ ERROR: $error");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('ข้อผิดพลาด'),
              content: Text('รูปแบบข้อมูลผิดพลาด หรือโทรซ้ำ'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ตกลง'),
                ),
              ],
            ),
          );
        });
  }
}
