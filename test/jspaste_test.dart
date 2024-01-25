import 'package:test/test.dart';
import 'package:jspaste/jspaste.dart'; // Replace with actual import path

void main() {
  group('JSPasteClient tests', () {
    late JSPasteClient jspasteClient;

    setUp(() {
      jspasteClient = JSPasteClient();
    });

    test('getDocumentById should throw Exception for non-existent document',
        () async {
      await expectLater(
        () => jspasteClient.getDocumentById('nonexistent-idajsdhkahdkjahs', null),
        throwsA(isA<Exception>()),
      );
    });

    test('createDocument should throw Exception for empty text', () async {
      expect(
        () => jspasteClient.createDocument('', null),
        throwsA(isA<Exception>()),
      );
    });

    test('createDocument should return Document for valid input', () async {
      final document = await jspasteClient.createDocument('Sample text', null);
      expect(document, isA<Document>());
      expect(document.text, 'Sample text');
      expect(document.id, isNotNull);
    });

    test('updateDocument should throw Exception for empty text', () async {
      expect(
        () => jspasteClient.updateDocument('valid-id', ''),
        throwsA(isA<Exception>()),
      );
    });

    test('updateDocument should throw Exception without secret', () async {
      expect(
        () => jspasteClient.updateDocument('valid-id', 'Updated text'),
        throwsA(isA<Exception>()),
      );
    });

    test('deleteDocument should throw Exception without secret', () async {
      expect(
        () => jspasteClient.deleteDocument('valid-id'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Document tests', () {
    test('Document constructor should initialize text and id', () {
      final document = Document('Sample text', 'document-id');
      expect(document.text, 'Sample text');
      expect(document.id, 'document-id');
    });
  });
}
