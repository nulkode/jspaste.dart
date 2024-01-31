import 'package:jspaste/jspaste.dart';

void main() async {
  // Create a new JSPaste client.
  final apiClient = JSPasteClient();

  // Get a document.
  try {
    final document =
        await apiClient.getDocument('document-key', password: 'password');
    print(document.text);

    // Update the document text.
    document.setSecret('aaaaa-bbbbb-ccccc-ddddd');
    await document.update('Hello, World! This is an edit.');
  } catch (e) {
    print(e);
  }
}
