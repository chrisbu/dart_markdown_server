import "dart:io";
import "package:markdown_server/markdown_server.dart" as md;

main() {
  var httpServer = new HttpServer();
  var markdownServer = new md.MarkdownServer("/path/to/serve/");
  httpServer.addRequestHandler(markdownServer.matcher, markdownServer.handler);
  httpServer.listen("127.0.0.1",8080); // only serves markdown files
                                       // add additional request handlers to serve other files
}