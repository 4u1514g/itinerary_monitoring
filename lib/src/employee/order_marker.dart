import 'package:flutter/material.dart';
import 'package:itinerary_monitoring/api/models/order_model.dart';
import 'package:itinerary_monitoring/helper/constant.dart';

class OrderMarker extends StatelessWidget {
  const OrderMarker({super.key, required this.listKey, required this.listOrder});

  final List<GlobalKey> listKey;
  final List<OrderModel> listOrder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: List.generate(listKey.length, (index) {
        return RepaintBoundary(
          key: listKey[index],
          child: listOrder[index].poinNumber == 1
              ? const Icon(Icons.radio_button_checked, color: blue, size: 26)
              : Stack(
                  children: [
                    Image(image: pinAsset, width: 26, color: color(listOrder[index])),
                    Positioned(
                        top: 4.88,
                        left: 4.88,
                        right: 4.88,
                        child: Container(
                            height: 16,
                            width: 16,
                            decoration: const BoxDecoration(color: white, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: setText('${listOrder[index].poinNumber}', 13,
                                fontWeight: FontWeight.w600,
                                height: 1,
                                color: color(listOrder[index]))))
                  ],
                ),
        );
      }),
    ));
  }

  Color color(OrderModel item) {
    if (item.id == curOrder) {
      return orange;
    } else if (item.status == 0) {
      return blue;
    }
    return green;
  }

  int get curOrder {
    if (listOrder.every((element) => element.status == 1)) {
      return -1;
    }
    return listOrder.firstWhere((element) => element.status == 0).id!;
  }
}
