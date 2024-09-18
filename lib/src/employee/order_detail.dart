import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itinerary_monitoring/api/api_utils.dart';
import 'package:itinerary_monitoring/api/models/order_detail_model.dart';
import 'package:itinerary_monitoring/helper/constant.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({
    super.key,
    required this.height,
    required this.id,
    this.confirmOrder,
  });

  final double height;
  final int id;
  final Function()? confirmOrder;

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  bool load = true;
  late OrderDetailModel order;

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() {
    getOrderDetail(id: widget.id, token: user.token).then((value) {
      if (mounted) {
        setState(() {
          order = value;
          load = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: widget.height,
        decoration: const BoxDecoration(
            color: white, borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
        child: load
            ? const Center(child: CupertinoActivityIndicator())
            : Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            setText('Điểm dừng số ${order.poinNumber}', 14,
                                fontWeight: FontWeight.w600, color: gray),
                            const Spacer(),
                            GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Image(image: clearAsset, height: 24))
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image(image: pinAsset, height: 28),
                            const SizedBox(width: 15),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: setText(order.namePoint ?? '', 18,
                                            fontWeight: FontWeight.w600, color: black)),
                                    order.timeFinished == null
                                        ? const SizedBox()
                                        : setText(
                                            DateFormat('HH:mm').format(order.timeFinished!), 14,
                                            fontWeight: FontWeight.w600, color: green)
                                  ],
                                ),
                                const SizedBox(height: 2),
                                setText(order.strAddress ?? '', 12, color: gray),

                              ],
                            ))
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Image(image: customerAsset, height: 24),
                            const SizedBox(width: 15),
                            setText(order.customerName ?? '', 16, color: black),
                            const Spacer(),
                            Image(image: phoneAsset, height: 24),
                            const SizedBox(width: 15),
                            setText(order.customerPhone ?? '', 16, color: black),
                          ],
                        ),
                        const SizedBox(height: 20),
                        setText('Nghiệp vụ', 14, color: blue, fontWeight: FontWeight.w700),
                        const SizedBox(height: 15),
                        Container(
                          decoration:
                              BoxDecoration(border: Border.all(color: const Color(0xff777777))),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                      height: 36,
                                      width: 110,
                                      alignment: Alignment.center,
                                      child: setText('Tổng số lượng', 12, color: black)),
                                  Container(height: 36, width: 1, color: const Color(0xff777777)),
                                  Expanded(
                                      child: Center(
                                          child: setText('${order.totalQuantity} SP', 12,
                                              color: black)))
                                ],
                              ),
                              Container(height: 1, color: const Color(0xff777777)),
                              Row(
                                children: [
                                  Container(
                                      height: 36,
                                      width: 110,
                                      alignment: Alignment.center,
                                      child: setText('Tổng thanh toán', 12, color: black)),
                                  Container(height: 36, width: 1, color: const Color(0xff777777)),
                                  Expanded(
                                      child: Center(
                                          child: setText(
                                              '${formatMoney(order.totalMoney!)} VNĐ', 12,
                                              color: black)))
                                ],
                              ),
                              Container(height: 1, color: const Color(0xff777777)),
                              Row(
                                children: [
                                  Container(
                                      height: 36,
                                      width: 110,
                                      alignment: Alignment.center,
                                      child: setText('Trạng thái', 12, color: black)),
                                  Container(height: 36, width: 1, color: const Color(0xff777777)),
                                  Expanded(
                                      child: Center(child: setText('Chờ giao', 12, color: purple)))
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: Container(height: 0.5, color: gray.withOpacity(0.5))),
                            setText('  Danh sách chi tiết  ', 12, color: gray),
                            Expanded(child: Container(height: 0.5, color: gray.withOpacity(0.5)))
                          ],
                        ),
                        const SizedBox(height: 15),
                        ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) => _item(index),
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemCount: order.details!.length)
                      ],
                    ),
                  )),
                  if (order.status == 0 && order.employeeId == user.dataUser!.id)
                    GestureDetector(
                      onTap: widget.confirmOrder,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        height: 45,
                        decoration:
                            BoxDecoration(color: orange, borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: setText('Xác nhận giao hàng', 16,
                            fontWeight: FontWeight.w600, color: white),
                      ),
                    )
                ],
              ),
      ),
    );
  }

  _item(int index) {
    final Detail item = order.details![index];
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25), offset: const Offset(0, 3), blurRadius: 4)
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        CachedNetworkImage(
          imageUrl:
              'https://scontent.fhan15-1.fna.fbcdn.net/v/t39.30808-6/457253000_927577462453943_5420400558096620779_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=aa7b47&_nc_ohc=CzZ9Pf-og9kQ7kNvgE6BWxv&_nc_ht=scontent.fhan15-1.fna&oh=00_AYAG211Pt4q-g5k8ck6D1T1e9NSlWL6wJuTJUCABqmyVIg&oe=66D71B91',
          height: 80,
          width: 80,
          errorWidget: (context, url, error) => const Icon(Icons.error),
          placeholder: (context, url) => const CupertinoActivityIndicator(),
        ),
        const SizedBox(width: 15),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            setText(item.productName ?? '', 14, color: black, fontWeight: FontWeight.bold),
            const SizedBox(height: 2),
            setText('Số lượng: ${item.quantity} ${item.unit}', 12, color: gray),
            const SizedBox(height: 2),
            setText('Số lượng giao: ${item.deliveryQuantity} ${item.unit}', 12, color: gray),
            const SizedBox(height: 2),
            setText('Số lượng đã giao: ${item.deliveredQuantity} ${item.unit}', 12, color: gray),
            const SizedBox(height: 2),
            setText('Số lượng thực giao: ${item.actualQuantity} ${item.unit}', 12, color: gray),
            const SizedBox(height: 2),
            setText('Tổng thanh toán: ${formatMoney(item.total!)} VNĐ', 12, color: gray),
          ],
        ))
      ]),
    );
  }
}
