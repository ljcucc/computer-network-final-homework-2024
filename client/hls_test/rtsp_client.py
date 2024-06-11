import socket
import threading
import time
from enum import Enum
from rtp_packet import RtpPacket

class RtspState(Enum):
    INIT = 0
    READY = 1
    PLAYING = 2


class RtspRequest(Enum):
    SETUP = 0
    PLAY = 1
    PAUSE = 2
    TEARDOWN = 3


class RtspClient:
    def __init__(self, server_addr, server_port, rtp_port, file_name):
        self.server_addr = server_addr
        self.server_port = server_port
        self.rtp_port = rtp_port
        self.file_name = file_name

        self.state = RtspState.INIT
        self.rtsp_seq = 0
        self.session_id = 0
        self.request_sent = None
        self.teardown_acked = False
        self.frame_nbr = 0

        self.rtsp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.rtp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self._frame_event = threading.Event()

    def connect(self):
        """Connect to the server."""
        self.rtsp_socket.connect((self.server_addr, self.server_port))
        threading.Thread(target=self._listen_rtsp_reply).start()

    def send_rtsp_request(self, request_code):
        """Send RTSP request to the server."""
        request = ''

        if request_code == RtspRequest.SETUP and self.state == RtspState.INIT:
            self.rtsp_seq += 1
            request = (
                f"SETUP {self.file_name} RTSP/1.0\n"
                f"CSeq: {self.rtsp_seq}\n"
                f"Transport: RTP/UDP; client_port= {self.rtp_port}"
            )
            self.request_sent = RtspRequest.SETUP
            self._open_rtp_port()
            # threading.Thread(target=self._listen_rtp).start()

        elif request_code == RtspRequest.PLAY and self.state == RtspState.READY:
            self.rtsp_seq += 1
            request = (
                f"PLAY {self.file_name} RTSP/1.0\n"
                f"CSeq: {self.rtsp_seq}\n"
                f"Session: {self.session_id}"
            )
            self.request_sent = RtspRequest.PLAY

        elif request_code == RtspRequest.PAUSE and self.state == RtspState.PLAYING:
            self.rtsp_seq += 1
            request = (
                f"PAUSE {self.file_name} RTSP/1.0\n"
                f"CSeq: {self.rtsp_seq}\n"
                f"Session: {self.session_id}"
            )
            self.request_sent = RtspRequest.PAUSE

        elif request_code == RtspRequest.TEARDOWN and self.state != RtspState.INIT:
            self.rtsp_seq += 1
            request = (
                f"TEARDOWN {self.file_name} RTSP/1.0\n"
                f"CSeq: {self.rtsp_seq}\n"
                f"Session: {self.session_id}"
            )
            self.request_sent = RtspRequest.TEARDOWN

        if request:
            self.rtsp_socket.sendall(request.encode())
            print("\nData sent:\n" + request)

    def _listen_rtsp_reply(self):
        """Listen for RTSP replies from the server."""
        while True:
            try:
                reply = self.rtsp_socket.recv(1024).decode()
                self._handle_rtsp_reply(reply)
            except OSError:
                break

    def _handle_rtsp_reply(self, reply):
        """Handle an RTSP reply from the server."""
        lines = reply.split("\n")
        seq_num = int(lines[1].split(" ")[1])

        if seq_num == self.rtsp_seq:
            session = int(lines[2].split(" ")[1])
            if self.session_id == 0:
                self.session_id = session

            if self.session_id == session and int(lines[0].split(" ")[1]) == 200:
                if self.request_sent == RtspRequest.SETUP:
                    self.state = RtspState.READY
                elif self.request_sent == RtspRequest.PLAY:
                    self.state = RtspState.PLAYING
                elif self.request_sent == RtspRequest.PAUSE:
                    self.state = RtspState.READY
                    self._frame_event.set()
                elif self.request_sent == RtspRequest.TEARDOWN:
                    self.state = RtspState.INIT
                    self.teardown_acked = True
                    self.rtsp_socket.close()
                    self.rtp_socket.close()

    def _open_rtp_port(self):
        """Open an RTP socket to receive video data."""
        self.rtp_socket.bind(("", self.rtp_port))
        print("RTP port is opened")

    def listen_rtp(self):
        """Listen for RTP packets and process them."""
        if self.teardown_acked:
            print("teardown_acked")
            return
        try:
            data = self.rtp_socket.recv(20480)
            if data:
                rtp_packet = RtpPacket()
                rtp_packet.decode(data)
                curr_frame_nbr = rtp_packet.seqNum()
                print(f"Current Seq Num: {curr_frame_nbr}")

                if curr_frame_nbr > self.frame_nbr:
                    self.frame_nbr = curr_frame_nbr
                    self._frame_event.set()
                    self._frame_event.clear()
                    return rtp_packet.getPayload()
        except socket.timeout:
            print("socket timeout")
            pass
        except OSError as e:
            print("OSError")
            print(e)
            return

    # @property
    # def frame_stream(self):
    #     """Generator that yields received video frames."""
    #     for frame in self._listen_rtp():
    #         yield frame
