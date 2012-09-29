// part of markdown_server;

/// A simple static file server which is capable of serving text and binary
/// files.
///
/// When matching (with the [matcher] method,
/// the overridable [transformFileExtension] method allows
/// you to provide a
/// translation from the requested file extension to the physical file extension
/// such as converting .html into .md.  In the default, [StaticServer]
/// implementation, there is no conversion performed.
///
/// When handling (with the [handler] method,
/// text files get passed through the [transformContent] method,
/// which can be overridden to convert from one content type to another.
/// In the default [StaticServer] implementation, this performs no conversion.
///
/// This implementation uses the sync file access functions, and is not
/// intended for use in a production environment.  It's primary use case is to
/// aid local editing of markdown.
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
  /// not be passed through the [transformContent] method.  Instead, they will
  /// be simply piped to the http response output stream
  /// - [textTypes] is a [MimeTypes] object containing a list of file types
  /// containing string types.  These are read as strings, and passed through
  /// the [transformContent] method.
  StaticServer(final String rootPath,
      [this._extensionFilter=null,
       this._binaryTypes = null,
       this._textTypes = null]) : _root=new Path.fromNative(rootPath) {
     // Set the default mime types if not provided
    if (_binaryTypes == null) _binaryTypes = new MimeTypes.binary();
    if (_textTypes == null) _textTypes = new MimeTypes.text();
  }

  /// Matcher function for use with [HttpServer] found in the [dart:io] package
  /// This implementation takes the [HttpRequest.path], and pass
  /// it through the [transformFileExtension] function, and then check to
  /// see if the file exists on disk.  This uses the sync() version of the
  /// exists function for simplicity - this is not intended to be used in a
  /// production environment.
  ///
  /// If there is no [_extensionFilter] (passed in the constructor,
  /// or the [_extensionFilter] contains the transformed path's extension,
  /// then the matcher will check on disk.
  ///
  /// For example, if the constructor is passed `md` and the transformed
  /// path's extension is `jpg` then the matcher will automatically return
  /// false. If the constructor is passed `null`, the matcher will check on
  /// disk for the files existance.
  bool matcher(final HttpRequest req) {
    final path = _getFullPath(req.path);
    if (_extensionFilter == null || path.extension.contains(_extensionFilter)){
      final file = new File.fromPath(path);
      return file.existsSync();
    }

    return false;
  }

  /// The [handler] function for use with [HttpServer] class found in the
  /// dart:io package.  It loads the file from disk.  If the file is a
  /// binary MimeType file, then it is simply piped into the response.
  /// Otherwise, the file is loaded as a string, and passed into the
  /// [transformContent] function, which, in this implementation, has no
  /// effect.
  void handler(final HttpRequest req, final HttpResponse res) {
    final path = _getFullPath(req.path);
    final file = new File.fromPath(path);

    /// Add some simple http headers
    res.headers.add(HttpHeaders.CONTENT_TYPE, getContentType(path));
    res.headers.add(HttpHeaders.CONTENT_ENCODING, "UTF-8");

    if (_binaryTypes.contains(path.extension)) {
      // if it is binary, then just pipe the file to the response output
      file.openInputStream().pipe(res.outputStream, true);
    }
    else {
      // otherwise, read as text and optionally convert content
      var content = file.readAsTextSync();
      content = transformContent(content);
      res.outputStream.writeString(content);
      res.outputStream.close();
    }




  }

  /// Provided to enable overriding in subclasses.  For example, the
  /// [MarkdownServer] subclass transforms the input [content] from
  /// markdown, and returns html.
  ///
  /// This implementation simply returns the [content]
  String transformContent(String content) {
    // do nothing in this implementation, provided to allow overriding
    return content;
  }

  /// Provided to enable overriding in subclasses.  For example, the
  /// [MarkdownServer] subclass converts the [path] requested (such as
  /// /index.html into /index.md.
  ///
  /// This implementation simply returns the input [path]
  String transformFileExtension(String path) {
    // do nothing in this implementation, provided to allow overriding
    return path;
  }

  /// Provided to enable overriding in subclasses.  This default implementation
  /// uses the file extension to determine the mime type.
  String getContentType(Path path) {
    if (_binaryTypes.contains(path.extension)) {
      return _binaryTypes[path.extension];
    }
    else {
      return _textTypes[path.extension];
    }
  }

  /// Trims the leading slash from a request path [reqPath] - converting
  /// `/index.html` into `index.html`
  String _trimLeadingSlash(String reqPath) {
    if (reqPath.startsWith("/")) {
      reqPath = reqPath.substring(1, reqPath.length);
    }
    return reqPath;
  }

  /// Returns the full path of a file from the requested path and the [rootPath]
  /// passed into the constructor.  Also calls [transformFileExtension] so that
  /// subclasses can modify the filename looked for on disk.
  Path _getFullPath(String reqPath) {
    reqPath = _trimLeadingSlash(reqPath);
    reqPath = transformFileExtension(reqPath);
    var path = new Path.fromNative(reqPath);
    return _root.join(path);
  }
}