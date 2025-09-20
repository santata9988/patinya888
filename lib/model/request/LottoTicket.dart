// To parse this JSON data, do
//
//     final lottoTicket = lottoTicketFromJson(jsonString);

import 'dart:convert';

LottoTicket lottoTicketFromJson(String str) => LottoTicket.fromJson(json.decode(str));

String lottoTicketToJson(LottoTicket data) => json.encode(data.toJson());

class LottoTicket {
    String number;
    int price;
    bool isSold;
    dynamic buyerId;
    bool claimed;

    LottoTicket({
        required this.number,
        required this.price,
        required this.isSold,
        required this.buyerId,
        required this.claimed,
    });

    factory LottoTicket.fromJson(Map<String, dynamic> json) => LottoTicket(
        number: json["number"],
        price: json["price"],
        isSold: json["isSold"],
        buyerId: json["buyerId"],
        claimed: json["claimed"],
    );

    Map<String, dynamic> toJson() => {
        "number": number,
        "price": price,
        "isSold": isSold,
        "buyerId": buyerId,
        "claimed": claimed,
    };
}
