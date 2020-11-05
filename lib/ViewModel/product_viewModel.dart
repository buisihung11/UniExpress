import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uni_express/Bussiness/BussinessHandler.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/services/analytic_service.dart';
import 'package:uni_express/utils/shared_pref.dart';


import '../constraints.dart';
import 'base_model.dart';

Color minusColor = kBackgroundGrey[5];
Color addColor = kBackgroundGrey[5];

// TODO: 1. Tach cac attriute tu Product master
// TODO: 2. Thay doi extra state khi chon xong attribute
// TODO: 2.1 Viet ham changeAttribute

class ProductDetailViewModel extends BaseModel {
  int affectIndex = 0;
  //List product ảnh hưởng giá
  Map<String, List<String>> affectPriceContent;
  //List choice bắt buộc không ảnh hưởng giá
  Map<String, String> selectedAttributes;
  int count = 1;

  double total, fixTotal = 0, extraTotal = 0;
  bool order = false;
  //List choice option
  Map<ProductDTO, bool> extra;
  //Bật cờ để đổi radio thành checkbox
  bool isExtra;
  //List size
  ProductDTO master;

  ProductDetailViewModel(ProductDTO dto) {
    master = dto;
    isExtra = false;

    this.affectPriceContent = new Map<String, List<String>>();

    this.selectedAttributes = new Map<String, String>();
    //

    if (master.type == MASTER_PRODUCT) {
      for (int i = 0; i < master.attributes.keys.length; i++) {
        String attributeKey = master.attributes.keys.elementAt(i);
        List<String> listAttributesName =
            master.attributes[attributeKey].split(",");
        listAttributesName.forEach((element) {
          element.trim();
        });
        affectPriceContent[attributeKey] = listAttributesName;
        selectedAttributes[attributeKey] = null;
      }
    } else {
      fixTotal = BussinessHandler.countPrice(master.prices, count);
    }

    total = fixTotal + extraTotal;

    verifyOrder();
    notifyListeners();
  }

  Future<void> getExtra(ProductDTO product) async {
    this.extra = new Map<ProductDTO, bool>();
    for (ProductDTO dto in product.extras) {
      extra[dto] = false;
    }
    notifyListeners();

    // setState(ViewStatus.Loading);
    // try {
    //   StoreDTO store = await getStore();
    //   ProductDAO dao = new ProductDAO();
    //   List<ProductDTO> products = new List();
    //
    //   for (int id in cat_id) {
    //     products.addAll(await dao.getExtraProducts(id, sup_id, store.id));
    //   }
    //
    //   for (ProductDTO dto in products) {
    //     extra[dto] = false;
    //   }
    //   setState(ViewStatus.Completed);
    // } catch (e) {
    //   bool result = await showErrorDialog();
    //   if (result) {
    //     await getExtra(cat_id, sup_id);
    //   } else
    //     setState(ViewStatus.Error);
    // }
  }

  void addQuantity() {
    if (addColor == kPrimary) {
      if (count == 1) {
        minusColor = kPrimary;
      }
      count++;

      if (master.type == MASTER_PRODUCT) {
        Map choice = new Map();
        for (int i = 0; i < affectPriceContent.keys.toList().length; i++) {
          choice[affectPriceContent.keys.elementAt(i)] =
              selectedAttributes[affectPriceContent.keys.elementAt(i)];
        }

        ProductDTO dto = master.getChildByAttributes(choice);
        fixTotal = BussinessHandler.countPrice(dto.prices, count);
      } else {
        fixTotal = BussinessHandler.countPrice(master.prices, count);
      }

      if (this.extra != null) {
        extraTotal = 0;
        for (int i = 0; i < extra.keys.length; i++) {
          if (extra[extra.keys.elementAt(i)]) {
            double price = BussinessHandler.countPrice(
                extra.keys.elementAt(i).prices, count);
            extraTotal += price;
          }
        }
      }

      total = fixTotal + extraTotal;
      notifyListeners();
      // total = (extraTotal + fixTotal) * count;
      // notifyListeners();
    }
  }

