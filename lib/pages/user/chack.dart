import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:patinya888/pages/user/mainhome.dart';
import 'package:patinya888/config/internal_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({
    super.key,
    required this.app,
    required this.onChange,
    required this.blue,
  });

  final AppState app;
  final VoidCallback onChange;
  final Color blue;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final _ctrl = TextEditingController();

  void _setWinning(String value) {
    if (value.length != 6 || int.tryParse(value) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาใส่เลข 6 หลักให้ถูกต้อง")),
      );
      return;
    }

    widget.app.checkResults({"first": value});
    setState(() {});
    widget.onChange();
  }

  Future<void> _fetchWinningFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return;

      final res = await http.get(
        Uri.parse('$API_ENDPOINT/results'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data is List) {
          final resultMap = {
            for (final item in data)
              if (item["type"] is String && item["number"] is String)
                item["type"]: item["number"]
          };

          widget.app.checkResults(resultMap);
          setState(() {});
          widget.onChange();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("โหลดผลรางวัลสำเร็จ ✅")),
          );
        } else if (data is Map<String, dynamic>) {
          // แปลง Map<String, dynamic> เป็น Map<String, String>
          final stringMap = data.map((key, value) =>
              MapEntry(key.toString(), value.toString()));
          widget.app.checkResults(stringMap);
          setState(() {});
          widget.onChange();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("โหลดผลรางวัลสำเร็จ ✅")),
          );
        } else {
          throw "ข้อมูลไม่ถูกต้อง";
        }
      } else {
        throw "โหลดไม่สำเร็จ [${res.statusCode}]";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ โหลดผลรางวัลล้มเหลว: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myWinners = widget.app.myUnclaimedWinners;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text("ตรวจผลลอตโต้", style: TextStyle(color: widget.blue)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                counterText: "",
                hintText: "กรอกเลขรางวัล 6 หลัก",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.numbers, color: Colors.white70),
              ),
              onSubmitted: _setWinning,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _fetchWinningFromApi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text(
                      "ตรวจผล",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.app.winners != null)
              _ResultBanner(
                text: "โหลดผลรางวัลจาก API แล้ว",
                blue: widget.blue,
              ),
            const SizedBox(height: 8),
            if (widget.app.winners != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "ตั๋วของฉันที่ถูกรางวัล (ยังไม่ขึ้นเงิน): ${myWinners.length}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            const SizedBox(height: 12),
            if (widget.app.winners != null)
              Expanded(
                child: myWinners.isEmpty
                    ? const Center(
                        child: Text(
                          "ยังไม่มีตั๋วถูกรางวัล",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.separated(
                        itemCount: myWinners.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final t = myWinners[i];
                          final prize = widget.app.prizeFor(t);
                          return Card(
                            color: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                t.number,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "เงินรางวัล: ${_fmt(prize)} ฿",
                                style: TextStyle(color: widget.blue),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  final ok = widget.app.claimTicket(t);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      ok
                                          ? "ขึ้นเงินสำเร็จ +${_fmt(prize)} ฿"
                                          : "ไม่สามารถขึ้นเงินได้",
                                    ),
                                  ));
                                  setState(() {});
                                  widget.onChange();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.blue,
                                ),
                                child: const Text(
                                  "ขึ้นเงิน",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    return NumberFormat("#,###").format(n);
  }
}

class NumberFormat {
  final String pattern;
  NumberFormat(this.pattern);

  String format(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final String text;
  final Color blue;
  const _ResultBanner({required this.text, required this.blue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: blue),
      ),
      child: Text(
        text,
        style: TextStyle(color: blue, fontWeight: FontWeight.bold),
      ),
    );
  }
}