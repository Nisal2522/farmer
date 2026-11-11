import 'package:get/get.dart';

import '../../core/config/app_config.dart';
import '../../services/auth_service.dart';

/// Shared HTTP client for the real backend. Adds the auth token to every
/// request and turns non-2xx responses into [ApiException]s.
class ApiClient extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = AppConfig.apiBaseUrl;
    httpClient.timeout = AppConfig.requestTimeout;
    httpClient.addRequestModifier<dynamic>((request) {
      final token = Get.find<AuthService>().token;
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      return request;
    });
    super.onInit();
  }

  Future<T> getJson<T>(String path, T Function(dynamic json) parse, {Map<String, dynamic>? query}) async {
    final res = await get<dynamic>(path, query: query);
    return parse(_unwrap(res));
  }

  Future<T> postJson<T>(String path, Object? body, T Function(dynamic json) parse) async {
    final res = await post<dynamic>(path, body);
    return parse(_unwrap(res));
  }

  dynamic _unwrap(Response<dynamic> res) {
    if (res.isOk) return res.body;
    throw ApiException(res.statusCode, res.statusText ?? 'Network error');
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int? statusCode;
  final String message;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
