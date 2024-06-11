import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:app/data/rtsp_provider.dart';

class StreamingServer {
  final Stream<Uint8List> _videoStream;
  RtspProvider rtsp;

  StreamingServer(this._videoStream, this.rtsp);

  int frame = 0;

  Future<void> start(String host, int port) async {
    final server = await ServerSocket.bind(host, port);
    print('Server started on ${server.address.address}:${server.port}');

    server.listen((socket) {
      _handleConnection(socket);
    });
  }

  void _handleConnection(Socket socket) {
    print('Connected by ${socket.remoteAddress.address}:${socket.remotePort}');

    socket.listen((data) async {
      final request = String.fromCharCodes(data).split('\n')[0];
      if (request.contains('/video.mp4')) {
        print("got request");
        await _sendVideoStream(socket);
      } else if (request.contains('.m3u8')) {
      } else {
        _send404(socket);
      }
    });
  }

  Future<void> _sendVideoStream(Socket socket) async {
    socket.writeln('HTTP/1.1 200 OK');
    socket.writeln('Content-Type: video/mp4');
    socket.writeln('Transfer-Encoding: chuncked');
    socket.writeln('Content-Length: 3700000'); // Length of body
    socket.writeln(); // End of headers
    print("sending video...");

    await rtsp.play();
    // await socket.addStream(_videoStream);

    await for (final chunk in _videoStream) {
      print(
          "write chunk ${chunk.length}, first byte: ${chunk[0]}, frame ${frame++}");
      socket.write(String.fromCharCodes(chunk));
      // socket.add(chunk);
      await socket.flush();
      // socket.write(chunk);
      // You can adjust the delay if needed to control the streaming rate.
      await Future.delayed(Duration(milliseconds: 10));
    }

    await socket.flush();
    socket.close();
  }

  void _send404(Socket socket) async {
    socket.writeln('HTTP/1.0 404 Not Found'); // Note: \r\n
    socket.writeln('Content-Type: text/plain'); // Example header
    socket.writeln('Content-Length: 0'); // Length of body
    socket.writeln(); // End of headers
    await socket.flush();
    socket.destroy();
    socket.close();
  }
}
