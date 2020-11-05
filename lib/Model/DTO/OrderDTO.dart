
import 'package:uni_express/ViewModel/index.dart';

class OrderListDTO {
  final checkInDate;
  final List<OrderDTO> orders;

  OrderListDTO(this.checkInDate, this.orders);

  factory OrderListDTO.fromJSON(Map<String, dynamic> map) => OrderListDTO(
        map["check_in_date"],
        OrderDTO.fromList(map["list_of_orders"]),
      );

  static List<OrderListDTO> fromList(List list) =>
      list?.map((e) => OrderListDTO.fromJSON(e))?.toList();
}

class OrderDTO {
  final int id;
  final int itemQuantity;
  final String invoiceId;

  final double total;
  final double finalAmount;
  final OrderFilter status;
  final String orderTime;
  final List<OrderItemDTO> orderItems;
  // update
  final int paymentType;
  final List<OtherAmount> otherAmounts;

  OrderDTO(
    this.id, {
    this.otherAmounts,
    this.finalAmount,
    this.orderTime,
    this.total,
    this.itemQuantity,
    this.status,
    this.orderItems,
    this.paymentType,
    this.invoiceId = "INVOICE-ID-123",
  });

  factory OrderDTO.fromJSON(Map<String, dynamic> map) => OrderDTO(
        map["order_id"],
        total: map["total_amount"] ?? 0,
        invoiceId: map["invoice_id"],
        finalAmount: map["final_amount"],
        orderTime: map["check_in_date"],
        itemQuantity: map["master_product_quantity"],
        status: (map["delivery_status"]) == 0
            ? OrderFilter.ORDERING
            : OrderFilter.DONE,
        orderItems: map["list_order_details"] != null
            ? OrderItemDTO.fromList(map["list_order_details"])
            : null,
        otherAmounts: (map["other_amounts"] as List)
            ?.map((otherAmountJSON) => OtherAmount.fromJSON(otherAmountJSON))
            ?.toList(),
        paymentType: map["payment_type"][0] ?? 0,
      );

  static List<OrderDTO> fromList(List list) =>
      list?.map((e) => OrderDTO.fromJSON(e))?.toList();
}

class OrderItemDTO {
  final String masterProductName;
  final String masterProductId;
  final double amount;
  final int quantity;
  final List<OrderItemDTO> productChilds;

  OrderItemDTO({
    this.masterProductName,
    this.masterProductId,
    this.amount,
    this.productChilds,
    this.quantity,
  });

  factory OrderItemDTO.fromJSON(Map<String, dynamic> map) => OrderItemDTO(
        masterProductName: map["product_name"],
        quantity: map["quantity"],
        amount: map["final_amount"],
        productChilds: OrderItemDTO.fromList(map["list_of_childs"]),
      );

  static List<OrderItemDTO> fromList(List list) =>
      list?.map((e) => OrderItemDTO.fromJSON(e))?.toList() ?? [];
}

class OtherAmount {
  final String name;
  final String unit;
  final double amount;

  OtherAmount({this.name, this.unit, this.amount});
  factory OtherAmount.fromJSON(Map<String, dynamic> map) {
    return OtherAmount(
      name: map["name"],
      amount: map["amount"],
      unit: map["unit"],
    );
  }
}
