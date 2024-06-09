import 'dart:typed_data';

const int HEADER_SIZE = 12;

class RtpPacket {
  final Uint8List header = Uint8List(HEADER_SIZE);
  Uint8List? payload;

  RtpPacket();

  void encode(int version, bool padding, bool extension, int cc, int seqnum,
      bool marker, int pt, int ssrc, Uint8List payload) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    header[0] = (3 << 6) & 0xFF; // version bits
    header[0] |= (padding ? 1 << 5 : 0);
    header[0] |= (extension ? 1 << 4 : 0);
    header[0] |= cc & 0xFF;

    header[1] = (marker ? 1 << 7 : 0) & 0xFF;
    header[1] |= pt & 0xFF;

    header[2] = (seqnum >> 8) & 0xFF;
    header[3] = seqnum & 0xFF;

    header[4] = (timestamp >> 24) & 0xFF;
    header[5] = (timestamp >> 16) & 0xFF;
    header[6] = (timestamp >> 8) & 0xFF;
    header[7] = timestamp & 0xFF;

    this.payload = payload;
  }

  void decode(Uint8List byteStream) {
    header.setAll(0, byteStream.sublist(0, HEADER_SIZE));
    payload = byteStream.sublist(HEADER_SIZE);
  }

  int version() {
    return (header[0] >> 6) & 3;
  }

  int seqNum() {
    return (header[2] << 8) | header[3];
  }

  int timestamp() {
    return (header[4] << 24) | (header[5] << 16) | (header[6] << 8) | header[7];
  }

  int payloadType() {
    return header[1] & 127;
  }

  Uint8List getPayload() {
    return payload ?? Uint8List(0);
  }

  Uint8List getPacket() {
    return Uint8List.fromList([...header, ...getPayload()]);
  }
}
