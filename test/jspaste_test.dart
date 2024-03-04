import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:jspaste/jspaste.dart';

void main() {
  group('JSPasteClient tests', () {
    final JSPasteClient apiClient = JSPasteClient();

    test('publishDocument should publish a document successfully', () async {
      apiClient.http = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path.endsWith('/documents'), true);

        return http.Response(
            '{"key": "mock_key", "secret": "mock_secret", "url": "mock_url"}',
            200);
      });

      final document = Document('Mock Text');

      expect(await document.isPublished(), false);

      final publishedDocument = await apiClient.publishDocument(document);

      expect(publishedDocument.key, 'mock_key');
      expect(publishedDocument.secret, 'mock_secret');
      expect(publishedDocument.url, 'mock_url');
    });

    test('getDocument should get a document successfully', () async {
      apiClient.http = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path.endsWith('/documents/mock_key'), true);

        return http.Response(
            '{"key": "mock_key", "url": "mock_url", "data": "Mock Text"}', 200);
      });

      final document = await apiClient.getDocument('mock_key');

      expect(document.key, 'mock_key');
      expect(document.url, 'mock_url');
      expect(document.text, 'Mock Text');
    });

    test('documentExists should return true if the document exists', () async {
      apiClient.http = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path.endsWith('/documents/mock_key/exists'), true);

        return http.Response('true', 200);
      });

      expect(await apiClient.documentExists('mock_key'), true);
    });
  });

  group('Document tests', () {
    final JSPasteClient apiClient = JSPasteClient();
    late Document document;
    late Document publishedDocument;

    setUp(() async {
      // prepare a published document
      apiClient.http = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path.endsWith('/documents'), true);

        return http.Response(
            '{"key": "mock_key", "secret": "mock_secret", "url": "mock_url"}',
            200);
      });
      document = Document('Mock Text');
      publishedDocument = await apiClient.publishDocument(document);
    });

    test('Document should be not published and fields can be set', () async {
      expect(await document.isPublished(), false);
      expect(document.key, null);
      expect(document.secret, null);

      expect(() => document.expiresAt = DateTime.now().add(Duration(days: 1)),
          returnsNormally);
      expect(() => document.password = 'mock_password', returnsNormally);
      expect(() => document.text = 'Mock Text', returnsNormally);
      expect(document.text, 'Mock Text');
      expect(() => document.secret = 'mock_secret', returnsNormally);
    });

    test('Document should be published and fields cannot be set', () async {
      publishedDocument.http = MockClient((request) async {
        expect(request.method, 'GET');

        if (request.url.path.endsWith('/documents/mock_key')) {
          return http.Response(
              '{"key": "mock_key", "url": "mock_url", "data": "Mock Text"}',
              200);
        } else if (request.url.path.endsWith('/documents/mock_key/exists')) {
          return http.Response('true', 200);
        } else {
          throw Exception('Unexpected path: ${request.url.path}');
        }
      });

      expect(await publishedDocument.isPublished(), true);
      expect(publishedDocument.key, 'mock_key');
      expect(publishedDocument.secret, 'mock_secret');

      expect(() => publishedDocument.expiresAt = DateTime.now(),
          throwsA(isA<Exception>()));
      expect(() => publishedDocument.password = 'mock_password',
          throwsA(isA<Exception>()));
      expect(() => publishedDocument.text = 'Mock Text',
          throwsA(isA<Exception>()));
      expect(publishedDocument.text, 'Mock Text');
      expect(() => publishedDocument.secret = 'mock_secret',
          throwsA(isA<Exception>()));
    });

    test('Document update on unpublished document', () {
      expect(() async => await document.update('Mock Text'),
          throwsA(isA<Exception>()));
    });

    test('Document update on published document', () async {
      publishedDocument.http = MockClient((request) async {
        if (request.url.path.endsWith('/documents/mock_key/exists')) {
          return http.Response('true', 200);
        }

        expect(request.method, 'PATCH');
        expect(request.url.path.endsWith('/documents/mock_key'), true);

        return http.Response('{"edited": true}', 200);
      });

      // WARNING: Tried to wrap the update function in a expect, however, after that the text
      // is not updated in the next expect statement with the text comparison. I don't know why
      // this happens as in the document.delete test it works fine and the vales that must be
      // null, are null even if the delete function is wrapped in a expect statement and is async.
      await publishedDocument.update('Updated Mock Text');
      expect(publishedDocument.text, 'Updated Mock Text');
    });

    test('Document delete on unpublished document', () {
      expect(() async => await document.unpublish(), throwsA(isA<Exception>()));
    });

    test('Document delete on published document', () async {
      publishedDocument.http = MockClient((request) async {
        if (request.url.path.endsWith('/documents/mock_key/exists')) {
          return http.Response('true', 200);
        }

        expect(request.method, 'DELETE');
        expect(request.url.path.endsWith('/documents/mock_key'), true);

        return http.Response('{"deleted": true}', 200);
      });

      expect(() async => await publishedDocument.unpublish(), returnsNormally);
      expect(document.key, null);
      expect(document.secret, null);
      expect(document.url, null);
    });
  });
}
