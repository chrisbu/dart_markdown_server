// part of markdown_server;

class StaticServer {
  final Path _root;
  final String _extensionFilter;
  
  StaticServer(final String root, [this._extensionFilter=null]) :
    _root=new Path.fromNative(root);

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
    print("Serving: ${req.path}");
    final path = _getFullPath(req.path);
    final file = new File.fromPath(path);
    var content = file.readAsTextSync();
    content = _processContent(content);
    
    print("Content type: ${_getContentType(path)}");
    res.headers.add(HttpHeaders.CONTENT_TYPE, _getContentType(path));
    res.outputStream.writeString(content);
    res.outputStream.close();
  }

  String _processContent(String content) {
    // do nothing in this implementation, provided to allow overriding
    return content;
  }
  
  String _modifyFileExtension(String path) {
    // do nothing in this implementation, provided to allow overriding
    return path;
  }
  
  String _getContentType(path) {
    return "text/${path.extension}";
  }
  
  String _trimLeadingSlash(String reqPath) {
    if (reqPath.startsWith("/")) {
      reqPath = reqPath.substring(1, reqPath.length);
    }
    return reqPath;
  }
  
  Path _getFullPath(String reqPath) {
    reqPath = _trimLeadingSlash(reqPath);
    reqPath = _modifyFileExtension(reqPath);
    var path = new Path.fromNative(reqPath);
    return _root.join(path);
  }
}