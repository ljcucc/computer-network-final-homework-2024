import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

class HLSServer {
  final String filename;
  final Future<String> Function() resolveM3u8;
  final Future<Uint8List> Function(int) resolveTs;

  HLSServer({
    required this.filename,
    required this.resolveM3u8,
    required this.resolveTs,
  });

  Future<void> start(int port) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    print('Server listening on port ${server.port}');

    await for (HttpRequest request in server) {
      final path = request.uri.path;
      if (path == '/$filename.m3u8') {
        _handleM3u8Request(request);
      } else if (path.startsWith('/$filename') && path.endsWith('.ts')) {
        _handleTsRequest(request);
      } else {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      }
    }
  }

  Future<void> _handleM3u8Request(HttpRequest request) async {
    try {
      final m3u8Content = await resolveM3u8();
      print("got m3u8");
      request.response.headers.contentType =
          ContentType('application', 'vnd.apple.mpegurl');
      request.response.write(m3u8Content);
    } catch (e) {
      print('Error resolving m3u8: $e');
      request.response.statusCode = HttpStatus.internalServerError;
    } finally {
      await request.response.close();
    }
  }

  Future<void> _handleTsRequest(HttpRequest request) async {
    try {
      final segmentNumber =
          int.tryParse(request.uri.path.split('.')[0].split(filename)[1]);
      if (segmentNumber == null) {
        throw Exception('Invalid segment number');
      }
      final tsContent = await resolveTs(segmentNumber);
      request.response.headers.contentType =
          ContentType('video', 'mp2t', charset: 'utf-8');
      request.response.add(tsContent);
    } catch (e) {
      print('Error resolving ts segment: $e');
      request.response.statusCode = HttpStatus.internalServerError;
    } finally {
      await request.response.close();
    }
  }
}

class ChunkJoiner {
  final Stream<Uint8List> _inputStream;
  final List<Uint8List> _chunks = [];
  final Completer<void> _completer = Completer<void>();

  bool isComplete = false;

  ChunkJoiner(this._inputStream);

  Future<void> join() async {
    _inputStream.listen((chunk) {
      if (chunk.length < 4) {
        // print(chunk);
        if (!_completer.isCompleted) _completer.complete();
        return;
      }
      _chunks.add(chunk);
      // print(utf8.decode(joinedData));
    }, onDone: () {
      print("done!");
      // _completer.complete();
    });

    await _completer.future;
  }

  Uint8List get joinedData {
    final totalLength =
        _chunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
    print("join: $totalLength");
    final result = Uint8List(totalLength);
    int offset = 0;
    for (var chunk in _chunks) {
      result.setAll(offset, chunk);
      offset += chunk.length;
    }
    return result;
  }
}
