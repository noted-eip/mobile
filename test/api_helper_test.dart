import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:noted_mobile/data/api_helper.dart';
import 'package:mockito/mockito.dart';

class DioAdapterMock extends Mock implements HttpClientAdapter {}

void main() {
  //test get request
  //test post request
  //test
  final Dio tdio = Dio();
  DioAdapterMock dioAdapterMock;
  APIHelper tapi;

  setUp(() {
    dioAdapterMock = DioAdapterMock();
    tdio.httpClientAdapter = dioAdapterMock;
    tapi = APIHelper.test(dio: tdio);
  });

  group('Get method', () {
    test('canbe used to get responses for any url', () async {
      tapi = APIHelper.test(dio: tdio);
      dioAdapterMock = DioAdapterMock();

      final responsepayload = jsonEncode({"response_code": "1000"});
      final httpResponse = ResponseBody.fromString(
        responsepayload,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

      when(dioAdapterMock.fetch(
              RequestOptions(path: 'https://noted-rojasdiego.koyeb.app'),
              any,
              any))
          .thenAnswer((_) async => httpResponse);

      final response = await tapi.get("/any url");
      final expected = {"response_code": "1000"};

      expect(response, equals(expected));
    });
  });

  group('Post Method', () {
    test('canbe used to get responses for any requests with body', () async {
      tapi = APIHelper.test(dio: tdio);
      dioAdapterMock = DioAdapterMock();

      final responsepayload = jsonEncode({"response_code": "1000"});
      final httpResponse =
          ResponseBody.fromString(responsepayload, 200, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      });

      when(dioAdapterMock.fetch(RequestOptions(path: ''), any, any))
          .thenAnswer((_) async => httpResponse);

      final response = await tapi.post("/any url", body: {"body": "body"});
      final expected = {"response_code": "1000"};

      expect(response, equals(expected));
    });
  });
}
