import 'package:dio/dio.dart';
import 'package:itinerary_monitoring/api/models/employee_model.dart';
import 'package:itinerary_monitoring/api/models/order_detail_model.dart';
import 'package:itinerary_monitoring/api/models/order_model.dart';
import 'package:itinerary_monitoring/api/models/user_model.dart';

String baseUrl = 'https://sse.gover.vn/api/v1';
Dio dio = Dio()
  ..options.headers = {
    "Accept": "application/json",
  };

Future<UserModel> login({String? account, String? pass}) async {
  final data = {"username": account, "password": pass};
  final result = await dio.post("$baseUrl/auth/login", data: data);
  final value = UserModel.fromJson(result.data!);
  return value;
}

Future<Map> getInit({String? token}) async {
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.get("$baseUrl/init", options: Options(headers: headers));
  return result.data;
}

Future<List<OrderModel>> getMyOrderToday({String? token}) async {
  final queryParameters = <String, dynamic>{};
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.get(
    "$baseUrl/order/my-order/list-address",
    queryParameters: queryParameters,
    options: Options(headers: headers),
  );
  var value = List<OrderModel>.from(result.data!.map((x) => OrderModel.fromJson(x)));
  return value;
}

Future<List<OrderModel>> getMyOrder({
  String? fromdate,
  String? todate,
  String? token,
  int? page,
  int? limit,
}) async {
  final queryParameters = <String, dynamic>{
    r'fromdate': fromdate,
    r'todate': todate,
    r'page': page,
    r'limit': limit,
  };
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.get(
    "$baseUrl/order/my-order",
    queryParameters: queryParameters,
    options: Options(headers: headers),
  );
  var value = List<OrderModel>.from(result.data!.map((x) => OrderModel.fromJson(x)));
  return value;
}

Future<OrderDetailModel> getOrderDetail({int? id, String? token}) async {
  final queryParameters = <String, dynamic>{};
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.get(
    "$baseUrl/order/my-order/detail/$id",
    queryParameters: queryParameters,
    options: Options(headers: headers),
  );
  final value = OrderDetailModel.fromJson(result.data!);
  return value;
}

Future<dynamic> updateOrder({int? id, String? token}) async {
  final queryParameters = <String, dynamic>{};
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.put(
    "$baseUrl/order/my-order/confirm/$id",
    queryParameters: queryParameters,
    options: Options(headers: headers),
  );
  return result.data;
}

Future<dynamic> startSession({String? token}) async {
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.post("$baseUrl/session/start", options: Options(headers: headers));
  return result.data;
}

Future<dynamic> updateLocation({double? lat, double? lng, String? token}) async {
  final headers = <String, dynamic>{r'token': token};
  final data = {"lat": lat, "lng": lng};
  final result = await dio.put("$baseUrl/location/update-my-location",
      data: data, options: Options(headers: headers));
  return result.data;
}

/////////////////////////////////////////////////////
Future<List<EmployeeModel>> getEmployee({String? token}) async {
  final queryParameters = <String, dynamic>{};
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.get(
    "$baseUrl/manager/location-current-employee",
    queryParameters: queryParameters,
    options: Options(headers: headers),
  );
  var value = List<EmployeeModel>.from(result.data!.map((x) => EmployeeModel.fromJson(x)));
  return value;
}

Future<List<OrderModel>> getEmployeeOrder({String? date, int? id, String? token}) async {
  final queryParameters = <String, dynamic>{r'date': date, r'employee_id': id};
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.get(
    "$baseUrl/manager/history-by-employee",
    queryParameters: queryParameters,
    options: Options(headers: headers),
  );
  var value = List<OrderModel>.from(result.data!.map((x) => OrderModel.fromJson(x)));
  return value;
}

Future<List<EmployeeModel>> getEmployeeRoute({String? date, int? id, String? token}) async {
  final queryParameters = <String, dynamic>{r'date': date, r'employee_id': id};
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.get(
    "$baseUrl/manager/history-route-employee",
    queryParameters: queryParameters,
    options: Options(headers: headers),
  );
  var value = List<EmployeeModel>.from(result.data!.map((x) => EmployeeModel.fromJson(x)));
  return value;
}
