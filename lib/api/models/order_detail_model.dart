// To parse this JSON data, do
//
//     final orderDetailModel = orderDetailModelFromJson(jsonString);

import 'dart:convert';

OrderDetailModel orderDetailModelFromJson(String str) => OrderDetailModel.fromJson(json.decode(str));

String orderDetailModelToJson(OrderDetailModel data) => json.encode(data.toJson());

class OrderDetailModel {
  int? id;
  String? namePoint;
  DateTime? toTime;
  String? city;
  String? district;
  String? subDistrict;
  String? detailAddress;
  String? strAddress;
  int? poinNumber;
  int? employeeId;
  int? status;
  String? customerName;
  String? customerPhone;
  List<Detail>? details;
  int? totalQuantity;
  int? totalMoney;
  DateTime? timeFinished;

  OrderDetailModel({
    this.id,
    this.namePoint,
    this.toTime,
    this.city,
    this.district,
    this.subDistrict,
    this.detailAddress,
    this.poinNumber,
    this.employeeId,
    this.status,
    this.customerName,
    this.customerPhone,
    this.details,
    this.totalQuantity,
    this.totalMoney,
    this.timeFinished,
    this.strAddress,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) => OrderDetailModel(
    id: json["id"],
    namePoint: json["name_point"],
    toTime: json["to_time"] == null ? null : DateTime.parse(json["to_time"]),
    city: json["city"],
    district: json["district"],
    subDistrict: json["sub_district"],
    detailAddress: json["detail_address"],
    poinNumber: json["poin_number"],
    employeeId: json["employee_id"],
    status: json["status"],
    customerName: json["customer_name"],
    customerPhone: json["customer_phone"],
    details: json["details"] == null ? [] : List<Detail>.from(json["details"]!.map((x) => Detail.fromJson(x))),
    totalQuantity: json["total_quantity"],
    totalMoney: json["total_money"],
    timeFinished: json["time_finished"] == null ? null : DateTime.parse(json["time_finished"]),
    strAddress: json["str_address"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name_point": namePoint,
    "to_time": toTime?.toIso8601String(),
    "city": city,
    "district": district,
    "sub_district": subDistrict,
    "detail_address": detailAddress,
    "poin_number": poinNumber,
    "employee_id": employeeId,
    "status": status,
    "customer_name": customerName,
    "customer_phone": customerPhone,
    "details": details == null ? [] : List<dynamic>.from(details!.map((x) => x.toJson())),
    "total_quantity": totalQuantity,
    "total_money": totalMoney,
    "time_finished": timeFinished?.toIso8601String(),
    "str_address": strAddress,
  };
}

class Detail {
  int? id;
  String? productName;
  dynamic productImage;
  String? unit;
  int? quantity;
  int? deliveryQuantity;
  int? deliveredQuantity;
  int? actualQuantity;
  int? total;
  int? orderId;

  Detail({
    this.id,
    this.productName,
    this.productImage,
    this.unit,
    this.quantity,
    this.deliveryQuantity,
    this.deliveredQuantity,
    this.actualQuantity,
    this.total,
    this.orderId,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    id: json["id"],
    productName: json["product_name"],
    productImage: json["product_image"],
    unit: json["unit"],
    quantity: json["quantity"],
    deliveryQuantity: json["delivery_quantity"],
    deliveredQuantity: json["delivered_quantity"],
    actualQuantity: json["actual_quantity"],
    total: json["total"],
    orderId: json["order_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_name": productName,
    "product_image": productImage,
    "unit": unit,
    "quantity": quantity,
    "delivery_quantity": deliveryQuantity,
    "delivered_quantity": deliveredQuantity,
    "actual_quantity": actualQuantity,
    "total": total,
    "order_id": orderId,
  };
}
