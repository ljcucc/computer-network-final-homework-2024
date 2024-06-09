# Socket RTSP

## Explanation

1. **Class Structure**: The code defines an `RtspClient` class that encapsulates the RTSP client functionality, separating it from any UI concerns.
2. **Enums**: It uses enums (`RtspState`, `RtspRequest`) to represent the different states and request types, making the code more readable and maintainable.
3. **State Management**:  The class keeps track of its internal state (`state`, `rtspSeq`, `sessionId`, etc.) to handle RTSP communication correctly.
4. **Socket Communication**: It utilizes Dart's `Socket` and `RawDatagramSocket` classes for RTSP (TCP) and RTP (UDP) communication respectively.
5. **Request/Reply Handling**: It includes functions to:
   -  `sendRtspRequest`: Construct and send different types of RTSP requests (SETUP, PLAY, PAUSE, TEARDOWN).
   - `handleRtspReply`: Parse and process incoming RTSP replies from the server, updating the client state accordingly.
6. **RTP Packet Processing**: The `listenRtp` function receives RTP packets, decodes them using your provided `RtpPacket` class, and extracts the payload (video frame data).
7. **Data Stream**:  Instead of saving frames as JPEGs, it uses a `StreamController` (`_frameStreamController`) to provide a stream of raw video frame data (`Uint8List`). This allows for flexibility in how you handle the received video data in your Flutter application.

## How to use this class

1. **Import**: Import the necessary files (this file and `rtp_packet.dart`).
2. **Create Instance**: Create an instance of `RtspClient` providing server address, ports, and filename.
3. **Connect**: Call the `connect()` method to establish the initial connection.
4. **Send Requests**: Use `sendRtspRequest` to send SETUP, PLAY, PAUSE, TEARDOWN commands.
5. **Consume Video Stream**: Listen to the `frameStream` to receive the video frame data. You can then process or display these frames in your Flutter UI.

## Example (Basic Usage in a Flutter Widget)

```dart
class MyVideoPlayer extends StatefulWidget {
  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late RtspClient _client;

  @override
  void initState() {
    super.initState();
    _client = RtspClient(
        serverAddr: 'your_server_ip', // Replace with your server IP
        serverPort: 554,
        rtpPort: 5004,
        fileName: 'your_video_file.mp4');

    _client.connect().then((_) {
      _client.sendRtspRequest(RtspRequest.setup);
    });
  }

  @override
  void dispose() {
    _client.sendRtspRequest(RtspRequest.teardown);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return // ... Your UI to display video using _client.frameStream
  }
}
```

Remember to replace placeholder values with your actual server details and file names. You'll need to implement the video display logic using the `_client.frameStream` and a suitable video player package in your Flutter application.
