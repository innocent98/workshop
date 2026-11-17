import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef FakeHandler = Future<ResponseBody> Function(RequestOptions options);

/// An [HttpClientAdapter] that never touches the network: every request is
/// answered by [handler] and recorded in [requests].
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.handler);

  FakeHandler handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

/// A [Dio] wired to a [FakeHttpAdapter]. Returns the adapter via [adapter].
Dio fakeDio(FakeHandler handler, {void Function(FakeHttpAdapter)? adapter}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.invalid/api/v1'));
  final fake = FakeHttpAdapter(handler);
  dio.httpClientAdapter = fake;
  adapter?.call(fake);
  return dio;
}

ResponseBody jsonResponse(Object body, {int status = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// Simulates the device being offline.
Future<ResponseBody> connectionError(RequestOptions options) {
  throw DioException.connectionError(
    requestOptions: options,
    reason: 'no network',
  );
}
