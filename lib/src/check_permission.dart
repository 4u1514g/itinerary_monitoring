import 'package:flutter/material.dart';
import 'package:itinerary_monitoring/src/employee/employee_screen.dart';
import 'package:itinerary_monitoring/helper/constant.dart';
import 'package:itinerary_monitoring/helper/location_service.dart';
import 'package:itinerary_monitoring/src/manager/manager_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckPermission extends StatefulWidget {
  const CheckPermission({super.key});

  @override
  State<CheckPermission> createState() => _CheckPermissionState();
}

class _CheckPermissionState extends State<CheckPermission> {
  final checkKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    print(serviceEnabled);
    print(permissionGranted);
    return Scaffold(
        key: checkKey,
        backgroundColor: white,
        appBar: AppBar(toolbarHeight: 0, elevation: 0, backgroundColor: white),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 15),
              setText('Cho phép ứng dụng truy cập vị trí và gửi thông báo đến bạn', 20,
                  fontWeight: FontWeight.w600),
              const SizedBox(height: 15),
              setText(
                  'Cho phép ứng dụng truy cập vị trí và gửi thông báo đến bạn để phục vụ việc đặt xe tốt hơn. Bạn hoàn toàn có thể thay đổi cấp quyền trong phần Cài đặt điện thoại bất cứ lúc nào.',
                  14,
                  color: gray),
              Expanded(child: Center(child: Image(image: i2Asset, height: 250))),
              GestureDetector(
                onTap: onChecking,
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: blue),
                  height: 50,
                  alignment: Alignment.center,
                  child: setText('Tiếp tục', 16, color: white, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: bottomPadding),
            ],
          ),
        ));
  }

  void onChecking() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceDialog(checkKey, false);
    } else {
      checkPermissionWhile(checkKey).then((value) {
        if (permissionGranted == PermissionStatus.granted) {
          if (user.dataUser!.isManager!) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const ManagerScreen()));
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const EmployeeScreen()));
          }
        }
      });
    }
  }
}
