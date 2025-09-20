// To parse this JSON data, do
//
//     final customerLoginPostRequest = customerLoginPostRequestFromJson(jsonString);

import 'dart:convert';

CustomerLoginPostRequest customerLoginPostRequestFromJson(String str) => CustomerLoginPostRequest.fromJson(json.decode(str));

String customerLoginPostRequestToJson(CustomerLoginPostRequest data) => json.encode(data.toJson());

class CustomerLoginPostRequest {
    String loginTel;
    String password;

    CustomerLoginPostRequest({
        required this.loginTel,
        required this.password,
    });

    factory CustomerLoginPostRequest.fromJson(Map<String, dynamic> json) => CustomerLoginPostRequest(
        loginTel: json["login_tel"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "login_tel": loginTel,
        "password": password,
    };
}
