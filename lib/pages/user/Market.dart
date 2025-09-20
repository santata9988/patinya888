import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:patinya888/config/internal_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SearchMode { full, head2, head3, tail2, tail3 }

class MarketPage extends StatefulWidget {
  final VoidCallback onChange;
  final Color blue;

  const MarketPage({Key? key, required this.onChange, required this.blue})
      : super(key: key);

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  List<dynamic> tickets = [];
  bool isLoading = true;
  String searchTerm = '';
  SearchMode searchMode = SearchMode.full;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  List<dynamic> get filteredTickets {
    if (searchTerm.isEmpty) return tickets;
    return tickets.where((t) {
      final number = t["number"]?.toString() ?? "";
      switch (searchMode) {
        case SearchMode.full:
          return number.contains(searchTerm);
        case SearchMode.head2:
          return number.startsWith(searchTerm.padLeft(2, '0'));
        case SearchMode.head3:
          return number.startsWith(searchTerm.padLeft(3, '0'));
        case SearchMode.tail2:
          return number.endsWith(searchTerm.padLeft(2, '0'));
        case SearchMode.tail3:
          return number.endsWith(searchTerm.padLeft(3, '0'));
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('ซื้อลอตเตอรี่', style: TextStyle(color: widget.blue)),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
              ? const Center(
                  child: Text(
                    "❌ ไม่มีเลขลอตเตอรี่เหลือขายแล้ว หรือยังไม่มีการเพิ่มเลขในระบบ",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[850],
                                hintText: 'ค้นหาเลขลอตเตอรี่',
                                hintStyle: const TextStyle(color: Colors.white70),
                                prefixIcon: Icon(Icons.search, color: widget.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchTerm = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<SearchMode>(
                            value: searchMode,
                            dropdownColor: Colors.grey[900],
                            style: const TextStyle(color: Colors.white),
                            iconEnabledColor: widget.blue,
                            items: const [
                              DropdownMenuItem(value: SearchMode.full, child: Text("ทั้งหมด")),
                              DropdownMenuItem(value: SearchMode.head2, child: Text("ขึ้นต้น 2 ตัว")),
                              DropdownMenuItem(value: SearchMode.head3, child: Text("ขึ้นต้น 3 ตัว")),
                              DropdownMenuItem(value: SearchMode.tail2, child: Text("เลขท้าย 2 ตัว")),
                              DropdownMenuItem(value: SearchMode.tail3, child: Text("เลขท้าย 3 ตัว")),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  searchMode = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filteredTickets.isEmpty
                          ? const Center(
                              child: Text(
                                "ไม่พบเลขที่ค้นหา",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredTickets.length,
                              itemBuilder: (context, index) {
                                final ticket = filteredTickets[index];
                                return Card(
                                  color: Colors.grey[900],
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: Icon(Icons.confirmation_number, color: widget.blue),
                                    title: Text(
                                      'เลข ${ticket["number"]}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      'ราคา ${ticket["price"]} บาท',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    trailing: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: widget.blue),
                                      onPressed: () => buyTicket(ticket),
                                      child: const Text('ซื้อ', style: TextStyle(color: Colors.black)),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Future<void> fetchTickets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) throw Exception("ยังไม่มี Token กรุณาเข้าสู่ระบบก่อน");

      final res = await http.get(
        Uri.parse('$API_ENDPOINT/lotto'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data == null || data.isEmpty) {
          throw Exception("ไม่มีเลขลอตเตอรี่ในระบบ");
        }

        setState(() {
          tickets = data.where((t) => t["isSold"] == false).toList();
          isLoading = false;
        });
      } else {
        throw Exception("โหลดลอตเตอรี่ไม่สำเร็จ (${res.statusCode})");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ เกิดข้อผิดพลาด: $e")),
      );
    }
  }

  Future<void> buyTicket(dynamic ticket) async {
    if (ticket["price"] < 80) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ ไม่สามารถซื้อเลขนี้ได้ เนื่องจากราคาต่ำกว่า 80 บาท'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการซื้อ'),
        content: Text('คุณต้องการซื้อเลข ${ticket["number"]} ใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('ยกเลิก')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: widget.blue),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ยืนยัน', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) throw Exception("ยังไม่มี Token");

      final res = await http.post(
        Uri.parse('$API_ENDPOINT/lotto/buy'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"number": ticket["number"]}),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("คุณซื้อเลข ${ticket["number"]} เรียบร้อยแล้ว"),
            backgroundColor: Colors.green,
          ),
        );
        fetchTickets();
        widget.onChange();
      } else {
        final error = jsonDecode(res.body);
        throw Exception(error["error"] ?? "ซื้อไม่สำเร็จ");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ เกิดข้อผิดพลาด: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}