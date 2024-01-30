import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'utils.dart';

/// The JSPaste client class. Create one to start interacting with the API!
class JSPasteClient {
  /// The API base url.
  ///
  /// Example: `https://jspaste.eu/api/v2/`
  String url = mainApiUrl; // ignore: non_constant_identifier_names

  /// Create a new JSPaste client.
  ///
  /// [url] is the API base url. Default is [mainApiUrl].
  JSPasteClient({String? url}) {
    if (url != null) this.url = url;
  }

  /// Publish a [Document] to the JSPaste API.
  ///
  /// The document must not be published already.
  /// Returns the published [Document] including the document key, secret and url.
  Future<Document> publishDocument(Document document) async {
    if (await document.isPublished) {
      throw Exception('Document is already published.');
    }

    final uri = joinUrl(mainApiUrl, 'documents');

    final response = await http.post(uri, body: document.text, headers: {
      'Secret': document.secret ?? '',
      'Password': document.password ?? '',
      'Lifetime': (document.expiresAt != null
              ? (document.expiresAt!.millisecondsSinceEpoch / 1000).toString()
              : null) ??
          '',
    });

    final responseBody = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final errorMessage = getErrorMessage(responseBody['errorCode']);
      throw Exception(errorMessage);
    }

    responseBody['text'] = document.text;

    Document newDocument = Document._fromJson(responseBody);

    return newDocument;
  }

  /// Get a [Document] from the JSPaste API.
  ///
  /// [key] is the document ID.
  /// [password] is the document password if the document is password protected.
  Future<Document> getDocument(String key, {String? password}) async {
    final uri = joinUrl(mainApiUrl, 'documents/$key');

    final response = await http.get(uri);

    final responseBody = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final errorMessage = getErrorMessage(responseBody['errorCode']);
      throw Exception(errorMessage);
    }

    responseBody['text'] = responseBody['text'];

    Document document = Document._fromJson(responseBody);

    return document;
  }

  /// Check if a document exists by [key] by pinging the API.
  Future<bool> documentExists(String key) async {
    final uri = joinUrl(mainApiUrl, 'documents/$key/exists');

    final response = await http.get(uri);

    if (response.body == 'false') return false;

    return true;
  }
}

/// A document in the JSPaste API.
///
/// You can publish a document with [JSPasteClient.publishDocument].
class Document {
  String _text;
  String? _key;
  DateTime? _expiresAt;
  String? _password;
  String? _secret;
  String? _url;

  Document(String text, {String? password, DateTime? expiresAt, String? secret}) : _text = text {
    if (password != null) _password = password;
    if (expiresAt != null) _expiresAt = expiresAt;
    if (secret != null) _secret = secret;
  }
  Document._fromJson(Map<String, dynamic> json)
      : _text = json['text'],
        _key = json['key'],
        _expiresAt = json['expirationTimestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['expirationTimestamp'])
            : null,
        _secret = json['secret'],
        _url = json['url'];

  /// Get the document ID.
  String? get key => _key;

  /// Check if the document is published. (Ping the API to check.)
  Future<bool> get isPublished async {
    if (_key == null) return false;

    final uri = joinUrl(mainApiUrl, 'documents/$_key/exists');

    final response = await http.get(uri);

    if (response.body == 'false') return false;

    return true;
  }

  /// The document expiration date.
  DateTime? get expiresAt => _expiresAt;

  /// Set the document expiration date.
  ///
  /// Throws an exception if the document is already published.
  void setExpiration(DateTime expiresAt) {
    if (_key != null) {
      throw Exception('Cannot set expiration date on published document.');
    }

    _expiresAt = expiresAt;
  }

  /// The document password.
  String? get password => _password;

  /// Set the document password.
  ///
  /// Throws an exception if the document is already published.
  void setPassword(String password) {
    if (_key != null) {
      throw Exception('Cannot set password on published document.');
    }

    if (password.length > 256) {
      throw Exception('Password cannot be longer than 256 characters.');
    }
    _password = password;
  }

  /// The document text.
  String get text => _text;

  /// Set the document text.
  ///
  /// Throws an exception if the document is already published.
  set text(String text) {
    if (_key != null) {
      throw Exception(
          'Cannot set text on published document. Use Document.update() instead.');
    }

    _text = text;
  }

  /// The document secret.
  ///
  /// Used to update or delete the document.
  String? get secret => _secret;

  /// Set the document secret.
  ///
  /// Throws an exception if the document is published with a set secret.
  /// Only used when already published if it is a document retrieved from the API.
  void setSecret(String secret) {
    if (_key != null && _secret != null) {
      throw Exception('Cannot set secret on published document.');
    }

    _secret = secret;
  }

  /// The document url.
  String? get url => _url;

  /// Update the document.
  ///
  /// Throws an exception if the document is not published or if no secret is set.
  Future<void> update(text) async {
    if (_secret == null) {
      throw Exception('Cannot update document without secret.');
    }

    if (await isPublished) {
      throw Exception('Cannot update unpublished document.');
    }

    final uri = joinUrl(mainApiUrl, 'documents/$_key');

    final response = await http.patch(uri, body: text, headers: {
      'Secret': _secret ?? '',
    });

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body);

      final errorMessage = getErrorMessage(responseBody['errorCode']);
      throw Exception(errorMessage);
    }

    _text = text;

    return;
  }

  /// Delete the document.
  ///
  /// Throws an exception if the document is not published or if no secret is set.
  Future<void> delete() async {
    if (_secret == null) {
      throw Exception('Cannot delete document without secret.');
    }

    if (!await isPublished) {
      throw Exception('Cannot delete unpublished document.');
    }

    final uri = joinUrl(mainApiUrl, 'documents/$_key');

    final response = await http.delete(uri, headers: {
      'Secret': _secret ?? '',
    });

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body);

      final errorMessage = getErrorMessage(responseBody['errorCode']);
      throw Exception(errorMessage);
    }

    _secret = null;
    _key = null;
    _url = null;

    return;
  }
}
