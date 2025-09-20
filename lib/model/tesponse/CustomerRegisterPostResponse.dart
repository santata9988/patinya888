// To parse this JSON data, do
//
//     final customerRegisterPostResponse = customerRegisterPostResponseFromJson(jsonString);

import 'dart:convert';

CustomerRegisterPostResponse customerRegisterPostResponseFromJson(String str) => CustomerRegisterPostResponse.fromJson(json.decode(str));

String customerRegisterPostResponseToJson(CustomerRegisterPostResponse data) => json.encode(data.toJson());

class CustomerRegisterPostResponse {
    String message;
    int id;

    CustomerRegisterPostResponse({
        required this.message,
        required this.id,
    });

    factory CustomerRegisterPostResponse.fromJson(Map<String, dynamic> json) => CustomerRegisterPostResponse(
        message: json["message"],
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "id": id,
    };
}
