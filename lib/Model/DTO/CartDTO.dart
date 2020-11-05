import 'package:logger/logger.dart';
import 'package:uni_express/Model/DTO/index.dart';


final logger = Logger(
    printer: PrettyPrinter(
  methodCount: 0,
  errorMethodCount: 5,
  lineLength: 50,
  colors: true,
  printEmojis: true,
  printTime: false,
));

class Cart {
  List<CartItem> items;
  // User info
  String orderNote;

  Cart.get({this.items, this.orderNote});

  int payment;

  Cart() {
    items = List();
  }

  factory Cart.fromJson(dynamic json) {
    List<CartItem> list = new List();
    if (json["items"] != null) {
      var itemJson = json["items"] as List;
      list = itemJson.map((e) => CartItem.fromJson(e)).toList();
    }
    return Cart.get(
      items: list,
      orderNote: json['orderNote'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    List listCartItem = items.map((e) => e.toJson()).toList();
    print("Items: " + listCartItem.toString());
    return {
      "items": listCartItem,
      "orderNote": orderNote,
    };
  }

  Map<String, dynamic> toJsonAPi() {
    List<Map<String, int>> payments = new List();
    payments.add({"type": payment});

    List<Map<String, dynamic>> listCartItem = new List();
    items.forEach((element) {
      listCartItem.add(element.toJsonApi());
    });

    Map<String, dynamic> map = {
      "payments": payments,
      "products_list": listCartItem,
      "note": orderNote,
    };
    logger.i("Order: " + map.toString());
    return map;
  }

  bool get isEmpty => items != null && items.isEmpty;
  int itemQuantity() {
    int quantity = 0;
    for (CartItem item in items) {
      quantity += item.quantity;
    }
    return quantity;
  }

  void addItem(CartItem item) {
    for (CartItem cart in items) {
      if (cart.findCartItem(item)) {
        cart.quantity += item.quantity;
        return;
      }
    }
    items.add(item);
  }

  void removeItem(CartItem item) {
    items.removeWhere((element) =>
        element.findCartItem(item) && element.quantity == item.quantity);
  }

  void updateQuantity(CartItem item) {
    for (CartItem cart in items) {
      if (cart.findCartItem(item)) {
        cart.quantity = item.quantity;
      }
    }
  }
}

class CartItem {
  ProductDTO master;
  List<ProductDTO> products;
  String description;
  int quantity;

  CartItem(this.master, this.products, this.description, this.quantity);

  bool findCartItem(CartItem item) {
    bool found = true;

    if (this.master.id != item.master.id ||
        this.master.type != item.master.type) {
      return false;
    }

    if (this.products.length != item.products.length) {
      return false;
    }
    for (int i = 0; i < this.products.length; i++) {
      if (item.products[i].id != this.products[i].id) found = false;
    }
    if (item.description != this.description) {
      found = false;
    }
    return found;
  }

  factory CartItem.fromJson(dynamic json) {
    List<ProductDTO> list = new List();
    if (json["products"] != null) {
      var itemJson = json["products"] as List;
      list = itemJson.map((e) => ProductDTO.fromJson(e)).toList();
    }
    return CartItem(
      ProductDTO.fromJson(json['master']),
      list,
      json['description'] as String,
      json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    List listProducts = products.map((e) => e.toJson()).toList();
    print("Products: " + listProducts.toString());
    return {
      "master": master.toJson(),
      "products": listProducts,
      "description": description,
      "quantity": quantity
    };
  }

  // TODO: Xem lai quantity cua tung CartItem
  Map<String, dynamic> toJsonApi() {
    // List<Map<String, dynamic>> map = new List();
    List productChilds = products
        .map((productChild) => {
              "product_id": productChild.id,
              "product_in_menu_id": productChild.productInMenuId,
              "quantity": quantity, // TODO: Kiem tra lon hon max va < min
            })
        .toList();

    return {
      "master_product": master.productInMenuId,
      "product_childs": productChilds,
      "description": description,
      "quantity": quantity
    };

    // if (master.type != ProductType.MASTER_PRODUCT) {
    //   map.add({
    //     "product_id": master.id,
    //     "quantity": quantity,
    //     "parent_id": master.catergoryId
    //   });
    // }

    // products.forEach((element) {
    //   map.add({
    //     "product_id": element.id,
    //     "quantity": quantity,
    //     "parent_id": element.catergoryId
    //   });
    // });
    // return map;
  }
}
