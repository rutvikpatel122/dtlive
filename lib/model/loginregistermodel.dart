// To parse this JSON data, do
// final loginRegisterModel = loginRegisterModelFromJson(jsonString);

import 'dart:convert';

LoginRegisterModel profileModelFromJson(String str) =>
    LoginRegisterModel.fromJson(json.decode(str));

String profileModelToJson(LoginRegisterModel data) =>
    json.encode(data.toJson());

class LoginRegisterModel {
  int? status;
  String? message;
  List<Result>? result;

  LoginRegisterModel({
    this.status,
    this.message,
    this.result,
  });

  factory LoginRegisterModel.fromJson(Map<String, dynamic> json) =>
      LoginRegisterModel(
        status: json["status"],
        message: json["message"],
        result: List<Result>.from(
            json["result"]?.map((x) => Result.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  int? id;
  String? name;
  String? userName;
  String? mobile;
  String? email;
  String? password;
  String? gender;
  String? image;
  int? status;
  int? type;
  String? expiryDate;
  String? apiToken;
  String? emailVerifyToken;
  String? isEmailVerify;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.name,
    this.userName,
    this.mobile,
    this.email,
    this.password,
    this.gender,
    this.image,
    this.status,
    this.type,
    this.expiryDate,
    this.apiToken,
    this.emailVerifyToken,
    this.isEmailVerify,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        userName: json["user_name"],
        mobile: json["mobile"],
        email: json["email"],
        password: json["password"],
        gender: json["gender"],
        image: json["image"],
        status: json["status"],
        type: json["type"],
        expiryDate: json["expiry_date"],
        apiToken: json["api_token"],
        emailVerifyToken: json["email_verify_token"],
        isEmailVerify: json["is_email_verify"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "user_name": userName,
        "mobile": mobile,
        "email": email,
        "password": password,
        "gender": gender,
        "image": image,
        "status": status,
        "type": type,
        "expiry_date": expiryDate,
        "api_token": apiToken,
        "email_verify_token": emailVerifyToken,
        "is_email_verify": isEmailVerify,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
