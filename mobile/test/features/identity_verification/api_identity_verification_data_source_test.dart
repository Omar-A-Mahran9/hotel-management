import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/core/errors/app_exception.dart';
import 'package:hotel_guest_app/core/network/api_client.dart';
import 'package:hotel_guest_app/core/network/interceptors/error_interceptor.dart';
import 'package:hotel_guest_app/features/identity_verification/data/datasources/api_identity_verification_data_source.dart';
import 'package:hotel_guest_app/features/identity_verification/domain/entities/identity_document.dart';
import 'package:hotel_guest_app/features/identity_verification/domain/entities/identity_verification_request.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.routes);

  final Map<String, (int, Map<String, dynamic>)> routes;
  final List<RequestOptions> received = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    received.add(options);
    final String key = '${options.method} ${options.path}';
    final (int, Map<String, dynamic>) entry =
        routes[key] ?? (404, <String, dynamic>{'success': false, 'message': 'no route $key'});
    return ResponseBody.fromString(
      jsonEncode(entry.$2),
      entry.$1,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiIdentityVerificationDataSource _source(_FakeAdapter adapter) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ErrorInterceptor());
  return ApiIdentityVerificationDataSource(ApiClient.withDio(dio));
}

void main() {
  test('fetchStatus parses the session', () async {
    final adapter = _FakeAdapter(<String, (int, Map<String, dynamic>)>{
      'GET /guest/reservations/9/identity': (200, <String, dynamic>{
        'success': true,
        'message': 'OK',
        'data': <String, dynamic>{
          'reservation_id': 9,
          'status': 'document_uploaded',
          'attempts': 1,
          'latest_outcome': null,
        },
      }),
    });

    final session = await _source(adapter).fetchStatus('9');
    expect(session.status.wireValue, 'document_uploaded');
    expect(session.attempts, 1);
  });

  test('submitDocument refuses when no real capture is wired (no filePath)', () async {
    final source = _source(_FakeAdapter(<String, (int, Map<String, dynamic>)>{}));

    expect(
      source.submitDocument(const SubmitIdentityDocumentRequest(
        reservationId: '9',
        type: IdentityDocumentType.passport,
        image: CapturedImage.dummy,
      )),
      throwsA(isA<NotImplementedInPhaseException>()),
    );
  });
}
