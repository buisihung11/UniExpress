import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as Get;
import 'package:uni_express/acessories/dialog.dart';
import '../route_constraint.dart';

class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String message]) : super(message, "Invalid Input: ");
}

class ExpiredException extends AppException {
  ExpiredException([String message]) : super(message, "Token Expired: ");
}

class CustomInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print(
        'REQUEST[${options.method}] => PATH: ${options.path} HEADER: ${options.headers.toString()}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions?.path}');
    print('DATA: ${response.data}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    return super.onError(err, handler);
  }
}
// or new Dio with a BaseOptions instance.

// or new Dio with a BaseOptions instance.

class MyRequest {
  static BaseOptions options = new BaseOptions(
      baseUrl: 'https://beanapi.unibean.net/api/',
      //baseUrl: 'http://13.212.101.182:8090/api/',
      headers: {
        Headers.contentTypeHeader: "application/json",
      },
      receiveTimeout: 5000);
  Dio _inner;
  MyRequest() {
    _inner = new Dio(options);
    _inner.interceptors.add(CustomInterceptors());
    _inner.interceptors.add(InterceptorsWrapper(
      onResponse: (e, handler) {
        return handler.next(e); // continue
      },
      onError: (e, handler) async {
        print(e.response.toString());
        if (e.response?.statusCode == 401) {
          await showStatusDialog("assets/images/global_error.png", "Lỗi",
              "Vui lòng đăng nhập lại");
          Get.Get.offAllNamed(RouteHandler.LOGIN);
        } else {
          throw e;
        }
      },
    ));
  }

  Dio get request {
    return _inner;
  }

  set setToken(token) {
    options.headers["Authorization"] = "Bearer $token";
  }
}

final requestObj = new MyRequest();
final request = requestObj.request;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
