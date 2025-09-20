import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:patinya888/config/internal_config.dart';

class Lotto extends StatefulWidget {
  const Lotto({super.key});

  @override
  State<Lotto> createState() => _LottoState();
}

class _LottoState extends State<Lotto> {
  List<String> numbers = [];
  bool isLoading = false;

  // ฟังก์ชันสุ่มเลข 6 หลัก 300 ตัว
  void generate300Numbers() {
    final rand = Random();
    final Set<String> uniqueNumbers = {}; // ป้องกันเลขซ้ำ

    while (uniqueNumbers.length < 300) {
      final num = rand.nextInt(1000000).toString().padLeft(6, '0');
      uniqueNumbers.add(num);
    }

    setState(() {
      numbers = uniqueNumbers.toList();
    });
  }

  // ฟังก์ชันบันทึกเลขทั้งหมดไป API Node.js
  Future<void> saveNumbers() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการบันทึก"),
        content: const Text("คุณต้องการบันทึกเลข 300 ตัวนี้หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ยืนยัน", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return; // ถ้าไม่ได้กด "ยืนยัน" ให้จบฟังก์ชันเลย
    if (numbers.isEmpty) return;

    setState(() => isLoading = true);



    try {
      final response = await http.post(
        Uri.parse("$API_ENDPOINT/lotto/saveMany"), // API ฝั่ง Node.js
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"numbers": numbers}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("บันทึกเลข 300 ตัวสำเร็จ ✅")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("บันทึกล้มเหลว: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "จัดการลอตเตอรี่",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: generate300Numbers,
              child: const Text(
                "สุ่มเลข",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : saveNumbers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "บันทึกล็อเตอรี่",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: numbers.isEmpty
                  ? const Center(
                      child: Text(
                        "ยังไม่ได้สุ่ม",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : GridView.count(
                      crossAxisCount: 4, // ✅ 3 คอลัมน์
                      crossAxisSpacing: 10,
                      children: numbers.map((num) {
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            num,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
