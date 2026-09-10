import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../security/token_store.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Thin wrapper over [Dio] that centralizes base URL, `/api/v1` prefix,
/// timeouts, auth headers and error normalization (mobile/docs/architecture.md §5).
///
/// API data sources depend on this — screens never touch it, and never call
/// `http`/`Dio` directly (mobile/docs/coding_rules.md §6). Phase 0 wires the
/// client but no feature endpoint is called yet.
class ApiClient {
  ApiClient({required AppConfig config, required TokenStore tokenStore})
      : _dio = Dio(
          BaseOptions(
            baseUrl: config.apiRoot,
            connectTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
          ),
        ) {
    _dio.interceptors.addAll(<Interceptor>[
      AuthInterceptor(tokenStore),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  /// Test seam: inject a preconfigured [Dio] (e.g. with `MockAdapter`).
  ApiClient.withDio(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      path,
      queryParameters: query,
    );
    return _asJsonMap(response.data);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(path, data: body);
    return _asJsonMap(response.data);
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Object? body,
  }) async {
    final Response<dynamic> response = await _dio.patch<dynamic>(path, data: body);
    return _asJsonMap(response.data);
  }

  /// Multipart upload — one or more files plus scalar fields. Used by the
  /// identity-verification document / selfie endpoints (Slice 4).
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, MultipartFile> files,
    Map<String, dynamic> fields = const <String, dynamic>{},
  }) async {
    final FormData form = FormData.fromMap(<String, dynamic>{...fields, ...files});
    final Response<dynamic> response = await _dio.post<dynamic>(path, data: form);
    return _asJsonMap(response.data);
  }

  Map<String, dynamic> _asJsonMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{'data': data};
  }
}
