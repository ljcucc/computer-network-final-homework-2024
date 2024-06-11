import 'package:app/data/rtsp_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:socket_rtsp/socket_rtsp.dart';

class ConnectionConfigWidget extends StatefulWidget {
  const ConnectionConfigWidget({super.key});

  @override
  State<ConnectionConfigWidget> createState() => _ConnectionConfigWidgetState();
}

class _ConnectionConfigWidgetState extends State<ConnectionConfigWidget> {
  late TextEditingController serverAddr =
      TextEditingController(text: "127.0.0.1");
  late TextEditingController port = TextEditingController(text: "8080");
  late TextEditingController rtpPort = TextEditingController(text: "9000");
  late TextEditingController filename =
      TextEditingController(text: "../test.mp4");

  _promptDialog(TextEditingController tec, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: tec,
            onChanged: (_) => setState(() {}),
          ),
          actions: [
            TextButton(
              child: Text("Done"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton(
          onPressed: () {
            final aic = Provider.of<RtspProvider>(context, listen: false);
            aic.client = RtspClient(
              serverAddr: serverAddr.text,
              serverPort: int.tryParse(port.text) ?? 8080,
              rtpPort: int.tryParse(rtpPort.text) ?? 9000,
              fileName: filename.text,
            );
            aic.client!.connect();
          },
          child: Text("Connect"),
        ),
        FilledButton.tonalIcon(
          icon: Icon(Icons.edit_outlined),
          onPressed: () {
            _promptDialog(serverAddr, "Server Address");
          },
          label: Text("Server Addr: ${serverAddr.text}"),
        ),
        FilledButton.tonalIcon(
          icon: Icon(Icons.edit_outlined),
          onPressed: () {
            _promptDialog(port, "Port");
          },
          label: Text("Port: ${port.text}"),
        ),
        FilledButton.tonalIcon(
          icon: Icon(Icons.edit_outlined),
          onPressed: () {
            _promptDialog(rtpPort, "RTP Port");
          },
          label: Text("RTP Port: ${rtpPort.text}"),
        ),
        FilledButton.tonalIcon(
          icon: Icon(Icons.edit_outlined),
          onPressed: () {
            _promptDialog(filename, "Filename");
          },
          label: Text("Filename: ${filename.text}"),
        ),
      ],
    );
  }
}
