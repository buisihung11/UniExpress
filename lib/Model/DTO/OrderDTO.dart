import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/constraints.dart';

class OrderListDTO {
  final checkInDate;
  List<OrderDTO> orders;

  OrderListDTO({this.checkInDate, this.orders});

  factory OrderListDTO.fromJSON(Map<String, dynamic> map) => OrderListDTO(
        checkInDate: map["check_in_date"],
        orders: OrderDTO.fromList(map["list_of_orders"]),
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
  final CustomerInfoDTO customer;
  final List<SupplierNoteDTO> notes;
  LocationDTO location;
  bool isCompleted;
  List<int> packageIds;

  OrderDTO(this.id,
      {this.otherAmounts,
      this.finalAmount,
      this.orderTime,
      this.total,
      this.itemQuantity,
      this.status,
      this.orderItems,
      this.paymentType,
      this.invoiceId,
      this.customer,
      this.isCompleted = false,
      this.notes,
      this.location,
      this.packageIds});

  factory OrderDTO.fromJSON(Map<String, dynamic> map) =>
      OrderDTO(map["order_id"],
          total: map["total_amount"] ?? 0,
          invoiceId: map["invoice_id"],
          finalAmount: map["final_amount"],
          orderTime: map["check_in_date"],
          itemQuantity: map["master_product_quantity"],
          status: (map["order_status"]) == ORDER_NEW_STATUS
              ? OrderFilter.ORDERING
              : OrderFilter.DONE,
          orderItems: map["list_order_details"] != null
              ? OrderItemDTO.fromList(map["list_order_details"])
              : null,
          otherAmounts: (map["other_amounts"] as List)
              ?.map((otherAmountJSON) => OtherAmount.fromJSON(otherAmountJSON))
              ?.toList(),
          customer: map["customer"] != null
              ? CustomerInfoDTO.fromJSON(map["customer"])
              : null,
          paymentType: map["payment_type"],
          notes: (map["supplier_notes"] as List)
              ?.map((e) => SupplierNoteDTO.fromJson(e))
              ?.toList(),
          location: map['location'] != null ? LocationDTO.fromJson(map['location']) : null,
          packageIds: (map['package_ids'] as List)?.cast<int>());

  static List<OrderDTO> fromList(List list) =>
      list?.map((e) => OrderDTO.fromJSON(e))?.toList();
}

class OrderItemDTO {
  final String masterProductName;
  final String masterProductId;
  final double amount;
  final int quantity;
  final List<OrderItemDTO> productChilds;
  final String supplierStoreName;
  final int supplierStoreId;
  final int supplierId;
  final int type;

  OrderItemDTO(
      {this.masterProductName,
      this.masterProductId,
      this.amount,
      this.productChilds,
      this.quantity,
      this.supplierStoreName,
      this.supplierStoreId,
      this.supplierId,
      this.type});

  factory OrderItemDTO.fromJSON(Map<String, dynamic> map) => OrderItemDTO(
      masterProductName: map["product_name"],
      quantity: map["quantity"],
      amount: map["final_amount"] ?? map['final_cost'],
      productChilds: OrderItemDTO.fromList(map["list_of_childs"]),
      supplierStoreName: map["supplier_store_name"],
      type: map['product_type']);

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

class CustomerInfoDTO {
  int customer_id;
  String name;
  String phone;

  CustomerInfoDTO({this.customer_id, this.name, this.phone});

  factory CustomerInfoDTO.fromJSON(Map<String, dynamic> map) {
    return CustomerInfoDTO(
        customer_id: map["customer_id"],
        name: map["name"],
        phone: map["phone_number"]);
  }

  Map<String, dynamic> toJson() {
    return {"customer_id": customer_id, "name": name, "phone_number": phone};
  }
}
