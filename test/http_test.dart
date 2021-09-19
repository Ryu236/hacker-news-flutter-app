// The test class for http using Mockito.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class Item {
  dynamic data;

  Item.fromJson(this.data);
}

Future<Item> fetchItem(http.Client client) async {
  final response = await client
      .get(Uri.parse('https://api.hnpwa.com/v0/item/21812041.json'));

  if (response.statusCode == 200) {
    return Item.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

class MockClient extends Mock implements http.Client {}

main() {
  group('fetchNewsItems', () {
    test('return a Item if the http call completes successfully', () async {
      final client = MockClient();

      when(client.get(Uri.parse('https://api.hnpwa.com/v0/item/21812041.json')))
          .thenAnswer((_) async => http.Response(
              '{"title": "What\'s new in Java 12, 13 and 14"}', 200));

      // ignore: deprecated_member_use
      expect(await fetchItem(client), const TypeMatcher<Item>());
    });

    test('throwns an exception if the http call completes with an error', () {
      final client = MockClient();

      when(client.get(Uri.parse('https://api.hnpwa.com/v0/item/21812041.json')))
          .thenAnswer((_) async => http.Response('Not Found', 400));

      expect(fetchItem(client), throwsException);
    });
  });
}
