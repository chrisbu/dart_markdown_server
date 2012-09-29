// part of markdown_server;

/// A simple static file server which is capable of serving text and binary
/// files.
///
/// When matching (with the [matcher] method,
/// the overridable [modifyFileExtension] method allows
/// you to provide a
/// translation from the requested file extension to the physical file extension
/// such as converting .html into .md.  In the default, [StaticServer]
/// implementation, there is no conversion performed.
///
/// When handling (with the [handler] method,
/// text files get passed through the [processContent] method,
/// which can be overridden to convert from one content type to another.
/// In the default [StaticServer] implementation, this performs no conversion.
///
class StaticServer {
  final Path _root;
  final String _extensionFilter;
  MimeTypes _binaryTypes;
  MimeTypes _textTypes;

  /// Constructor, which requires the [rootPath] to serve files from
  ///
  /// Optional parameters
  ///
  /// - [extensionFilter] is the modified path to match.  The base
  /// [StaticServer] implementation matches all files
  /// - [binaryTypes] is a [MimeTypes] object containing a list of file
  /// extensions and the appropriate mime type string. If not provided, the
  /// default list is used.  Any file with the file extension in this list will
  /// not be passed through the [processContent] method.  Instead, they will
  /// be simply piped to the http response output stream
  /// - [textTypes] is a [MimeTypes] object containing a list of file types
  /// containing string types.  These are read as strings, and passed through
  /// the [processContent] method.
  StaticServer(final String rootPath,
      [this._extensionFilter=null,
       this._binaryTypes = null,
       this._textTypes = null]) : _root=new Path.fromNative(rootPath) {
    if (_binaryTypes == null) _binaryTypes = new MimeTypes.binary();
    if (_textTypes == null) _textTypes = new MimeTypes.text();
  }

  // match any file
  bool matcher(final HttpRequest req) {
    final path = _getFullPath(req.path);
    if (_extensionFilter == null || path.extension.contains(_extensionFilter)){
      final file = new File.fromPath(path);
      return file.existsSync();
    }

    return false;
  }

  void handler(final HttpRequest req, final HttpResponse res) {
    final path = _getFullPath(req.path);
    final file = new File.fromPath(path);

    res.headers.add(HttpHeaders.CONTENT_TYPE, getContentType(path));
    res.headers.add(HttpHeaders.CONTENT_ENCODING, "UTF-8");

    if (_binaryTypes.contains(path.extension)) {
      // if it is binary, then just pipe the file to the response output
      file.openInputStream().pipe(res.outputStream, true);
    }
    else {
      // otherwise, read as text and optionally convert content
      var content = file.readAsTextSync();
      content = processContent(content);
      res.outputStream.writeString(content);
      res.outputStream.close();
    }




  }

  String processContent(String content) {
    // do nothing in this implementation, provided to allow overriding
    return content;
  }

  String modifyFileExtension(String path) {
    // do nothing in this implementation, provided to allow overriding
    return path;
  }

  String getContentType(Path path) {
    if (_binaryTypes.contains(path.extension)) {
      return _binaryTypes[path.extension];
    }
    else {
      return _textTypes[path.extension];
    }
  }

  String _trimLeadingSlash(String reqPath) {
    if (reqPath.startsWith("/")) {
      reqPath = reqPath.substring(1, reqPath.length);
    }
    return reqPath;
  }

  Path _getFullPath(String reqPath) {
    reqPath = _trimLeadingSlash(reqPath);
    reqPath = modifyFileExtension(reqPath);
    var path = new Path.fromNative(reqPath);
    return _root.join(path);
  }
}