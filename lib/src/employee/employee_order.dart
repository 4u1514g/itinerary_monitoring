import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itinerary_monitoring/api/models/order_model.dart';
import 'package:itinerary_monitoring/helper/constant.dart';
import 'package:itinerary_monitoring/src/employee/order_detail.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class EmployeeOrder extends StatefulWidget {
  const EmployeeOrder(
      {super.key,
      required this.height,
      required this.date,
      this.onClear,
      this.changePolylines,
      this.active = true,
      required this.listOrder,
      required this.name,
      this.confirmOrder,
      this.isReality = false});

  final DateTime date;
  final double height;
  final Function()? onClear;
  final Function()? changePolylines;
  final bool active;
  final List<OrderModel> listOrder;
  final String name;
  final ValueChanged<int>? confirmOrder;
  final bool isReality;

  @override
  State<EmployeeOrder> createState() => _EmployeeOrderState();
}

class _EmployeeOrderState extends State<EmployeeOrder> {
  List<OrderModel> listOrder = [];
  PanelController controller = PanelController();

  @override
  void initState() {
    if (controller.isAttached) {
      controller.show();
    }
    setState(() {
      listOrder = widget.listOrder.reversed.toList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      isDraggable: widget.active,
      color: Colors.transparent,
      maxHeight: widget.height,
      controller: controller,
      panelBuilder: (sc) {
        return Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)), color: white),
          child: SingleChildScrollView(
            controller: sc,
            child: Column(
              children: [
                _info(),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 1,
                    color: const Color(0xffE8E8E8)),
                const SizedBox(height: 20),
                widget.listOrder.isEmpty
                    ? Column(
                        children: [
                          const SizedBox(height: 100),
                          Image(image: noResultAsset, width: 180),
                          const SizedBox(height: 20),
                          setText('Không tìm thấy đơn', 15, color: gray)
                        ],
                      )
                    : Column(
                        children: List.generate(widget.listOrder.length, (index) => _item(index))),
                if (widget.listOrder.isNotEmpty && user.dataUser!.isManager!)
                  GestureDetector(
                    onTap: widget.changePolylines,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      height: 45,
                      decoration:
                          BoxDecoration(color: orange, borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: setText(
                          widget.isReality ? 'Xem đường đi chỉ dẫn' : 'Xem đường đi thực tế', 16,
                          fontWeight: FontWeight.w600, color: white),
                    ),
                  ),
                SizedBox(height: bottomPadding),
              ],
            ),
          ),
        );
      },
    );
  }

  _info() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)), color: white),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Image(image: avatarAsset, height: 50),
                  ),
                  Positioned(
                      bottom: 0,
                      child: Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                            border: Border.all(color: white, width: 2),
                            color: green,
                            shape: BoxShape.circle),
                      ))
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  setText('Tài xế', 14, color: gray),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      setText(widget.name, 16, fontWeight: FontWeight.w600, color: blue),
                      const Spacer(),
                      setText(
                          widget.date.isToday
                              ? 'Hôm nay'
                              : DateFormat('dd/MM/yyyy').format(widget.date),
                          14,
                          color: gray)
                    ],
                  ),
                ],
              )),
            ],
          ),
        ),
        if (widget.onClear != null)
          Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                  onTap: widget.onClear, child: Image(image: clearAsset, height: 24)))
      ],
    );
  }

  _item(int index) {
    final item = listOrder[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showMaterialModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            builder: (context) => OrderDetail(
                height: widget.height,
                confirmOrder: () {
                  if (widget.confirmOrder != null) {
                    widget.confirmOrder!(listOrder.length - 1 - index);
                  }
                },
                id: item.id!));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: item.id == curOrder ? const Color(0xffFFF3E5) : white,
        child: Column(
          children: [
            const SizedBox(height: 3),
            Row(
              children: [
                index == listOrder.length - 1
                    ? Container(
                        width: 38,
                        alignment: Alignment.center,
                        child: const Icon(Icons.radio_button_checked, color: blue, size: 22))
                    : Container(
                        width: 38,
                        alignment: Alignment.center,
                        child: setText('${item.poinNumber}', 18,
                            fontWeight: FontWeight.w700, color: blue)),
                const SizedBox(width: 10),
                Expanded(
                    child: setText(item.namePoint ?? '', 18,
                        fontWeight: FontWeight.w600, color: black)),
                if (item.status == 1)
                  setText(DateFormat('HH:mm').format(item.timeFinished!), 14,
                      fontWeight: FontWeight.w600, color: green)
              ],
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                index == widget.listOrder.length - 1
                    ? const SizedBox(width: 38)
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 18),
                        height: 55,
                        width: 2,
                        color: blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      setText(item.strAddress ?? '', 12, color: gray),
                      const SizedBox(height: 3),
                      setText('Điểm dừng số ${item.poinNumber}', 12, color: gray),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: index == widget.listOrder.length - 1 ? 20 : 0)
          ],
        ),
      ),
    );
  }

  int get curOrder {
    if (widget.listOrder.every((element) => element.status == 1)) {
      return -1;
    }
    return widget.listOrder.firstWhere((element) => element.status == 0).id!;
  }
}
