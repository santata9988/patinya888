// 📁 login.dart
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:patinya888/config/internal_config.dart';
import 'package:patinya888/model/request/customer_login_post_res.dart';
import 'package:patinya888/model/tesponse/customer_login_post_res.dart';
import 'package:patinya888/pages/admin/adminLotto.dart';
import 'package:patinya888/pages/register.dart';
import 'package:patinya888/pages/resrtpass.dart';
import 'package:patinya888/pages/user/mainhome.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String text = '';
  var phoneCtl = TextEditingController();
  var passwordCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset("assets/image/image.png", fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "หมายเลขโทรศัพท์",
                                  style: TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: phoneCtl,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "รหัสผ่าน",
                                  style: TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: passwordCtl,
                                  obscureText: true,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Center(
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(300, 50),
                                      backgroundColor: Colors.blueAccent,
                                    ),
                                    onPressed: login,
                                    child: const Text(
                                      'เข้าสู่ระบบ',
                                      style: TextStyle(fontSize: 25),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: resetpassword,
                                      child: const Text(
                                        'ลืมรหัสผ่านใช่หรือไม่?',
                                        style: TextStyle(fontSize: 19),
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(300, 40),
                                      side: BorderSide(color: Colors.black),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: register,
                                    child: Text(
                                      'ลงทะเบียนใหม่',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> login() async {
    CustomerLoginPostRequest req = CustomerLoginPostRequest(
      loginTel: phoneCtl.text,
      password: passwordCtl.text,
    );

    try {
      var response = await http.post(
        Uri.parse("$API_ENDPOINT/login"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: customerLoginPostRequestToJson(req),
      );

      final data = jsonDecode(response.body);

      if (data["error"] != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('ข้อมูลผิดพลาด'),
            content: Text('หมายเลขโทรศัพท์หรือรหัสผ่านไม่ถูกต้อง'),
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
      // หลังจาก login API success
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      await prefs.setInt("userId", data["user"]["id"]); // เก็บ id

      handleLoginSuccess(data["token"]);
      if (data["token"] == null || data["user"] == null) {
        log("❌ response missing token or user");
        setState(() => text = "ข้อมูล login ไม่สมบูรณ์");
        return;
      }

      CustomerLoginPostResponse customerLoginPostResponse =
          CustomerLoginPostResponse.fromJson(data);
      log('📦 login response: ${response.body}');
      if (customerLoginPostResponse.user.role == "owner") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                Adminlotto(userId: customerLoginPostResponse.user.id),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainApp(userId: customerLoginPostResponse.user.id),
          ),
        );
      }
    } catch (error) {
      log('Error $error');
      setState(() => text = "เกิดข้อผิดพลาด: $error");
    }
  }

  void register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void resetpassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Resrtpass()),
    );
  }

  void handleLoginSuccess(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }
}
