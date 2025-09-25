class LottoTicket {
  final int id;          // 🟦 เพิ่ม id สำหรับอ้างอิงตั๋ว
  final String number;   // เลขลอตเตอรี่
  final double price;    // ราคา
  bool isSold;           // ขายแล้วหรือยัง
  bool isWinner;         // ถูกรางวัลไหม
  bool isClaimed;        // ขึ้นเงินหรือยัง
  String? winningType;   // ประเภทรางวัล เช่น first, lastTwoDigits

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
      id: json['id'] ?? 0,  // ✅ map id จาก API
      number: json['number'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 80.0,
      isSold: json['isSold'].toString() == "1" || json['isSold'] == true,
      isWinner: json['isWinner'].toString() == "1" || json['isWinner'] == true,
      isClaimed: json['claimed'].toString() == "1" || json['claimed'] == true,
      winningType: json['prizeType'] ?? "",
    );
  }
}