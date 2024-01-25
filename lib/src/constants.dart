// TODO: add versioning
const String MainAPIURL = 'https://jspaste.eu/api/v2/'; // ignore: constant_identifier_names
enum JSPErrorCode {
  invalidInput('jsp.invalid_input', 'Invalid input. Maybe the ID is not alphanumeric?'),
  fileNotFound('jsp.file_not_found', 'File not found.'),
  invalidPassword('jsp.invalid_password', 'Invalid password.'),
  documentExpired('jsp.document_expired', 'Document expired.'),
  invalidFileLength('jsp.invalid_file_length', 'Invalid file length.'),
  invalidSecret('jsp.invalid_secret', 'Invalid secret.'),
  invalidSecretLength('jsp.invalid_secret_length', 'Invalid secret length.'),
  invalidPasswordLength('jsp.invalid_password_length', 'Invalid password length.'),;

  final String string;
  final String message;

  const JSPErrorCode(this.string, this.message);
}