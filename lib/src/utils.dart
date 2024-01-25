import 'constants.dart';

String getErrorMessage(JSPErrorCode errorCode) {
  // check if the error code is in the enum
  if (JSPErrorCode.values.contains(errorCode)) {
    // return the error message
    return errorCode.message;
  } else {
    // return the error message for unknown error
    return 'Unknown error.';
  }
}

String joinURL(String url, String url2) {
  // remove trailing slash from url
  if (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }

  // remove leading slash from url2
  if (url2.startsWith('/')) {
    url2 = url2.substring(1);
  }

  // return the joined url
  final joinedURL = '$url/$url2';

  // check if the url is valid
  if (Uri.parse(joinedURL).isAbsolute) {
    return joinedURL;
  } else {
    throw Exception('Invalid URL.');
  }
}