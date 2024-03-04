import 'package:http/http.dart' show Client;
import 'dart:convert';
import 'constants.dart';
import 'utils.dart';
import 'package:meta/meta.dart';

/// The JSPaste client class. Create one to start interacting with the API!
class JSPasteClient {
  /// The API base url.
  ///
  /// Example: `https://jspaste.eu/api/v2/`
  String url = mainApiUrl;

  /// Create a new JSPaste client.
  ///
  /// [url] is the API base url. Default is [mainApiUrl].
  JSPasteClient({String? url}) {
    if (url != null) this.url = url;
  }

  /// HTTP client used to make requests to the API.
  ///
  /// Used for testing purposes only.
  @visibleForTesting
  Client http = Client();

  /// Publish a [Document] to the JSPaste API.
  ///
  /// The document must not be published already.
  ///
  /// [keyLength] is the length of the generated key if a custom key is not set.
  ///
  /// Uses [Document.isPublished] to check if the document is published.
  ///
  /// Returns the published [Document] including the document key, secret and url.
  Future<Document> publishDocument(Document document, {int? keyLength}) async {
    if (await document.isPublished()) {
      throw Exception('Document is already published.');
    }

    final uri = joinUrl(mainApiUrl, 'documents');

    Map<String, String> headers = {};

    if (document.password != null) {
      headers['password'] = document.password!;
    }

    if (document.expiresAt != null) {
      headers['lifetime'] =
          document.expiresAt!.difference(DateTime.now()).inSeconds.toString();
    } else {
      headers['lifetime'] = '0';
    }

    if (document.secret != null) {
      headers['secret'] = document.secret!;
    }

    if (document.key != null) {
      headers['key'] = document.key!;
    } else if (keyLength != null) {
      if (keyLength < 2 || keyLength > 32) {
        throw Exception(
            'The key length must be between 2 and 32 characters long.');
      }

      headers['key-length'] = keyLength.toString();
    }

    final response =
        await http.post(uri, body: document.text, headers: headers);

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
  ///
  /// [password] is the document password if the document is password protected.
  Future<Document> getDocument(String key, {String? password}) async {
    final uri = joinUrl(mainApiUrl, 'documents/$key');

    Map<String, String> headers = {};

    if (password is String) {
      headers['password'] = password;
    }

    final response = await http.get(uri, headers: headers);

    final responseBody = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final errorMessage = getErrorMessage(responseBody['errorCode']);
      throw Exception(errorMessage);
    }

    responseBody['text'] = responseBody['data'];

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
  bool _published = false;

  // TODO: offline mode

  /// HTTP client used to make requests to the API.
  ///
  /// Used for testing purposes only.
  @visibleForTesting
  Client http = Client();

  Document(String text, {String? password, DateTime? expiresAt, String? secret})
      : _text = text {
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
        _url = json['url'],
        _published = true;

  /// Get the document ID.
  String? get key => _key;

  /// Set a custom key for an unpublished document.
  set key(String? key) {
    if (_key != null) {
      throw Exception('Cannot set custom key on published document.');
    }

    if (key == null) {
      _key = key;
      return;
    }

    if (key.length < 2 || key.length > 32) {
      throw Exception(
          'The key length must be between 2 and 32 characters long.');
    }

    if (!isAlphaNumeric(key)) {
      throw Exception('The key must be alphanumeric.');
    }

    _key = key;
  }

  /// Check if the document is published.
  ///
  /// By default, before connecting to the API, it performs some checks, such as checking whether
  /// the expiration date of the document has already passed. If you want to omit this checks, set
  /// [forceOnlineCheck] to true.
  ///
  /// If you don't want to connect to the API, set [offlineMode] to true.
  ///
  /// By default, if the document is not published (as it has expired or the API has answered that
  /// it doesn't), then the document will nullify some fields such as [Document.secret] or
  /// [Document.url] if they aren't null yet. If you want to preserve this data, set [nullify] to false.
  Future<bool> isPublished(
      {bool offlineMode = false,
      bool forceOnlineCheck = false,
      nullify = true}) async {
    if (!forceOnlineCheck && (!_published || _key == null)) {
      _setUnpublished(nullify: nullify);
      return false;
    }

    if (!forceOnlineCheck &&
        (_expiresAt != null && _expiresAt!.isBefore(DateTime.now()))) {
      if (nullify) _setUnpublished();
      return false;
    }

    if (offlineMode) return true;

    final uri = joinUrl(mainApiUrl, 'documents/$key/exists');

    final response = await http.get(uri);

    if (response.body == 'true') return true;

    return false;
  }

  /// The document expiration date.
  ///
  /// Returns null if the document does not expire.
  DateTime? get expiresAt => _expiresAt;

  /// Set the document expiration date.
  ///
  /// Set to null if the document should not expire.
  ///
  /// Throws an exception if the document is already published.
  set expiresAt(DateTime? expiresAt) {
    if (_published) {
      throw Exception('Cannot set expiration date on published document.');
    }

    if (expiresAt == null) {
      _expiresAt = null;
      return;
    }

    if (expiresAt.isBefore(DateTime.now())) {
      throw Exception('Expiration date cannot be in the past.');
    }

    _expiresAt = expiresAt;
  }

  /// The document password.
  String? get password => _password;

  /// Set the document password.
  ///
  /// Throws an exception if the document is already published.
  set password(String? password) {
    if (_published) {
      throw Exception('Cannot set password on published document.');
    }

    if (password == null) {
      _password = null;
      return;
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
  ///
  /// If you want to update a published document, use [Document.update] instead.
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
  ///
  /// Only used when already published if it is a document retrieved from the API.
  set secret(String? secret) {
    if (_published) {
      throw Exception('Cannot set secret on published document.');
    }

    if (secret == null) {
      _secret == null;
      return;
    }

    if (secret.isEmpty || secret.length > 255) {
      throw Exception(
          'The key length must be between 2 and 255 characters long.');
    }

    _secret = secret;
  }

  /// The document url.
  String? get url => _url; // TODO: generate the url dynamically

  /// Update the document.
  ///
  /// Uses [isPublished] to check if the document is published. The argument [nullify] is passed to this function.
  ///
  /// Throws an exception if the document is not published or if no secret is set.
  Future<void> update(String text, {bool nullify = true}) async {
    if (_secret == null) {
      throw Exception('Cannot update document without secret.');
    }

    if (!await isPublished(nullify: nullify)) {
      throw Exception('Cannot update unpublished document.');
    }

    final uri = joinUrl(mainApiUrl, 'documents/$_key');

    final response = await http.patch(uri, body: text, headers: {
      'Secret': _secret!,
    });

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body);

      final errorMessage = getErrorMessage(responseBody['errorCode']);
      throw Exception(errorMessage);
    }

    _text = text;

    return;
  }

  /// Unpublish the document.
  ///
  /// Uses [isPublished] to check if the document is published. The argument [nullify] is passed to this
  /// function.
  ///
  /// The function will nullify some fields such as [Document.secret] or [Document.url] if they aren't
  /// null yet. [nullify] set to true will also prevent this.
  ///
  /// Throws an exception if the document is not published or if no secret is set.
  Future<void> unpublish({bool nullify = false}) async {
    if (_secret == null) {
      throw Exception('Cannot delete document without secret.');
    }

    if (!await isPublished(nullify: nullify)) {
      throw Exception('Cannot delete unpublished document.');
    }

    final uri = joinUrl(mainApiUrl, 'documents/$_key');

    final response = await http.delete(uri, headers: {
      'Secret': _secret!,
    });

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body);

      final errorMessage = getErrorMessage(responseBody['errorCode']);
      throw Exception(errorMessage);
    }

    _setUnpublished(nullify: nullify);

    return;
  }

  void _setUnpublished({bool nullify = true}) {
    _published = false;
    if (nullify) {
      _secret = null;
      _url = null;
    }
  }
}
