import 'constants.dart';

String getErrorMessage(String errorCode) {
  // find the JSPErrorCode by errorCode
  final error = JSPErrorCode.values.firstWhere(
    (element) => element.string == errorCode,
    orElse: () => JSPErrorCode.unknown,
  );

  // return the error message
  return error.message;
}

Uri joinUrl(String url, String url2) {
  // remove trailing slash from url
  if (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }

  // remove leading slash from url2
  if (url2.startsWith('/')) {
    url2 = url2.substring(1);
  }

  // return the joined url
  final joinedUrl = '$url/$url2';

  // check if the url is valid
  if (Uri.parse(joinedUrl).isAbsolute) {
    return Uri.parse(joinedUrl);
  } else {
    throw Exception('Invalid URL.');
  }
}
