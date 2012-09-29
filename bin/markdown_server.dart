
import "package:args/args.dart";
import "package:markdown_server/markdown_server_lib.dart" as server;

void main() {
  var args = _getArgs();
  if (args != null) {
    final rootPath = args['root'];
    final host = args['host'];
    final port = int.parse(args['port']);
    server.runServer(rootPath, host, port);
  }
}


ArgResults _getArgs() {

  final parser = new ArgParser();
  parser.addOption("root", abbr:"r", help:"The root path to serve", defaultsTo: "/");
  parser.addOption("host", abbr:"h", help:"The host IP to listen on", defaultsTo: "127.0.0.1");
  parser.addOption("port", abbr:"p", help:"The port to listen to", defaultsTo: "8080");

  final options = new Options();
  if (options.arguments.length == 0) {
    print(parser.getUsage());
    return null;
  }
  else {
    return parser.parse(options.arguments);
  }
}







