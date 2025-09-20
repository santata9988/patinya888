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
  bool isLoading = true;
  Map<String, dynamic> winners = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "ผลรางวัลลอตเตอรี่",
          style: TextStyle(color: Colors.white)
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildMainContent(),
    );
  }

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

        // 🔄 จัดกลุ่มข้อมูล
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
            case "lastTwoDigits":
              grouped["lastTwo"] = item["number"];
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

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget showmoney(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildNumberGrid(List<dynamic> numbers, {Color color = Colors.red}) {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: numbers
          .map(
            (num) => Text(
              num.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget buildMainContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // รางวัลที่ 1
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text("รางวัลที่ 1", style: TextStyle(fontSize: 28)),
                Text(
                  winners['first'] ?? "-",
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                const Text("รางวัลละ 6,000,000 บาท"),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // รางวัลที่ 2
        buildSectionTitle("รางวัลที่ 2 "),
        buildNumberGrid((winners['second'] ?? []) as List<dynamic>),
        showmoney("รางวัล 200,000 บาท"),

        // รางวัลที่ 3
        buildSectionTitle("รางวัลที่ 3 "),
        buildNumberGrid((winners['third'] ?? []) as List<dynamic>),
        showmoney("80,000 บาท"),

        const Divider(height: 32),

        // เลขท้าย 3 ตัว
        buildSectionTitle("เลขท้าย 3 ตัว"),
        buildNumberGrid((winners['lastThree'] ?? []) as List<dynamic>),
        showmoney("4,000 บาท"),

        const SizedBox(height: 24),

        // เลขท้าย 2 ตัว
        buildSectionTitle("เลขท้าย 2 ตัว "),
        showmoney("2,000 บาท"),
        Text(
          winners['lastTwo'] ?? "-",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
