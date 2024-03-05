## 0.2.0

- Support for custom key or custom key length.
- More documentation.
- Removed useless functions.
- Bug fixes.

BREAKING CHANGES:
- `isPublished` is now a function.
- `setSecret` is no longer a function. `secret` is now setted as a normal property.
- `Document.isPasswordProtected` no longer exists. ([e149a0a](https://github.com/nulkode/jspaste.dart/commit/e149a0add5ff4969e2abb9184aeaf68414887e2e))

## 0.1.1

- Fixed a bug where documents without expiration date would expire.

## 0.1.0

- Complete rewrite of the package.
- Changed 'delete' to 'unpublish'.
- Changed 'id' to 'key' in the API.
- Added support for document URL.
- Updated to the latest version of the JSPaste API.
- Added more examples.
- More bug fixes.

## 0.0.3

- Updated to the latest version of the JSPaste API.
- Bug fixes.

## 0.0.2

- Added support for document expiration.

## 0.0.1

- Initial version.
