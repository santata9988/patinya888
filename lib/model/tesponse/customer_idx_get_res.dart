// To parse this JSON data, do
//
//     final customerIdxGetResponse = customerIdxGetResponseFromJson(jsonString);

import 'dart:convert';

CustomerIdxGetResponse customerIdxGetResponseFromJson(String str) => CustomerIdxGetResponse.fromJson(json.decode(str));

String customerIdxGetResponseToJson(CustomerIdxGetResponse data) => json.encode(data.toJson());

class CustomerIdxGetResponse {
    int id;
    String name;
    String loginTel;
    String password;
    String role;
    int wallet;

    CustomerIdxGetResponse({
        required this.id,
        required this.name,
        required this.loginTel,
        required this.password,
        required this.role,
        required this.wallet,
    });

    factory CustomerIdxGetResponse.fromJson(Map<String, dynamic> json) => CustomerIdxGetResponse(
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
