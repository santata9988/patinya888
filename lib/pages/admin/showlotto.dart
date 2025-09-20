import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:patinya888/config/internal_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowLotto extends StatefulWidget {
  const ShowLotto({super.key});

  @override
  State<ShowLotto> createState() => _ShowLottoState();
}

class _ShowLottoState extends State<ShowLotto> {
  List<dynamic> allLotto = [];
  List<dynamic> soldLotto = [];
  List<dynamic> unsoldLotto = [];
  List<dynamic> winnerLotto = [];

  String selectedCategory = "all";
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ล็อตเตอรี่ทั้งหมด",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildContent(),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchLotto();
  }

  // Widget สำหรับแสดงรายการลอตเตอรี่
  Widget buildLottoList(List<dynamic> list) {
    return Column(
      children: list.map((lotto) {
        final number = lotto['number'];
        final isSold = lotto['isSold'];
        final isWinner = lotto['isWinner'];
        final claimed = lotto['claimed'];
        final buyerId = lotto['buyerId'];

        List<Widget> chipWidgets = [];

        if (isSold == true) {
          chipWidgets.add(
            const Chip(label: Text("ขายแล้ว"), backgroundColor: Colors.green),
          );
        } else {
          chipWidgets.add(
            const Chip(label: Text("ยังไม่ขาย"), backgroundColor: Colors.grey),
          );
        }

        if (isWinner == true) {
          chipWidgets.add(
            const Chip(label: Text("ถูกรางวัล"), backgroundColor: Colors.amber),
          );
        }

        if (claimed == true) {
          chipWidgets.add(
            const Chip(
              label: Text("เคลมแล้ว"),
              backgroundColor: Colors.blueAccent,
            ),
          );
        }

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.confirmation_number),
            title: Text("เลข: $number"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 6, children: chipWidgets),
                if (buyerId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "ผู้ซื้อ: $buyerId",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildContent() {
    List<dynamic> currentList;

    switch (selectedCategory) {
      case "sold":
        currentList = soldLotto;
        break;
      case "unsold":
        currentList = unsoldLotto;
        break;
      case "winner":
        currentList = winnerLotto;
        break;
      default:
        currentList = allLotto;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          buildCategorySelector(),
          const SizedBox(height: 12),
          buildLottoList(currentList),
        ],
      ),
    );
  }

  // Widget สำหรับสร้างปุ่มเลือกหมวดหมู่
  Widget buildCategorySelector() {
    final categories = {
      "all": "🎟 ทั้งหมด",
      "sold": "✅ ขายแล้ว",
      "unsold": "🕳 ยังไม่ขาย",
      "winner": "🏆 ถูกรางวัล",
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.entries.map((entry) {
          final key = entry.key;
          final label = entry.value;
          final isSelected = selectedCategory == key;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              onPressed: () {
                setState(() {
                  selectedCategory = key;
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: isSelected ? Colors.black : Colors.grey[300],
                foregroundColor: isSelected ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Text(label),
            ),
          );
        }).toList(),
      ),
    );
  }
  // ฟังก์ชันสำหรับดึงข้อมูลลอตเตอรี่จาก API

  Future<void> fetchLotto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("ยังไม่มี Token กรุณาเข้าสู่ระบบก่อน");
      }

      final lottoRes = await http.get(
        Uri.parse('$API_ENDPOINT/lotto'),
        headers: {"Authorization": "Bearer $token"},
      );

      final winnerRes = await http.get(
        Uri.parse('$API_ENDPOINT/winners'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (lottoRes.statusCode == 200 && winnerRes.statusCode == 200) {
        final List<dynamic> data = jsonDecode(lottoRes.body);
        final List<dynamic> winners = jsonDecode(winnerRes.body);
        final winnerNumbers = winners.map((w) => w['number']).toSet();

        final updated = data.map((lotto) {
          return {
            ...lotto,
            'isWinner': winnerNumbers.contains(lotto['number']),
          };
        }).toList();

        setState(() {
          allLotto = updated;
          soldLotto = updated.where((e) => e['isSold'] == true).toList();
          unsoldLotto = updated.where((e) => e['isSold'] == false).toList();
          winnerLotto = updated.where((e) => e['isWinner'] == true).toList();
          isLoading = false;
        });
      } else {
        throw Exception("โหลดข้อมูลไม่สำเร็จ");
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
