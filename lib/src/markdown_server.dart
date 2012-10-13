part of markdown_server;

/// Subclass of StaticServer, which converts the `.html` or `.htm` requests
/// into a `.md` request.  The `.md` file, if found, is converted using the
/// dartdoc's [markdownToHtml] converter.
class MarkdownServer extends StaticServer {

  /// [rootPath] contains the path to look for markdown files in.
  /// The [markdownExt] is the file extension to match on, and defaults to `md`
  MarkdownServer(final rootPath, [markdownExt = 'md'])
      : super(rootPath, markdownExt);

  /// Converts the [content] from markdown, and returns html
  String transformContent(final String content) {
    print("Converting content: from md to html");
    String result =  markdownToHtml(content);
    return """
<html><head><title>Converted from markdown</title>
  <body><!-- Converted from markdown, starts below-->
$result
  <!-- Conversion from markdown, end --></body> 
</html>""";
  }

  /// Returns the `text/html` content type
  String getContentType(path) {
    return "text/html";
  }

  /// Transforms a request for `.html` or `.htm` into `.md`
  String transformFileExtension(String path) {
    return path
        .replaceAll(".html", ".$_extensionFilter")
        .replaceAll(".htm", ".$_extensionFilter");
  }

}