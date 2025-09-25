import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:patinya888/config/internal_config.dart';
import 'package:patinya888/pages/user/mainhome.dart'; // AppState & LottoTicket

class ShowLottoSell extends StatefulWidget {
  final AppState app;
  final Color blue;

  const ShowLottoSell({super.key, required this.app, required this.blue});

  @override
  State<ShowLottoSell> createState() => _ShowLottoSellState();
}

class _ShowLottoSellState extends State<ShowLottoSell> {
  @override
  void initState() {
    super.initState();
    fetchMyTickets();
  }

  Future<void> fetchMyTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final userId = prefs.getInt("userId");

    if (token == null || userId == null) return;

    // 📌 ดึงตั๋วของผู้ใช้
    final resTickets = await http.get(
      Uri.parse('$API_ENDPOINT/users/$userId/tickets'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (resTickets.statusCode != 200) return;
    final ticketData = jsonDecode(resTickets.body) as List;

    // 📌 ดึงผลรางวัลทั้งหมด
    final resResults = await http.get(
      Uri.parse('$API_ENDPOINT/results'),
      headers: {"Authorization": "Bearer $token"},
    );

    Map<String, String> winners = {};
    if (resResults.statusCode == 200) {
      final resultData = jsonDecode(resResults.body);

      if (resultData is List) {
        winners = {
          for (final item in resultData)
            item["type"].toString(): item["number"].toString(),
        };
      } else if (resultData is Map) {
        winners = {
          for (final entry in resultData.entries)
            entry.key.toString(): (entry.value["number"] ?? "").toString(),
        };
      }

      // ✅ เก็บ winners ลง AppState
      widget.app.winners = winners;
    }

    // 📌 อัปเดตตั๋วของ user + เช็คว่าถูกรางวัลหรือไม่
    setState(() {
      widget.app.member.myTickets.clear();
      for (final t in ticketData) {
        final ticket = LottoTicket.fromJson(t);
        final num = ticket.number;

        ticket.isWinner = winners.entries.any((entry) {
          final type = entry.key;
          final prize = entry.value;

          if (type == "first" ||
              type == "second" ||
              type == "third" ||
              type == "fourth" ||
              type == "fifth") {
            return num == prize; // ตรงเลขเต็ม ๆ
          } else if (type == "lastThreeDigits") {
            return num.endsWith(prize);
          } else if (type == "lastTwoDigits") {
            return num.endsWith(prize);
          }
          return false;
        });

        widget.app.member.myTickets.add(ticket);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myTickets = widget.app.myTickets;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ลอตเตอรี่ของฉัน"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: myTickets.isEmpty
            ? const Center(
                child: Text(
                  "ยังไม่มีลอตเตอรี่ที่ซื้อไว้",
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : ListView.separated(
                itemCount: myTickets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final t = myTickets[i];
                  final prize = widget.app.prizeFor(t); // เงินรางวัล
                  final status = t.isWinner
                      ? (t.isClaimed ? "ขึ้นเงินแล้ว" : "ถูกรางวัล ✅")
                      : "ไม่ถูกรางวัล ❌";

                  return Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        "เลข: ${t.number}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "ราคา: ${t.price} ฿ | สถานะ: $status",
                        style: TextStyle(color: widget.blue),
                      ),
                      trailing: (t.isWinner && !t.isClaimed)
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.blue,
                              ),
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final token = prefs.getString("token");

                                if (token == null) return;

                                final res = await http.post(
                                  Uri.parse(
                                    '$API_ENDPOINT/tickets/${t.id}/claim',
                                  ),
                                  headers: {"Authorization": "Bearer $token"},
                                );

                                if (res.statusCode == 200) {
                                  final data = jsonDecode(res.body);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "✅ ขึ้นเงินสำเร็จ +${data['reward']} บาท",
                                      ),
                                    ),
                                  );

                                  // 🔄 รีโหลดข้อมูลใหม่
                                  await fetchMyTickets();
                                } else {
                                  final err = jsonDecode(res.body);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("❌ ${err['error']}"),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                "ขึ้นเงิน",
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
