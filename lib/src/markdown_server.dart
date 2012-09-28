// part of markdown_server;

/// Exte
class MarkdownServer extends StaticServer {
  MarkdownServer(final root) : super(root, "md");
  
  String _processContent(final String content) {
    print("Converting content from md to html");
    return markdownToHtml(content);
  }
  
  String _getContentType(path) {
    return "text/html";
  }
  
  String _modifyFileExtension(String path) {
    final oldPath = path;
    path = path.replaceAll(".html", ".md").replaceAll(".htm", ".md");
    print("Converting: $oldPath > $path");
    return path;
  }
}