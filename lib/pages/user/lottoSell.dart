import 'package:flutter/material.dart';

class ShowLottoSell extends StatefulWidget {
  const ShowLottoSell({super.key});

  @override
  State<ShowLottoSell> createState() => _ShowLottoSellState();
}

class _ShowLottoSellState extends State<ShowLottoSell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ลอตเตอรี่"),
      ),
    );
  }
}