#library("markdown_server");

#import("package:dartdoc/markdown.dart");
#import("dart:io");

//part "src/markdown_server.dart";
//part "src/static_server.dart";
#source("src/markdown_server.dart");
#source("src/static_server.dart");
#source("src/mime_types.dart");

runServer(String rootPath, String host, int port) {
  final server = new HttpServer();

  final mdServer = new MarkdownServer(rootPath);
  server.addRequestHandler(mdServer.matcher, mdServer.handler);

  final staticServer = new StaticServer(rootPath);
  server.addRequestHandler(staticServer.matcher, staticServer.handler);

  server.defaultRequestHandler = _notFoundHandler;

  server.listen(host, port);
  print("Listening on $host:$port, serving files from: $rootPath");
}



void _notFoundHandler(req,HttpResponse res) {
  res.statusCode = 404;
  res.outputStream.writeString("${req.path}\n404 - not found""");
  res.outputStream.close();
}