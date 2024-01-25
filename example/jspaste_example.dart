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
