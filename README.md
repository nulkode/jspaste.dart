<img src="https://github.com/nulkode/jspaste.dart/assets/48804489/0fda9d97-acc2-4727-b952-ff2c6939daa6" alt="jspaste.dart banner" width="80%"/>

[![Pub Version](https://img.shields.io/pub/v/jspaste)](https://pub.dev/packages/jspaste)
[![Dart Version](https://img.shields.io/badge/dart-%3E%3D3.1.4-blue)](https://dart.dev)
[![License](https://img.shields.io/github/license/nulkode/jspaste.dart)](https://opensource.org/license/mit/)

This is a Dart library for interacting with the JSPaste API. It provides a simple way to create, retrieve, update, and delete documents on JSPaste.

## Installation

Add `jspaste` to your `pubspec.yaml` file:

```yaml
dependencies:
  jspaste: ^0.0.1
```

Then run `dart pub get`.

## Usage

Here is a simple example of how to use the library:

```dart
import 'package:jspaste/jspaste.dart';

void main() async {
  // Create a new JSPaste client instance
  JSPasteClient client = JSPasteClient(secret: 'your_secret_key_here');

  try {
    // Create a new document
    Document createdDocument = await client.createDocument(
        'Hello, this is a test document!', 'document_password');
    print('Document created with ID: ${createdDocument.id}');

    // Get the document by its ID
    Document retrievedDocument =
        await client.getDocumentById(createdDocument.id!, 'document_password');
    print('Retrieved document: ${retrievedDocument.text}');

    // Update the document
    await client.updateDocument(
        createdDocument.id!, 'Updated content for the document.');
    print('Document updated successfully.');

    // Delete the document
    await client.deleteDocument(createdDocument.id!);
    print('Document deleted successfully.');
  } catch (e) {
    print('Error: $e');
  }
}
```

You can find more examples in the [example](example/jspaste_example.dart) directory.

## Testing

To run the tests, use the following command:

```sh
dart test
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
