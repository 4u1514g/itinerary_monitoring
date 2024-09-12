// To parse this JSON data, do
//
//     final orderModel = orderModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

OrderModel orderModelFromJson(String str) => OrderModel.fromJson(json.decode(str));

String orderModelToJson(OrderModel data) => json.encode(data.toJson());

class OrderModel {
  int? id;
  String? namePoint;
  DateTime? toTime;
  String? city;
  String? district;
  String? subDistrict;
  String? detailAddress;
  int? poinNumber;
  int? employeeId;
  int? status;
  DateTime? timeFinished;
  String? customerName;
  String? customerPhone;
  dynamic ctNumber;
  int? totalQuantity;
  int? totalMoney;
  String? strDistance;
  String? strDuration;
  String? strAddress;
  double? lng;
  double? lat;
  List<PointLatLng>? overviewPolyline;

  OrderModel({
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
    this.timeFinished,
    this.customerName,
    this.customerPhone,
    this.ctNumber,
    this.totalQuantity,
    this.totalMoney,
    this.strDistance,
    this.strDuration,
    this.strAddress,
    this.lng,
    this.lat,
    this.overviewPolyline,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
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
        timeFinished: json["time_finished"] == null ? null : DateTime.parse(json["time_finished"]),
        customerName: json["customer_name"],
        customerPhone: json["customer_phone"],
        ctNumber: json["ct_number"],
        totalQuantity: json["total_quantity"],
        totalMoney: json["total_money"],
        strDistance: json["str_distance"],
        strDuration: json["str_duration"],
        strAddress: json["str_address"],
        lng: json["lng"]?.toDouble(),
        lat: json["lat"]?.toDouble(),
        overviewPolyline: json["overview_polyline"] == null
            ? null
            : PolylinePoints().decodePolyline(json["overview_polyline"]),
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
        "time_finished": timeFinished?.toIso8601String(),
        "customer_name": customerName,
        "customer_phone": customerPhone,
        "ct_number": ctNumber,
        "total_quantity": totalQuantity,
        "total_money": totalMoney,
        "str_distance": strDistance,
        "str_duration": strDuration,
        "str_address": strAddress,
        "lng": lng,
        "lat": lat,
        "overview_polyline": overviewPolyline,
      };
}
