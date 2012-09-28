dart_markdown_server
====================

A simple Dart Markdown Server application and library, which serves static files, 
automatically converting .md files to .html on the fly.

It uses the dartdoc markdown parser from the Dart SDK to perform the conversion.

## Usage:
This package is both a library and an application.  

### Library Usage:
    
    import "dart:io";
    import "package:markdown_server/markdown_server_lib.dart" as md;
    
    main() {
      var httpServer = new HttpServer();
      var markdownServer = new md.MarkdownServer("/path/to/serve/");
      httpServer.addRequestHandler(markdownServer.matcher, markdownServer.handler);
      httpServer.listen("127.0.0.1",8080); // only serves markdown files
                                           // add additional request handlers to serve other files                                           
    }
    
### Application usage:

From the command line, which serves both markdown and non markdown files

    dart markdown_server.dart -h 127.0.0.1 -p 8080 -r /path/to/serve/