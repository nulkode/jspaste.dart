import 'package:jspaste/jspaste.dart';

void main() async {
  // Create a new JSPaste client.
  final apiClient = JSPasteClient();

  // Create a new document.
  Document document = Document('Hello, World!',
      password: 'password', expiresAt: DateTime.now().add(Duration(days: 1)));

  // Publish the document.
  document = await apiClient.publishDocument(document);

  // Print the document url.
  print(document.url);

  // Update the document text.
  await document.update('Hello, World! This is an edit.');

  // Get a document.
  try {
    final document =
        await apiClient.getDocument('document-key', password: 'password');
    print(document.text);

    // Update the document text.
    document.secret = 'aaaaa-bbbbb-ccccc-ddddd';
    await document.update('Hello, World! This is an edit.');
  } catch (e) {
    print(e);
  }

  // Unpublish the document.
  await document.unpublish();
}
