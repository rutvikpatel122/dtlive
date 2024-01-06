// To parse this JSON data, do
// final paymentOptionModel = paymentOptionModelFromJson(jsonString);

import 'dart:convert';

PaymentOptionModel paymentOptionModelFromJson(String str) =>
    PaymentOptionModel.fromJson(json.decode(str));

String paymentOptionModelToJson(PaymentOptionModel data) =>
    json.encode(data.toJson());

class PaymentOptionModel {
  PaymentOptionModel({
    this.status,
    this.message,
    this.result,
  });

  int? status;
  String? message;
  Result? result;

  factory PaymentOptionModel.fromJson(Map<String, dynamic> json) =>
      PaymentOptionModel(
        status: json["status"],
        message: json["message"],
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? {} : result?.toJson() ?? {},
      };
}

class Result {
  Result({
    this.inAppPurchage,
    this.paypal,
    this.razorpay,
    this.flutterWave,
    this.payUMoney,
    this.payTm,
    this.stripe,
    this.cash,
  });

  PaymentGatewayData? inAppPurchage;
  PaymentGatewayData? paypal;
  PaymentGatewayData? razorpay;
  PaymentGatewayData? flutterWave;
  PaymentGatewayData? payUMoney;
  PaymentGatewayData? payTm;
  PaymentGatewayData? stripe;
  PaymentGatewayData? cash;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        inAppPurchage: PaymentGatewayData.fromJson(json["inapppurchage"]),
        paypal: PaymentGatewayData.fromJson(json["paypal"]),
        razorpay: PaymentGatewayData.fromJson(json["razorpay"]),
        flutterWave: PaymentGatewayData.fromJson(json["flutterwave"]),
        payUMoney: PaymentGatewayData.fromJson(json["payumoney"]),
        payTm: PaymentGatewayData.fromJson(json["paytm"]),
        stripe: PaymentGatewayData.fromJson(json["stripe"]),
        cash: PaymentGatewayData.fromJson(json["cash"]),
      );

  Map<String, dynamic> toJson() => {
        "inapppurchage":
            inAppPurchage == null ? {} : inAppPurchage?.toJson() ?? {},
        "paypal": paypal == null ? {} : paypal?.toJson() ?? {},
        "razorpay": razorpay == null ? {} : razorpay?.toJson() ?? {},
        "flutterwave": flutterWave == null ? {} : flutterWave?.toJson() ?? {},
        "payumoney": payUMoney == null ? {} : payUMoney?.toJson() ?? {},
        "paytm": payTm == null ? {} : payTm?.toJson() ?? {},
        "stripe": stripe == null ? {} : stripe?.toJson() ?? {},
        "cash": cash == null ? {} : cash?.toJson() ?? {},
      };
}

class PaymentGatewayData {
  PaymentGatewayData({
    this.id,
    this.name,
    this.visibility,
    this.isLive,
    this.liveKey1,
    this.liveKey2,
    this.liveKey3,
    this.testKey1,
    this.testKey2,
    this.testKey3,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  String? name;
  String? visibility;
  String? isLive;
  String? liveKey1;
  String? liveKey2;
  String? liveKey3;
  String? testKey1;
  String? testKey2;
  String? testKey3;
  String? createdAt;
  String? updatedAt;

  factory PaymentGatewayData.fromJson(Map<String, dynamic> json) =>
      PaymentGatewayData(
        id: json["id"],
        name: json["name"],
        visibility: json["visibility"],
        isLive: json["is_live"],
        liveKey1: json["live_key_1"],
        liveKey2: json["live_key_2"],
        liveKey3: json["live_key_3"],
        testKey1: json["test_key_1"],
        testKey2: json["test_key_2"],
        testKey3: json["test_key_3"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "visibility": visibility,
        "is_live": isLive,
        "live_key_1": liveKey1,
        "live_key_2": liveKey2,
        "live_key_3": liveKey3,
        "test_key_1": testKey1,
        "test_key_2": testKey2,
        "test_key_3": testKey3,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
