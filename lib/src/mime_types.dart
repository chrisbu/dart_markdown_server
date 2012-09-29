// part of markdown_server

/// Provided to setup some default mime types.
/// This can be subclassed as required to add your own custom mime types
/// and passed into the StaticServer constructor
class MimeTypes {
  final _mimeTypes = new Map<String,String>();
  final String _defaultIfNotFound;

  String operator [](String key) {
    var result = _mimeTypes[key.toLowerCase()];
    return result == null ? _defaultIfNotFound : result;
  }

  MimeTypes.binary([this._defaultIfNotFound = ""]) {
    _mimeTypes["jpg"] = "image/jpg";
    _mimeTypes["png"] = "image/png";
    _mimeTypes["gif"] = "image/gif";
    _mimeTypes["ico"] = "image/ico";
  }

  MimeTypes.text([this._defaultIfNotFound = "text/plain"]) {
    _mimeTypes["html"] = "text/html";
    _mimeTypes["htm"] = "text/html";
    _mimeTypes["txt"] = "text/text";
    _mimeTypes["dart"] = "application/dart";

    // ref: http://stackoverflow.com/questions/4101394/javascript-mime-type
    // rather than application/javaScript and application/xml
    _mimeTypes["js"] = "text/javascript";
    _mimeTypes["xml"] = "text/xml";
  }

  // Returns true if [extension] matches one of the mime types.
  bool contains(String extension) {
    return _mimeTypes.containsKey(extension.toLowerCase());
  }


}
