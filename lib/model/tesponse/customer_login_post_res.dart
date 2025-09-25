// To parse this JSON data, do
//
//     final customerLoginPostResponse = customerLoginPostResponseFromJson(jsonString);

import 'dart:convert';

CustomerLoginPostResponse customerLoginPostResponseFromJson(String str) =>
    CustomerLoginPostResponse.fromJson(json.decode(str));

String customerLoginPostResponseToJson(CustomerLoginPostResponse data) =>
    json.encode(data.toJson());

class CustomerLoginPostResponse {
  String token;
  User user;

  CustomerLoginPostResponse({required this.token, required this.user});

  factory CustomerLoginPostResponse.fromJson(Map<String, dynamic> json) =>
      CustomerLoginPostResponse(
        token: json["token"],
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {"token": token, "user": user.toJson()};
}

class User {
  int id;
  String name;
  String loginTel;
  String password;
  String role;
  int wallet;

  User({
    required this.id,
    required this.name,
    required this.loginTel,
    required this.password,
    required this.role,
    required this.wallet,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: int.tryParse(json["id"].toString()) ?? 0,
    name: json["name"] ?? json["NAME"] ?? "", // 🔒 แก้จุดที่ทำให้ error
    loginTel: json["login_tel"] ?? "",
    password: json["password"] ?? "",
    role: json["role"] ?? "",
    wallet: int.tryParse(json["wallet"].toString()) ?? 0,
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
