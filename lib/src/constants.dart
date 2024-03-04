const String mainApiUrl = 'https://jspaste.eu/api/v2/';

enum JSPErrorCode {
  unknown('jsp.unknown', 'An unknown error occurred.'),
  notFound('jsp.not_found', 'The requested resource was not found.'),
  validationFailed('jsp.validation_failed', 'The validation failed.'),
  internalServerError(
      'jsp.internal_server_error', 'An internal server error occurred.'),
  parseInvalid('jsp.parse_failed', 'Failed to parse the request.'),
  inputInvalid('jsp.input.invalid', 'The input is invalid.'),
  documentNotFound('jsp.document.not_found', 'The document was not found.'),
  documentPasswordNeeded(
      'jsp.document.needs_password', 'The document needs a password.'),
  documentInvalidPasswordLength('jsp.document.invalid_password_length',
      'The password length is invalid.'),
  documentInvalidPassword(
      'jsp.document.invalid_password', 'The password is invalid.'),
  documentInvalidLength('jsp.document.invalid_length',
      'The document length is invalid. Maybe it is too long?'),
  documentInvalidSecret(
      'jsp.document.invalid_secret', 'The secret is invalid.'),
  documentInvalidSecretLength(
      'jsp.document.invalid_secret_length', 'The secret length is invalid.'),
  documentInvalidKeyLength('jsp.document.invalid_key_length', 'The key length is invalid.'),
  documentKeyAlreadyExists('jsp.document.key_already_exists', 'The key already exists.');

  final String string;
  final String message;

  const JSPErrorCode(this.string, this.message);
}
