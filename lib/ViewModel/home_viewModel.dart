import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uni_express/Model/DAO/StoreDAO.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/StoreDTO.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/services/analytic_service.dart';
import 'package:uni_express/utils/shared_pref.dart';


import '../constraints.dart';
import '../route_constraint.dart';

class Filter {
  final int id;
  final String name;
  bool isSelected;
  bool isMultiple;

  Filter(this.id, this.name,
      {this.isSelected = false, this.isMultiple = false});
}

class HomeViewModel extends BaseModel {
  static HomeViewModel _instance;

  ProductDAO _dao = ProductDAO();
  dynamic error;
  List<ProductDTO> products;
  List<ProductDTO> _cachedProduct;
  bool _isFirstFetch = true;
  List<Filter> filterType = [
    Filter(47, 'Tất cả', isSelected: true),
    Filter(48, 'Gần đây'),
    Filter(49, 'Mới'),
  ];

  bool get isFirstFetch => _isFirstFetch;

  set isFirstFetch(bool value) {
    _isFirstFetch = value;
  }

  List<Filter> filterCategories = [
    Filter(44, 'Cơm', isMultiple: true),
    Filter(45, 'Món nước', isMultiple: true),
    Filter(46, 'Thức uống', isMultiple: true),
  ];

  HomeViewModel() {
    setState(ViewStatus.Loading);
    // getProducts();
  }

  Future<void> openProductDetail(ProductDTO product) async {
    await AnalyticsService.getInstance().logViewItem(product);
    bool result =
        await Get.toNamed(RouteHandler.PRODUCT_DETAIL, arguments: product);
    hideSnackbar();
    if (result != null) {
      if (result) {
        Get.rawSnackbar(
            message: "Thêm món thành công",
            duration: Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.only(left: 8, right: 8, bottom: 32),
            backgroundColor: kPrimary,
            borderRadius: 8);
      }
    }
    notifyListeners();
  }

  Future<void> openCart(RootViewModel rootViewModel) async {
    hideSnackbar();
    bool result = await Get.toNamed(RouteHandler.ORDER);
    if (result != null) {
      if (result) {
        notifyListeners();
        await showStatusDialog("assets/images/global_sucsess.png", "Thành công",
            "Đơn hàng của bạn sẽ được giao vào lúc $TIME");

        await rootViewModel.fetchUser();
      }
    }

  }

  Future<Cart> get cart async {
    return await getCart();
  }

  static HomeViewModel getInstance() {
    if (_instance == null) {
      _instance = HomeViewModel();
    }
    return _instance;
  }

  static void destroyInstance() {
    _instance = null;
  }

  // 1. Get ProductList with current Filter
  Future<List<ProductDTO>> getProducts() async {
    try {
      setState(ViewStatus.Loading);
      StoreDTO store = await getStore();
      //StoreDTO store = StoreDTO();
      if (store == null) {
        StoreDAO storeDAO = new StoreDAO();
        List<StoreDTO> listStore = await storeDAO.getStores();
        for (StoreDTO dto in listStore) {
          if (dto.id == UNIBEAN_STORE) {
            store = dto;
            await setStore(dto);
          }
        }
      }
      print("Get products...");
      if (_isFirstFetch) {
        products = await _dao.getProducts(store?.id);
        _cachedProduct = products.sublist(0);
        // products.insertAll(0, products);
        _isFirstFetch = false;
      } else {
        // change filter

        // 1. Filter by type (All,New,History)
        // 2. Filter by Categories
        products = _cachedProduct.where((prod) {
          if (filterCategories.every((category) => !category.isSelected))
            return true;
          bool isInFilter = filterCategories.any((category) =>
              prod.catergoryId == category.id && category.isSelected);
          return isInFilter;
        }).toList();
        // do something with products
        print("Fetch prodyuct with filter");
        // products = products.sublist(2)..shuffle();
        // products = products.sublist(0)..shuffle();
      }
      await Future.delayed(Duration(microseconds: 1000));
      // check truong hop product tra ve rong (do khong co menu nao trong TG do)
      if (products.isEmpty || products == null) {
        setState(ViewStatus.Empty);
      } else {
        setState(ViewStatus.Completed);
      }
    } catch (e, stacktrace) {
      print("Excception: " + e.toString() + stacktrace.toString());
      bool result = await showErrorDialog();
      if (result) {
        await getProducts();
      } else
        setState(ViewStatus.Error);
    } finally {
      // notifyListeners();
    }

    return products;
  }

  // 2. Change filter

  Future<void> updateFilter(int filterId, bool isMultiple) async {
    if (isMultiple)
      await updateFilterCategories(filterId);
    else
      await updateFilterType(filterId);
    // Update Product List
    await getProducts();
  }

  Future<void> updateFilterType(int filterId) async {
    filterType = filterType.map((filter) {
      if (filter.id == filterId) {
        filter.isSelected = true;
      } else {
        filter.isSelected = false;
      }
      return filter;
    }).toList();
    notifyListeners();
  }

  Future<void> updateFilterCategories(int filterId) async {
    filterCategories = filterCategories.map((filter) {
      if (filter.id == filterId) {
        filter.isSelected = !filter.isSelected;
      }
      return filter;
    }).toList();
    notifyListeners();
  }
}
