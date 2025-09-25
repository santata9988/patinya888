import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:patinya888/config/internal_config.dart';
import 'package:patinya888/pages/admin/lotto.dart';
import 'package:patinya888/pages/admin/profileAdmin.dart';
import 'package:patinya888/pages/admin/showlotto.dart';
import 'package:patinya888/pages/admin/winLotto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Adminlotto extends StatefulWidget {
  final int userId;
  const Adminlotto({super.key, required this.userId});

  @override
  State<Adminlotto> createState() => _AdminlottoState();
}

class _AdminlottoState extends State<Adminlotto> {
  int _selectedIndex = 0;
  final Color blue = Colors.blue;

  // เก็บค่ารางวัลเป็น String
  String firstPrize = '';
  String secondPrize = '';
  String thirdPrize = '';
  String lastTwoPrize = '';

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      AdminPage(),
      const Lotto(),
      const ShowLotto(),
      const Winlotto(),
      ProAdmin(userId: widget.userId),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: blue,
        unselectedItemColor: Colors.blueAccent,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "หน้าแรก"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "ลอตเตอรี่"),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: "จัดการล็อตเตอรี่",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: "เลขที่ถูกรางวัล",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "โปรไฟล์"),
        ],
      ),
    );
  }

  // ✅ หน้า Admin หลัก
  Widget AdminPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Page',
          style: TextStyle(color: Colors.blueAccent),
        ),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(6),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildPrizeCard("รางวัลที่ 1", firstPrize, (val) {
                setState(() => firstPrize = val);
              }),
              const SizedBox(height: 12),
              buildPrizeCard("รางวัลที่ 2", secondPrize, (val) {
                setState(() => secondPrize = val);
              }),
              const SizedBox(height: 12),
              buildPrizeCard("รางวัลที่ 3", thirdPrize, (val) {
                setState(() => thirdPrize = val);
              }),
              const SizedBox(height: 12),
              lasttwo("รางวัลเลขท้าย 2 ตัว", lastTwoPrize, (val) {
                setState(() => lastTwoPrize = val);
              }),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: saveWinners,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("💾 บันทึกผลทั้งหมด"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: clearAll,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text("🧹 ล้างทั้งหมด"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Card รางวัลหลัก
  Widget buildPrizeCard(
    String title,
    String prizeNumber,
    Function(String) onRandom,
  ) {
    return Card(
      color: Colors.black,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                prizeNumber.isNotEmpty ? prizeNumber : "ยังไม่มีเลข",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: () async {
                      final number = await randomsell();
                      if (number != null) {
                        onRandom(number); // ✅ อัปเดต prizeNumber
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('สุ่มเลขที่มีคนซื้อแล้ว'),
                            content: Text(
                              number,
                              style: const TextStyle(fontSize: 24),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('ตกลง'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text('สุ่มจากเลขที่ขายไปแล้ว'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: Colors.purple,
                    ),
                    onPressed: () async {
                      final number = await randomAllLotto(context);
                      if (number != null) {
                        onRandom(number); // ✅ อัปเดต prizeNumber
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('สุ่มเลขลอตเตอรี่'),
                            content: Text(
                              number,
                              style: const TextStyle(fontSize: 24),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('ตกลง'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text('สุ่มเลขลอตเตอรี่'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Card รางวัลเลขท้าย 2 ตัว
  Widget lasttwo(String title, String prizeNumber, Function(String) onRandom) {
  return Card(
    color: Colors.black,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              prizeNumber.isNotEmpty ? prizeNumber : "ยังไม่มีเลข",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    // ✅ สุ่มเลข 00-99 จริง ๆ
                    final rnd = Random().nextInt(100).toString().padLeft(2, "0");
                    onRandom(rnd);
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text(
                    'สุ่มเลขจาก 00-99',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  // ✅ ส่งผลไป API
  Future<void> saveWinners() async {
    if (firstPrize.isEmpty ||
        secondPrize.isEmpty ||
        thirdPrize.isEmpty ||
        lastTwoPrize.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("ข้อมูลไม่ครบ"),
          content: const Text("กรุณากรอกผลรางวัลให้ครบทุกช่อง"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ตกลง"),
            ),
          ],
        ),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการบันทึกผลรางวัล"),
        content: const Text("คุณแน่ใจหรือไม่ว่าต้องการบันทึกผลรางวัลนี้?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ยืนยัน"),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final url = Uri.parse('$API_ENDPOINT/winners/save');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final winnersList = [
      {"type": "first", "number": firstPrize},
      {"type": "second", "number": secondPrize},
      {"type": "third", "number": thirdPrize},
      {"type": "fifth", "number": lastTwoPrize},
    ];

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"winners": winnersList}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ บันทึกผลรางวัลเรียบร้อย')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ บันทึกไม่สำเร็จ: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ เกิดข้อผิดพลาด: $e')));
    }
  }

  void clearAll() {
    setState(() {
      firstPrize = "";
      secondPrize = "";
      thirdPrize = "";
      lastTwoPrize = "";
    });
  }

  Future<String?> randomsell() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("ยังไม่มี Token กรุณาเข้าสู่ระบบก่อน");
      }

      final res = await http.get(
        Uri.parse('$API_ENDPOINT/lotto/randomSell'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final number = data['number'];
        return number;
      } else if (res.statusCode == 400) {
        final data = jsonDecode(res.body);
        final message = data['error'] ?? 'ยังไม่มีข้อมูล';

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('ไม่มีการซื้อ'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      } else {
        throw Exception("ไม่สามารถสุ่มเลขได้ (${res.statusCode})");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ เกิดข้อผิดพลาด: $e')));
    }
    return null;
  }

  Future<String?> randomAllLotto(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("ยังไม่มี Token กรุณาเข้าสู่ระบบก่อน");
      }

      final res = await http.get(
        Uri.parse('$API_ENDPOINT/lotto/randomAll'),
        headers: {"Authorization": "Bearer $token"},
      );

      print("Status code: ${res.statusCode}");
      print("Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final number = data['number'];
        return number;
      } else if (res.statusCode == 400) {
        // ✅ ถ้าไม่มีเลข
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("❌ ไม่มีเลขในระบบ")));
        return null;
      } else if (res.statusCode == 401) {
        throw Exception("ไม่ได้รับอนุญาต (401)");
      } else {
        throw Exception("ไม่สามารถสุ่มเลขได้ (${res.statusCode})");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ เกิดข้อผิดพลาด: $e')));
      return null;
    }
  }
}
