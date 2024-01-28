// TODO: add versioning
const String MainAPIURL = // ignore: constant_identifier_names
    'https://jspaste.eu/api/v2/';

enum JSPErrorCode {
  inputInvalid('jsp.input.invalid', 'The input is invalid.'),
  documentNotFound('jsp.document.not_found', 'The document was not found.'),
  documentPasswordNeeded(
      'jsp.document.needs_password', 'The document needs a password.'),
  documentInvalidPasswordLength('jsp.document.invalid_password_length',
      'The password length is invalid.'),
  documentInvalidPassword('jsp.document.invalid_password',
      'The password is invalid.'),
  documentInvalidLength(
      'jsp.document.invalid_length', 'The document length is invalid. Maybe it is too long?'),
  documentInvalidSecret('jsp.document.invalid_secret',
      'The secret is invalid.'),
  documentInvalidSecretLength('jsp.document.invalid_secret_length',
      'The secret length is invalid.');
  
  

  final String string;
  final String message;

  const JSPErrorCode(this.string, this.message);
}
