// To parse this JSON data, do
//
//     final customerIdxGetResponse = customerIdxGetResponseFromJson(jsonString);

import 'dart:convert';

CustomerIdxGetResponse customerIdxGetResponseFromJson(String str) =>
    CustomerIdxGetResponse.fromJson(json.decode(str));

String customerIdxGetResponseToJson(CustomerIdxGetResponse data) =>
    json.encode(data.toJson());

class CustomerIdxGetResponse {
  int id;
  String name;
  String loginTel;
  String? password; // ✅ อาจเป็น null ได้
  String role;
  int wallet;

  CustomerIdxGetResponse({
    required this.id,
    required this.name,
    required this.loginTel,
    this.password,
    required this.role,
    required this.wallet,
  });

  factory CustomerIdxGetResponse.fromJson(Map<String, dynamic> json) {
    return CustomerIdxGetResponse(
      id: json["id"] ?? 0,
      name: json["name"]?.toString() ?? "",
      loginTel: json["login_tel"]?.toString() ?? "",
      password: json["password"]?.toString(),
      role: json["role"]?.toString() ?? "member",
      wallet: json["wallet"] is int
          ? json["wallet"]
          : int.tryParse(json["wallet"].toString().split(".").first) ??
                0, // ✅ parse "2222.00" → 2222
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "login_tel": loginTel,
    "password": password,
    "role": role,
    "wallet": wallet,
  };
}
