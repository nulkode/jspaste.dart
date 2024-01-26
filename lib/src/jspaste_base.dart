import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'utils.dart';

/// The JSPaste client class. Create one to start interacting with the API!
class JSPasteClient {
  String? _secret;

  /// The API base URL.
  ///
  /// Example: `https://jspaste.eu/api/v2/`
  String URL = MainAPIURL; // ignore: non_constant_identifier_names

  /// Create a new JSPaste client.
  ///
  /// [secret] is the secret key for the API.
  /// [url] is the API base URL. Default is [MainAPIURL].
  JSPasteClient({String? secret, String? url}) {
    if (secret != null) _secret = secret;
  }

  /// Get a [Document] by its [id].
  ///
  /// [password] is the password for the document. Default is `null`.
  Future<Document> getDocumentById(String id, {String? password}) async {
    final uri = Uri.parse(joinURL(URL, 'documents/$id'));

    final response = await http.get(uri, headers: {'Password': password ?? ''});
    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final key = responseBody['key'];
      final data = responseBody['data'];
      return Document(data, key);
    } else if ((response.statusCode == 400 ||
            response.statusCode == 401 ||
            response.statusCode ==
                404) && // TODO: waiting until backend is fixed
        responseBody.containsKey('errorCode')) {
      final errorMessage = getErrorMessage(responseBody['errorCode']);
      throw Exception(errorMessage);
    } else {
      throw Exception('Unknown error while getting document.');
    }
  }

  /// Create a new [Document] with [text].
  ///
  /// [password] is the password for the document. Default is `null`.
  /// [expiration] is the expiration time for the document in milliseconds. Default is no expiration.
  /// A secret key is required for this operation. You can set it with [setSecret]. If there is no secret key, one will be generated for you and set in the client.
  Future<Document> createDocument(String text,
      {String? password, int? expiration}) async {
    if (text == '') throw Exception('Text cannot be empty.');

    final uri = Uri.parse(joinURL(URL, 'documents'));
    final response = await http.post(uri,
        headers: {
          'Password': password ?? '',
          'Secret': _secret ?? '',
          'Expiration': expiration?.toString() ?? '',
          'Content-Type': 'application/octet-stream'
        },
        body: text);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final key = responseBody['key'];
      final secret = responseBody['secret'];
      if (_secret == null || _secret == '') _secret = secret;

      return Document(text, key);
    } else if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.body);
      final errorMessage = getErrorMessage(responseBody['errorCode']);

      throw Exception(errorMessage);
    } else {
      print(response.body);
      print(response.statusCode);
      throw Exception('Unknown error while creating document.');
    }
  }

  /// Update a [Document] with [text].
  ///
  /// [secret] must be the same as the one used to create the document. You can set it with [setSecret].
  Future<Document> updateDocument(String id, String text) async {
    if (text == '') throw Exception('Text cannot be empty.');
    if (_secret == null || _secret == '') {
      throw Exception('Secret key is required for this operation.');
    }

    final uri = Uri.parse(joinURL(URL, 'documents/$id'));
    final response = await http.patch(uri,
        headers: {
          'Secret': _secret!,
          'Content-Type': 'application/octet-stream'
        },
        body: text);
    if (response.statusCode == 200) {
      return Document(text, id);
    } else if (response.statusCode == 400 ||
        response.statusCode == 403 ||
        response.statusCode == 404) {
      final responseBody = jsonDecode(response.body);
      final errorMessage = getErrorMessage(responseBody['errorCode']);

      throw Exception(errorMessage);
    } else {
      throw Exception('Unknown error while updating document.');
    }
  }

  /// Delete a [Document] by its [id].
  ///
  /// [secret] must be the same as the one used to create the document. You can set it with [setSecret].
  Future<void> deleteDocument(String id) async {
    if (_secret == null || _secret == '') {
      throw Exception('Secret key is required for this operation.');
    }

    final uri = Uri.parse(joinURL(URL, 'documents/$id'));
    final response = await http.delete(uri, headers: {'Secret': _secret!});
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404 || response.statusCode == 403) {
      final responseBody = jsonDecode(response.body);
      final errorMessage = getErrorMessage(responseBody['errorCode']);

      throw Exception(errorMessage);
    } else {
      throw Exception('Unknown error while deleting document.');
    }
  }

  /// Set the [secret] key for the API.
  void setSecret(String secret) {
    _secret = secret;
  }
}

/// A document.
///
/// [text] is the document text. [id] is the document ID if it exists.
class Document {
  String text;
  String? id;

  Document(this.text, this.id);
}
