#import('dart:io');
#import('dart:math', prefix:"Math");

send404(HttpResponse response) {
  response.statusCode = HttpStatus.NOT_FOUND;
  response.outputStream.close();
}

startServer(String basePath) {
  var server = new HttpServer();
  int port = Math.parseInt(Platform.environment['PORT']);
  server.listen('0.0.0.0', port);
  server.defaultRequestHandler = (HttpRequest request, HttpResponse response) {
    final String path = request.path == '/' ? '/web/hexgrid.html' : request.path;
    final File file = new File('${basePath}${path}');
    file.exists().then((bool found) {
      if (found) {
        file.fullPath().then((String fullPath) {
          if (!fullPath.startsWith(basePath)) {
            //_send404(response);
          } else {
            file.openInputStream().pipe(response.outputStream);
          }
        });
      } else {
        //_send404(response);
      }
    }); 
  };
}

main() {
  // Compute base path for the request based on the location of the
  // script and then start the server.
  File script = new File(new Options().script);
  script.directory().then((Directory d) {
    startServer(d.path);
  });
}