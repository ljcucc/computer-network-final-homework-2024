library socket_rtsp;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:socket_rtsp/rtp_packet.dart';

enum RtspState { init, ready, playing }

enum RtspRequest { setup, play, pause, teardown }

class RtspClient {
  final String serverAddr;
  final int serverPort;
  final int rtpPort;
  final String fileName;

  RtspState state = RtspState.init;
  int rtspSeq = 0;
  int sessionId = 0;
  RtspRequest? requestSent;
  bool teardownAcked = false;
  int frameNbr = 0;

  late RawDatagramSocket rtpSocket;
  late Socket rtspSocket;
  final StreamController<Uint8List> _frameStreamController =
      StreamController<Uint8List>();

  Stream<Uint8List> get frameStream => _frameStreamController.stream;

  RtspClient(
      {required this.serverAddr,
      required this.serverPort,
      required this.rtpPort,
      required this.fileName});

  Future<void> connect() async {
    rtspSocket = await Socket.connect(serverAddr, serverPort);
    rtspSocket.listen(handleRtspReply);
  }

  void sendRtspRequest(RtspRequest requestCode) async {
    String request;

    switch (requestCode) {
      case RtspRequest.setup:
        if (state == RtspState.init) {
          rtspSeq++;
          request =
              'SETUP $fileName RTSP/1.0\nCSeq: $rtspSeq\nTransport: RTP/UDP; client_port= $rtpPort';
          requestSent = RtspRequest.setup;
          await openRtpPort();
          listenRtp();
        } else {
          return;
        }
        break;

      case RtspRequest.play:
        if (state == RtspState.ready) {
          rtspSeq++;
          request =
              'PLAY $fileName RTSP/1.0\nCSeq: $rtspSeq\nSession: $sessionId';
          requestSent = RtspRequest.play;
        } else {
          return;
        }
        break;

      case RtspRequest.pause:
        if (state == RtspState.playing) {
          rtspSeq++;
          request =
              'PAUSE $fileName RTSP/1.0\nCSeq: $rtspSeq\nSession: $sessionId';
          requestSent = RtspRequest.pause;
        } else {
          return;
        }
        break;

      case RtspRequest.teardown:
        if (state != RtspState.init) {
          rtspSeq++;
          request =
              'TEARDOWN $fileName RTSP/1.0\nCSeq: $rtspSeq\nSession: $sessionId';
          requestSent = RtspRequest.teardown;
        } else {
          return;
        }
        break;

      default:
        return;
    }

    rtspSocket.write('$request\r\n');
    print('\nData sent:\n$request');
  }

  void handleRtspReply(Uint8List data) {
    final reply = String.fromCharCodes(data);
    final lines = reply.split('\n');
    final seqNum = int.parse(lines[1].split(' ')[1]);

    if (seqNum == rtspSeq) {
      final session = int.parse(lines[2].split(' ')[1]);

      if (sessionId == 0) {
        sessionId = session;
      }

      if (sessionId == session) {
        if (int.parse(lines[0].split(' ')[1]) == 200) {
          switch (requestSent) {
            case RtspRequest.setup:
              state = RtspState.ready;
              break;
            case RtspRequest.play:
              state = RtspState.playing;
              break;
            case RtspRequest.pause:
              state = RtspState.ready;
              break;
            case RtspRequest.teardown:
              state = RtspState.init;
              teardownAcked = true;
              rtspSocket.close();
              rtpSocket.close();
              break;
            default:
              break;
          }
        }
      }
    }
  }

  Future<void> openRtpPort() async {
    rtpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, rtpPort);
    print("rtp port is opened");
  }

  void listenRtp() {
    rtpSocket.listen((event) {
      print("new rtp packet");
      if (event == RawSocketEvent.read) {
        final packet = rtpSocket.receive();
        if (packet != null) {
          final rtpPacket = RtpPacket();
          rtpPacket.decode(packet.data);
          final currFrameNbr = rtpPacket.seqNum();
          print('Current Seq Num: $currFrameNbr');

          if (currFrameNbr > frameNbr) {
            frameNbr = currFrameNbr;
            _frameStreamController.add(rtpPacket.getPayload());
          }
        }
      }
    });
  }
}
