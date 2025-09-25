import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:patinya888/config/internal_config.dart';

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

  // ✅ เพิ่มตัวแปร search
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchLotto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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

  // ✅ Widget สำหรับเลือกหมวดหมู่
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
              ),
              child: Text(label),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ✅ Widget สำหรับแสดงลอตเตอรี่
  Widget buildLottoList(List<dynamic> list) {
    // 🔎 กรองด้วย searchQuery
    final filteredList = list.where((lotto) {
      final number = lotto['number']?.toString() ?? '';
      return number.contains(searchQuery);
    }).toList();

    if (filteredList.isEmpty) {
      return const Center(child: Text("ไม่พบลอตเตอรี่ที่ค้นหา"));
    }

    return Column(
      children: filteredList.map((lotto) {
        final number = lotto['number'] ?? 'ไม่ทราบ';
        final isSold = lotto['isSold'] == true;
        final isWinner = lotto['isWinner'] == true;
        final claimed = lotto['claimed'] == true;
        final buyerId = lotto['buyerId'];

        List<Widget> chipWidgets = [
          Chip(
            label: Text(isSold ? "ขายแล้ว" : "ยังไม่ขาย"),
            backgroundColor: isSold ? Colors.green : Colors.grey,
          ),
        ];

        if (isWinner) {
          chipWidgets.add(
            const Chip(label: Text("ถูกรางวัล"), backgroundColor: Colors.amber),
          );
        }

        if (claimed) {
          chipWidgets.add(
            const Chip(
              label: Text("ขึ้นเงินแล้ว"),
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

  // ✅ Content
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
          // 🔎 ช่องค้นหา
          TextField(
            decoration: InputDecoration(
              hintText: "ค้นหาเลขลอตเตอรี่",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.trim();
              });
            },
          ),
          const SizedBox(height: 12),
          buildCategorySelector(),
          const SizedBox(height: 12),
          buildLottoList(currentList),
        ],
      ),
    );
  }

  // ✅ ฟังก์ชันเช็คว่าถูกรางวัลมั้ย
  bool checkWinner(String number, List winners) {
    for (var w in winners) {
      final type = w['type'];
      final prizeNum = w['number'].toString();

      if (['first', 'second', 'third', 'fourth', 'fifth'].contains(type) &&
          number == prizeNum)
        return true;

      if (type == 'lastThreeDigits' && number.endsWith(prizeNum)) return true;
      if (type == 'lastTwoDigits' && number.endsWith(prizeNum)) return true;
    }
    return false;
  }

  // ✅ ดึงข้อมูลจาก API
  Future<void> fetchLotto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) throw Exception("ยังไม่มี Token กรุณาเข้าสู่ระบบก่อน");

      final lottoRes = await http.get(
        Uri.parse('$API_ENDPOINT/lottos'),
        headers: {"Authorization": "Bearer $token"},
      );

      final winnerRes = await http.get(
        Uri.parse('$API_ENDPOINT/winners'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (lottoRes.statusCode == 200 && winnerRes.statusCode == 200) {
        final List<dynamic> data = jsonDecode(lottoRes.body);
        final List<dynamic> winners = jsonDecode(winnerRes.body);

        final updated = data.map((lotto) {
          final number =
              lotto['number']?.toString() ?? lotto['NUMBER']?.toString() ?? '';

          return {
            ...lotto,
            'number': number,
            'isSold': lotto['isSold'] == 1 || lotto['isSold'] == true,
            'claimed': lotto['claimed'] == 1 || lotto['claimed'] == true,
            'buyerId': lotto['buyerId'],
            'isWinner': checkWinner(number, winners),
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
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ เกิดข้อผิดพลาด: $e")));
    }
  }
}
