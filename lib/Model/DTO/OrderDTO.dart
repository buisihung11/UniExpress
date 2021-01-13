import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/index.dart';

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
  final List<StoreDTO> stores;

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
      this.stores});

  factory OrderDTO.fromJSON(Map<String, dynamic> map) =>
      OrderDTO(map["order_id"],
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
          customer: map["customer"] != null
              ? CustomerInfoDTO.fromJSON(map["customer"])
              : null,
          stores: map["store_orders"] != null
          ? StoreDTO.fromList(map["store_orders"])
      : null,
        paymentType: map["payment_type"] != null ? map["payment_type"][0] : 0,
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
  final String supplier_store_name;

  OrderItemDTO({
    this.masterProductName,
    this.masterProductId,
    this.amount,
    this.productChilds,
    this.quantity,
    this.supplier_store_name
  });

  factory OrderItemDTO.fromJSON(Map<String, dynamic> map) => OrderItemDTO(
        masterProductName: map["product_name"],
        quantity: map["quantity"],
        amount: map["final_amount"]??map['unit_cost'],
        productChilds: OrderItemDTO.fromList(map["list_of_childs"]),
    supplier_store_name: map["supplier_store_name"]
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

class CustomerInfoDTO{
  int customer_id;
  String name;
  String phone;

  CustomerInfoDTO({this.customer_id, this.name, this.phone});

  factory CustomerInfoDTO.fromJSON(Map<String, dynamic> map) {
    return CustomerInfoDTO(
        customer_id: map["customer_id"],
        name: map["name"],
        phone: map["phone_number"]
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "customer_id" : customer_id,
      "name" : name,
      "phone_number": phone
    };
  }
}
