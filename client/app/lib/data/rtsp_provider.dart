import 'package:flutter/material.dart';
import 'package:socket_rtsp/socket_rtsp.dart';

class RtspProvider extends ChangeNotifier {
  RtspClient? client;
  bool _isConnect = false;

  bool _isSetup = false;
  bool _isPlay = false;

  bool get isConnect => _isConnect;
  bool get isSetup => _isSetup;
  bool get isPlay => _isPlay;

  Future<void> setup() async {
    print("setup()");

    if (client == null) {
      client = RtspClient(
        serverAddr: '127.0.0.1',
        serverPort: 8081,
        rtpPort: 9010,
        fileName: './ikea2.mjpg',
      );

      await client!.connect();
      notifyListeners();
    }

    _isConnect = true;
    client!.sendRtspRequest(RtspRequest.setup);
    _isSetup = true;
    notifyListeners();
  }

  Future<void> play() async {
    if (!_isConnect) return;
    client!.sendRtspRequest(RtspRequest.play);

    _isPlay = true;
    notifyListeners();
  }

  Future<void> pause() async {
    if (!_isConnect) return;
    client!.sendRtspRequest(RtspRequest.pause);

    _isPlay = false;
    notifyListeners();
  }

  Future<void> teardown() async {
    if (!_isConnect) return;
    client!.sendRtspRequest(RtspRequest.teardown);

    _isSetup = false;
    notifyListeners();
  }
}
