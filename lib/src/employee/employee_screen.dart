import 'dart:async';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:itinerary_monitoring/api/api_utils.dart';
import 'package:itinerary_monitoring/api/models/order_model.dart';
import 'package:itinerary_monitoring/itinerary_monitoring.dart';
import 'package:itinerary_monitoring/src/employee/order_marker.dart';
import 'package:itinerary_monitoring/helper/constant.dart';
import 'package:itinerary_monitoring/src/employee/employee_order.dart';
import 'package:itinerary_monitoring/helper/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> with WidgetsBindingObserver {
  final employeeKey = GlobalKey();
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  DateTime date = DateTime.now();
  static const CameraPosition kLocation =
      CameraPosition(target: LatLng(21.0227784, 105.8163641), zoom: 14.4746);
  List<GlobalKey> orderKey = [];
  Set<Marker> orderMarkers = <Marker>{};
  List<OrderModel> listOrder = [];
  Set<Polyline> polylines = {};
  bool load = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkPermissionAlways(employeeKey);
    });
    init();
    super.initState();
  }

  void init() async {
    getInit(token: user.token).then((value) {
      if (mounted) {
        setState(() {
          isStart = value['is_start'];
          isEnd = value['is_end'];
          timeCallApi = value['is_time_call_api'];
          load = false;
          listenLocation();
        });
      }
    });
    getMyOrderToday(token: user.token).then((value) async {
      if (mounted) {
        setState(() {
          listOrder.addAll(value);
          orderKey.addAll(List.generate(value.length, (index) => GlobalKey()));
        });
        if (value.isNotEmpty) {
          getOrder();
        }
      }
    });
    location.getLocation().then((value) async {
      if (mounted) {
        var current = LatLng(value.latitude!, value.longitude!);
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(CameraUpdate.newLatLng(current));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double paddingTop = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      key: employeeKey,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark),
      ),
      body: Stack(
        children: [
          if (orderKey.isNotEmpty) OrderMarker(listKey: orderKey, listOrder: listOrder),
          Container(color: Colors.white, height: double.infinity, width: double.infinity),
          GoogleMap(
              initialCameraPosition: kLocation,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              compassEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              polylines: polylines,
              markers: orderMarkers),
          Positioned(top: paddingTop + 10, left: kPadding, right: kPadding, child: _action()),
          load ? const SizedBox() : Positioned(bottom: 130, left: 0, right: 0, child: _start()),
          load
              ? const SizedBox()
              : AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  top: paddingTop + 80,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height - 80 - paddingTop,
                  child: EmployeeOrder(
                      key: UniqueKey(),
                      height: MediaQuery.of(context).size.height - 80 - paddingTop,
                      date: date,
                      active: isStart,
                      listOrder: listOrder,
                      confirmOrder: confirmOrder,
                      name: '${user.dataUser!.firstName!} ${user.dataUser!.lastName!}')),
        ],
      ),
    );
  }

  _action() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 45,
            width: 45,
            decoration: const BoxDecoration(color: white, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => logOut(),
          child: Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(color: white, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.power_settings_new, size: 26),
          ),
        ),
      ],
    );
  }

  _start() {
    if (isStart) return const SizedBox();
    return Container(
        height: 104,
        width: 104,
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: blue, width: 2.5),
            shape: BoxShape.circle),
        padding: const EdgeInsets.all(5),
        child: GestureDetector(
          onTap: onStart,
          child: Container(
            height: 94,
            width: 94,
            decoration: const BoxDecoration(color: orange, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: setText('Bắt đầu', 16, fontWeight: FontWeight.w700, color: white),
          ),
        ));
  }

  void getOrder() async {
    final GoogleMapController controller = await _controller.future;
    await controller
        .animateCamera(CameraUpdate.newLatLng(LatLng(listOrder.first.lat!, listOrder.first.lng!)));
    for (var element in listOrder) {
      if (element.overviewPolyline != null && element.status == 0) {
        polylines.add(Polyline(
            polylineId: PolylineId('${element.id}'),
            color: blue,
            width: 3,
            points:
                element.overviewPolyline!.map((e) => LatLng(e.latitude, e.longitude)).toList()));
      }
    }
    Future.delayed(const Duration(milliseconds: 500), () async {
      await Future.wait(List.generate(listOrder.length, (i) async {
        Marker m = await generateOrderMarker(i);
        orderMarkers.add(m);
      })).whenComplete(() {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  Future<Marker> generateOrderMarker(int index) async {
    final RenderRepaintBoundary boundary =
        orderKey[index].currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    return Marker(
        zIndex: 1000.0 - index,
        markerId: MarkerId(index.toString()),
        icon: BitmapDescriptor.bytes(pngBytes),
        position: LatLng(listOrder[index].lat!, listOrder[index].lng!),
        onTap: () {});
  }

  void onStart() {
    startSession(token: user.token).then((value) {
      setState(() {
        isStart = true;
      });
    });
  }

  int get curOrder {
    return listOrder.firstWhere((element) => element.status == 0).id!;
  }

  void confirmOrder(int index) async {
    showLoaderDialog(context);
    await updateOrder(id: listOrder[index].id, token: user.token).then((value) {
      print(value);
      cancelLoaderDialog(context);
      Navigator.pop(context);
      getMyOrderToday(token: user.token).then((value) async {
        if (mounted) {
          setState(() {
            listOrder.clear();
            orderKey.clear();
            listOrder.addAll(value);
            orderKey.addAll(List.generate(value.length, (index) => GlobalKey()));
          });
          if (value.isNotEmpty) {
            getOrder();
          }
        }
      });
    }).onError((error, stackTrace) {
      cancelLoaderDialog(context);
      if (error is DioException) {
        showDialog(
            context: context,
            builder: (c) {
              return CupertinoAlertDialog(
                title: Text(error.response!.data),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Đóng', style: TextStyle(color: Colors.blue, fontSize: 15)))
                ],
              );
            });
      }
    });
  }

  void logOut() {
    showDialog(
        context: context,
        builder: (c) {
          return CupertinoAlertDialog(
            title: const Text('Bạn chắc chắn muốn đăng xuất'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    stopListen();
                    SharedPreferences.getInstance().then((pref) => pref.remove('account'));
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) => const SignIn()), (route) => route.isFirst);
                  },
                  child:
                      const Text('Đăng xuất', style: TextStyle(color: Colors.blue, fontSize: 15))),
              TextButton(
                  onPressed: () {
                    Navigator.pop(c);
                  },
                  child: const Text('Đóng', style: TextStyle(color: Colors.red, fontSize: 15)))
            ],
          );
        });
  }
}
