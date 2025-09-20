// To parse this JSON data, do
//
//     final customerRegisterPostRequest = customerRegisterPostRequestFromJson(jsonString);

import 'dart:convert';

CustomerRegisterPostRequest customerRegisterPostRequestFromJson(String str) => CustomerRegisterPostRequest.fromJson(json.decode(str));

String customerRegisterPostRequestToJson(CustomerRegisterPostRequest data) => json.encode(data.toJson());

class CustomerRegisterPostRequest {
    int id;
    String name;
    String loginTel;
    String password;
    String role;
    int wallet;

    CustomerRegisterPostRequest({
        required this.id,
        required this.name,
        required this.loginTel,
        required this.password,
        required this.role,
        required this.wallet,
    });

    factory CustomerRegisterPostRequest.fromJson(Map<String, dynamic> json) => CustomerRegisterPostRequest(
        id: json["id"],
        name: json["name"],
        loginTel: json["login_tel"],
        password: json["password"],
        role: json["role"],
        wallet: json["wallet"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "login_tel": loginTel,
        "password": password,
        "role": role,
        "wallet": wallet,
    };
}
