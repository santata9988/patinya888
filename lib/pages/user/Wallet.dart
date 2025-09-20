import 'package:flutter/material.dart';
import 'package:patinya888/pages/user/mainhome.dart'; // สำหรับใช้ AppState

class WalletPage extends StatelessWidget {
  final AppState app;
  final VoidCallback onChange;
  final Color blue;

  const WalletPage({
    Key? key,
    required this.app,
    required this.onChange,
    required this.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('กระเป๋าเงิน', style: TextStyle(color: blue)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ยอดเงินของคุณ',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              '${app.member.wallet} บาท',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                onChange(); // รีโหลดข้อมูลใหม่
              },
              icon: const Icon(Icons.refresh, color: Colors.black),
              label: const Text("รีเฟรช", style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}