// ✅ รวมหน้า HomePage และแสดงผลรางวัล lotto แบบแก้ไขแล้ว (รวมใน Card เดียว)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:patinya888/config/internal_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _ctrl = TextEditingController();
  bool isLoading = true;
  Map<String, dynamic> winners = {};

  @override
  void initState() {
    super.initState();
    fetchWinners();
  }

  Future<void> fetchWinners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.get(
        Uri.parse("$API_ENDPOINT/winners"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);

        final Map<String, dynamic> grouped = {
          "second": [],
          "third": [],
          "lastThree": [],
        };

        for (var item in data) {
          switch (item["type"]) {
            case "first":
              grouped["first"] = item["number"];
              break;
            case "second":
              grouped["second"].add(item["number"]);
              break;
            case "third":
              grouped["third"].add(item["number"]);
              break;
            case "fifth":
              grouped["fifth"] = item["number"];
              break;
            case "lastThreeDigits":
              grouped["lastThree"].add(item["number"]);
              break;
          }
        }

        setState(() {
          winners = grouped;
          isLoading = false;
        });
      } else {
        throw Exception("โหลดข้อมูลล้มเหลว (${res.statusCode})");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ เกิดข้อผิดพลาด: $e")));
    }
  }

  void _checkNumber() async {
    final number = _ctrl.text.trim();
    if (number.isEmpty || int.tryParse(number) == null) {
      _showDialog("⚠️ กรุณากรอกเลขให้ถูกต้อง");
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) {
        _showDialog("❌ กรุณาเข้าสู่ระบบก่อน");
        return;
      }

      final res = await http.get(
        Uri.parse('$API_ENDPOINT/results'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        bool isWin = false;
        String prizeType = "";

        if (data is List) {
          for (final item in data) {
            final winNum = item["number"].toString();
            final type = item["type"].toString();

            if (number == winNum ||
                (type == "lastTwoDigits" && number.endsWith(winNum)) ||
                (type == "lastThreeDigits" && number.endsWith(winNum))) {
              isWin = true;
              prizeType = type;
              break;
            }
          }
        }

        if (isWin) {
          _showDialog("🎉 ยินดีด้วย! เลข $number ถูกรางวัล [$prizeType]");
        } else {
          _showDialog("❌ เลข $number ไม่ถูกรางวัล");
        }
      } else {
        _showDialog("โหลดผลรางวัลไม่สำเร็จ [\${res.statusCode}]");
      }
    } catch (e) {
      _showDialog("❌ เกิดข้อผิดพลาด: $e");
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("ผลการตรวจสอบ", style: TextStyle(color: Colors.cyan)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ปิด", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "ตรวจผลลอตเตอรี่",
          style: TextStyle(color: Colors.cyan),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "กรอกเลขลอตเตอรี่",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _checkNumber,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                  child: const Text(
                    "ตรวจรางวัล",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const Divider(height: 32),

                // ✅ รวมรางวัลทั้งหมดใน Card เดียว
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),

                        if (winners['first'] != null) ...[
                          const Text(
                            "รางวัลที่ 1 (6,000,000 บาท)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            winners['first'],
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if ((winners['second'] ?? []).isNotEmpty) ...[
                          const Text("รางวัลที่ 2 (200,000 บาท)"),
                          Wrap(
                            spacing: 10,
                            children: (winners['second'] as List)
                                .map<Widget>(
                                  (e) => Text(
                                    e,
                                    style: const TextStyle(fontSize: 35),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if ((winners['third'] ?? []).isNotEmpty) ...[
                          const Text("รางวัลที่ 3 (80,000 บาท)"),
                          Wrap(
                            spacing: 10,
                            children: (winners['third'] as List)
                                .map<Widget>(
                                  (e) => Text(
                                    e,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if ((winners['lastThree'] ?? []).isNotEmpty) ...[
                          const Text("เลขท้าย 3 ตัว (4,000 บาท)"),
                          Wrap(
                            spacing: 10,
                            children: (winners['lastThree'] as List)
                                .map<Widget>(
                                  (e) => Text(
                                    e,
                                    style: const TextStyle(fontSize: 25),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (winners['fifth'] != null) ...[
                          const Text("เลขท้าย 2 ตัว (2,000 บาท)"),
                          Text(
                            winners['fifth'],
                            style: const TextStyle(fontSize: 25),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
