import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:itinerary_monitoring/api/api_utils.dart';
import 'package:itinerary_monitoring/api/models/order_model.dart';
import 'package:itinerary_monitoring/src/employee/employee_screen.dart';
import 'package:itinerary_monitoring/src/employee/order_detail.dart';
import 'package:itinerary_monitoring/helper/constant.dart';
import 'package:itinerary_monitoring/helper/date_picker.dart';
import 'package:itinerary_monitoring/helper/loadany.dart';
import 'package:location/location.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> with WidgetsBindingObserver {
  Location location = Location();
  LoadStatus status = LoadStatus.normal;
  List<OrderModel> list = [];
  int page = 1, limit = 15;
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    init();
    onLoadMore();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        serviceDialog();
      } else {
        _permissionGranted = await location.hasPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          serviceDialog();
        }
      }
    }
  }

  Future<void> onLoadMore() async {
    setState(() {
      status = LoadStatus.loading;
    });
    getMyOrder(
            limit: limit,
            page: page,
            fromdate: fromDate.toString().substring(0, 10),
            todate: fromDate.toString().substring(0, 10),
            token: user.token)
        .then((value) {
      list.addAll(value);
      if (value.isEmpty || value.length < limit) {
        status = LoadStatus.completed;
      } else {
        status = LoadStatus.normal;
      }
      page++;
      if (!mounted) {
        return;
      }
      setState(() {});
    }).onError((error, stackTrace) {
      setState(() {
        status = LoadStatus.error;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          GestureDetector(
            onTap: () => selectDate(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
                width: 56, height: 56, child: Icon(Icons.calendar_today, color: white)),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).viewPadding.top + 56,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xff033572), Color(0xff93B5E3)])),
            padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
            alignment: Alignment.center,
            child: setText('Danh sách đơn hàng', 18, color: white, fontWeight: FontWeight.w700),
          ),
          LoadAny(
              status: status,
              onLoadMore: onLoadMore,
              child: CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) => _item(index),
                          childCount: list.length))
                ],
              ))
        ],
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => const EmployeeScreen())),
        child: Container(
          margin: EdgeInsets.fromLTRB(kPadding, 10, kPadding, bottomPadding),
          decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(10)),
          height: 46,
          alignment: Alignment.center,
          child: setText('Tổng quan', 15, fontWeight: FontWeight.w500, color: white),
        ),
      ),
    );
  }

  _item(int index) {
    final OrderModel item = list[index];
    return GestureDetector(
      onTap: () => detailOrder(item.id!),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25), offset: const Offset(0, 2), blurRadius: 8)
        ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  setText('KH: ${item.customerName}', 14, fontWeight: FontWeight.w800),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.stay_current_portrait, color: gray, size: 18),
                      const SizedBox(width: 6),
                      setText('Số CT: ${390}', 14, color: gray),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: gray, size: 18),
                      const SizedBox(width: 6),
                      setText('Ngày: ${DateFormat('dd-MM-yyyy').format(fromDate)}', 14,
                          color: gray),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.paid_outlined, color: gray, size: 18),
                      const SizedBox(width: 6),
                      setText('Tổng thanh toán: ${0} VNĐ', 14, color: gray),
                      const Spacer(),
                      setText('Chờ giao', 14, color: purple),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, color: Color(0xff777777))
          ],
        ),
      ),
    );
  }

  void selectDate() async {
    await showMaterialModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
        builder: (context) => CustomDatePicker(date: fromDate)).then((val) {
      setState(() {
        if (val is DateTime) {
          setState(() {
            fromDate = val;
            list.clear();
            page = 1;
          });
          onLoadMore();
        }
      });
    });
  }

  void detailOrder(int id) {
    double h = MediaQuery.of(context).size.height - MediaQuery.of(context).viewPadding.top - 56;
    showMaterialModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
        builder: (context) => OrderDetail(height: h, id: id));
  }

  void init() {
    getInit(token: user.token).then((value) {
      setState(() {
        isStart = value['is_start'];
        isEnd = value['is_end'];
        timeCallApi = value['is_time_call_api'];
      });
      if (isStart) {
        checkPermission();
      }
    });
  }

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  void checkPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _listenLocation();
  }

  void _listenLocation() {
    location.enableBackgroundMode();
    location.changeSettings(interval: timeCallApi * 1000);
    _locationSubscription = location.onLocationChanged.handleError((dynamic err) {
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((LocationData current) {
      // updateLocation(lat: current.latitude, lng: current.longitude, token: user.token);
    });
  }

  Future<void> _stopListen() async {
    await _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  void serviceDialog() {
    _stopListen();
    Navigator.popUntil(context, (route) => route.isFirst);
    showDialog(
        context: context,
        builder: (c) {
          return CupertinoAlertDialog(
            title: const Text('Vui lòng bật định vị'),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('Đóng', style: TextStyle(color: Colors.blue, fontSize: 15)))
            ],
          );
        });
  }

  void permissionDialog() {
    _stopListen();
    Navigator.popUntil(context, (route) => route.isFirst);
    showDialog(
        context: context,
        builder: (c) {
          return CupertinoAlertDialog(
            title: const Text('Vui lòng cấp quyền vị trí'),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('Đóng', style: TextStyle(color: Colors.blue, fontSize: 15)))
            ],
          );
        });
  }
}
