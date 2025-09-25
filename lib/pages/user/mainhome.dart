import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:patinya888/config/internal_config.dart';
import 'package:patinya888/pages/user/Market.dart';
import 'package:patinya888/pages/user/Wallet.dart';
import 'package:patinya888/pages/user/home.dart';
import 'package:patinya888/pages/user/lottoSell.dart';
import 'package:patinya888/pages/user/profile.dart';

class LottoTicket {
  final int id; // 🟦 ต้องเพิ่ม id ตรงนี้
  final String number; // เลขลอตเตอรี่
  final double price; // ราคา
  bool isSold;
  bool isWinner;
  bool isClaimed;
  String? winningType;

  LottoTicket({
    required this.id,
    required this.number,
    this.price = 80.0,
    this.isSold = false,
    this.isWinner = false,
    this.isClaimed = false,
    this.winningType,
  });

  factory LottoTicket.fromJson(Map<String, dynamic> json) {
    return LottoTicket(
      id: json['id'] ?? 0, // ✅ map id จาก API
      number: json['number'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 80.0,
      isSold: json['isSold'].toString() == "1" || json['isSold'] == true,
      isWinner: json['isWinner'].toString() == "1" || json['isWinner'] == true,
      isClaimed: json['claimed'].toString() == "1" || json['claimed'] == true,
      winningType: json['prizeType'] ?? "",
    );
  }
}

class Member {
  String name;
  int wallet;
  final List<LottoTicket> myTickets = [];

  Member({required this.name, required this.wallet});
}

class AppState {
  final List<LottoTicket> allTickets;
  final Member member;
  Map<String, String>? winners;

  AppState({required this.allTickets, required this.member});

  List<LottoTicket> get availableTickets =>
      allTickets.where((t) => !t.isSold).toList();

  List<LottoTicket> get myTickets => member.myTickets;

  List<LottoTicket> get myUnclaimedWinners =>
      member.myTickets.where((t) => t.isWinner && !t.isClaimed).toList();

  // ✅ เพิ่ม method addTicket

  void addTicket(LottoTicket ticket) {
    member.myTickets.add(ticket);
  }

  void checkResults(Map<String, String> results) {
    winners = results;
    for (final t in allTickets) {
      t.isWinner = results.values.any(
        (prize) =>
            prize.length == 6 && t.number == prize ||
            prize.length == 3 && t.number.endsWith(prize) ||
            prize.length == 2 && t.number.endsWith(prize),
      );
    }
  }

  int prizeFor(LottoTicket t) {
    if (!t.isWinner || winners == null) return 0;

    if (t.number == winners!["first"]) return 6000000;
    if (t.number == winners!["second"]) return 200000;
    if (t.number == winners!["third"]) return 80000;
    if (t.number == winners!["fourth"]) return 4000;
    if (t.number == winners!["fifth"]) return 2000;
    if (t.number.endsWith(winners!["lastThreeDigits"] ?? '')) return 4000;
    if (t.number.endsWith(winners!["lastTwoDigits"] ?? '')) return 2000;

    return 0;
  }

  bool claimTicket(LottoTicket t) {
    if (!t.isWinner || t.isClaimed) return false;
    final prize = prizeFor(t);
    member.wallet += prize;
    t.isClaimed = true;
    return true;
  }
}

class MainApp extends StatefulWidget {
  final int userId;
  const MainApp({super.key, required this.userId});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  static const Color blue = Color.fromARGB(255, 3, 169, 244);
  AppState? app;

  @override
  void initState() {
    super.initState();
    _loadTicketsFromApi();
  }

  Future<void> _loadTicketsFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      print("Token: $token"); // ✅ ตรวจ token

      if (token == null) {
        print("❌ Token is null");
        return;
      }

      final response = await http.get(
        Uri.parse('$API_ENDPOINT/lotto'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final userRes = await http.get(
        Uri.parse('$API_ENDPOINT/users/${widget.userId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print("User body: ${userRes.body}");

      print("Lotto status: ${response.statusCode}");
      print("User status: ${userRes.statusCode}");

      if (response.statusCode == 200 && userRes.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final tickets = jsonList.map((e) => LottoTicket.fromJson(e)).toList();

        final userJson = json.decode(userRes.body);
        final member = Member(
          name: userJson["name"] ?? "ไม่ทราบชื่อ",
          wallet: userJson["wallet"] ?? 0,
        );

        setState(() {
          app = AppState(allTickets: tickets, member: member);
        });
      } else {
        print("❌ Failed API response");
      }
    } catch (e) {
      print("❌ ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (app == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = <Widget>[
      HomePage(),
      MarketPage(app: app!, onChange: () => setState(() {}), blue: blue),
      WalletPage(app: app!, onChange: () => setState(() {}), blue: blue),
      ShowLottoSell(app: app!, blue: blue),
      ProfilePage(userId: widget.userId),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "ตลาด",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "กระเป๋า",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: "ลอตเตอรี่ที่ซื้อ",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "โปรไฟล์"),
        ],
      ),
    );
  }
}