  void minusQuantity() {
    if (count > 1) {
      count--;
      if (count == 1) {
        minusColor = kBackgroundGrey[5];
      }

      if (master.type == MASTER_PRODUCT) {
        Map choice = new Map();
        for (int i = 0; i < affectPriceContent.keys.toList().length; i++) {
          choice[affectPriceContent.keys.elementAt(i)] =
              selectedAttributes[affectPriceContent.keys.elementAt(i)];
        }

        ProductDTO dto = master.getChildByAttributes(choice);
        fixTotal = BussinessHandler.countPrice(dto.prices, count);
      } else {
        fixTotal = BussinessHandler.countPrice(master.prices, count);
      }

      if (this.extra != null) {
        extraTotal = 0;
        for (int i = 0; i < extra.keys.length; i++) {
          if (extra[extra.keys.elementAt(i)]) {
            double price = BussinessHandler.countPrice(
                extra.keys.elementAt(i).prices, count);
            extraTotal += price;
          }
        }
      }

      total = fixTotal + extraTotal;
      notifyListeners();
      // total = (extraTotal + fixTotal) * count;
      // notifyListeners();
    }
  }

  void changeAffectPriceAtrribute(String attributeValue) {
    Map choice = new Map();
    String attributeKey = affectPriceContent.keys.elementAt(affectIndex);

    selectedAttributes[attributeKey] = attributeValue;

    verifyOrder();

    if (order) {
      for (int i = 0; i < affectPriceContent.keys.toList().length; i++) {
        choice[affectPriceContent.keys.elementAt(i)] =
            selectedAttributes[affectPriceContent.keys.elementAt(i)];
      }

      if (master.type == MASTER_PRODUCT) {
        try {
          ProductDTO dto = master.getChildByAttributes(choice);
          print("dto: " + dto.toString());
          fixTotal = BussinessHandler.countPrice(dto.prices, count);
          extraTotal = 0;
          if (dto.hasExtra != null && dto.hasExtra) {
            print("add extra!");
            getExtra(dto);
          } else {
            this.extra = null;
          }
        } catch (e) {
          showStatusDialog("assets/images/global_error.png",
              "Sản phẩm không tồn tại", choice.toString());
          selectedAttributes[attributeKey] = null;
          verifyOrder();
        }
      }
      total = fixTotal + extraTotal;
    }

    notifyListeners();
  }

  void changeAffectIndex(int index) {
    this.affectIndex = index;
    if (index == affectPriceContent.keys.toList().length) {
      isExtra = true;
    } else
      isExtra = false;
    notifyListeners();
  }

  void verifyOrder() {
    order = true;

    for (int i = 0; i < affectPriceContent.keys.toList().length; i++) {
      if (selectedAttributes[affectPriceContent.keys.elementAt(i)] == null) {
        order = false;
      }
    }

    if (order) {
      addColor = kPrimary;
    }
    // setState(ViewStatus.Completed);
  }

  void changExtra(bool value, int i) {
    extraTotal = 0;
    extra[extra.keys.elementAt(i)] = value;
    for (int j = 0; j < extra.keys.toList().length; j++) {
      if (extra[extra.keys.elementAt(j)]) {
        double price =
            BussinessHandler.countPrice(extra.keys.elementAt(j).prices, count);
        extraTotal += price;
      }
    }
    total = fixTotal + extraTotal;
    notifyListeners();
  }

  Future<void> addProductToCart() async {
    showLoadingDialog();
    List<ProductDTO> listChoices = new List<ProductDTO>();
    if (master.type == MASTER_PRODUCT) {
      Map choice = new Map();
      for (int i = 0; i < affectPriceContent.keys.toList().length; i++) {
        choice[affectPriceContent.keys.elementAt(i)] =
            selectedAttributes[affectPriceContent.keys.elementAt(i)];
      }

      ProductDTO dto = master.getChildByAttributes(choice);
      listChoices.add(dto);
    }

    if (this.extra != null) {
      for (int i = 0; i < extra.keys.length; i++) {
        if (extra[extra.keys.elementAt(i)]) {
          listChoices.add(extra.keys.elementAt(i));
        }
      }
    }

    String description = "";

    CartItem item = new CartItem(master, listChoices, description, count);

    print("Save product: " + master.toString());
    await addItemToCart(item);
    await AnalyticsService.getInstance()
        .logChangeCart(item.master, item.quantity, true);
    hideDialog();
    await Get.back(result: true);
  }
}
