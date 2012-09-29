// part of markdown_server;

/// Exte
class MarkdownServer extends StaticServer {
  MarkdownServer(final rootPath) : super(rootPath, "md");

  String processContent(final String content) {
    print("Converting content: from md to html");
    String result =  markdownToHtml(content);
    return """
<html><head><title>Converted from markdown</title>
  <body><!-- Converted from markdown, starts below-->
$result
  <!-- Conversion from markdown, end --></body> 
</html>""";
  }

  String getContentType(path) {
    return "text/html";
  }

  String modifyFileExtension(String path) {
    return path
        .replaceAll(".html", ".$_extensionFilter")
        .replaceAll(".htm", ".$_extensionFilter");
  }

}