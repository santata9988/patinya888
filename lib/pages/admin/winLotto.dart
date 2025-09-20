import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:patinya888/config/internal_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Winlotto extends StatefulWidget {
  const Winlotto({super.key});

  @override
  State<Winlotto> createState() => _WinlottoState();
}

class _WinlottoState extends State<Winlotto> {
  List<dynamic> winners = [];
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "เลขที่ถูกรางวัล",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildContent(),
    );
  }

  final prizeMap = {
    'first': 'รางวัลที่ 1',
    'second': 'รางวัลที่ 2',
    'third': 'รางวัลที่ 3',
    'lastTwoDigits': 'เลขท้าย 2 ตัว',
    'lastThreeDigits': 'เลขท้าย 3 ตัว (จากรางวัลที่ 1)',
  };

  final prizeMoney = {
    'first': '6,000,000 บาท',
    'second': '200,000 บาท',
    'third': '80,000 บาท',
    'lastTwoDigits': '2,000 บาท',
    'lastThreeDigits': '4,000 บาท',
  };

  @override
  void initState() {
    super.initState();
    fetchWinners();
  }

  Widget buildPrizeCard(String type, String number) {
    String prizeTitle = prizeMap.containsKey(type) ? prizeMap[type]! : type;
    String money = prizeMoney.containsKey(type) ? prizeMoney[type]! : "-";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.emoji_events, color: Colors.amber),
        title: Text(
          "$prizeTitle - $number",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text("เงินรางวัล: $money"),
      ),
    );
  }

  Widget buildContent() {
    if (winners.isEmpty) {
      return const Center(child: Text("ยังไม่มีการบันทึกรางวัล"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: winners.length,
      itemBuilder: (context, index) {
        final item = winners[index];
        return buildPrizeCard(item['type'], item['number']);
      },
    );
  }

  Future<void> fetchWinners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("ยังไม่มี Token กรุณาเข้าสู่ระบบก่อน");
      }

      final res = await http.get(
        Uri.parse('$API_ENDPOINT/winners'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);

        // ✅ หารางวัลที่ 1 แบบไม่ใช้ ?. หรือ orElse
        String firstPrizeNumber = "";
        for (int i = 0; i < data.length; i++) {
          if (data[i]['type'] == 'first') {
            firstPrizeNumber = data[i]['number'];
            break;
          }
        }

        // ✅ ตรวจสอบว่ามี lastThreeFromFirst หรือยัง
        bool hasLastThree = false;
        for (int i = 0; i < data.length; i++) {
          if (data[i]['type'] == 'lastThreeDigits') {
            hasLastThree = true;
            break;
          }
        }

        if (firstPrizeNumber != "" && !hasLastThree) {
          String lastThree = firstPrizeNumber.substring(3);
          data.add({'type': 'lastThreeDigits', 'number': lastThree});
        }

        setState(() {
          winners = data;
          isLoading = false;
        });
      } else {
        throw Exception("โหลดข้อมูลไม่สำเร็จ (${res.statusCode})");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ เกิดข้อผิดพลาด: $e")));
    }
  }
}
