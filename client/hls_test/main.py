import socket
import os
import threading
import time
from rtsp_client import RtspClient,RtspRequest

HOST = '0.0.0.0'  # Standard loopback interface address (localhost)
PORT = 8061        # Port to listen on (non-privileged ports are > 1023)
rtsp = RtspClient(
        server_addr="127.0.0.1",
        server_port=8080,
        file_name="../test.mp4",
        rtp_port=9011
    )

def handle_client(conn, addr):
    global rtsp
    frame = 0
    print(f'Connected by {addr}')

    while True:
        data = conn.recv(1024)
        if not data:
            break

        request = data.decode('utf-8').split('\n')[0]
        if '/video.mp4' in request:
            conn.sendall(b'HTTP/1.1 200 OK\nContent-Type: video/mp4\n\n')

            rtsp.send_rtsp_request(RtspRequest.PLAY)
            time.sleep(1)

            while True:
                # print("send a chunk")
                # chunk = f.read(4096)
                chunk = rtsp.listen_rtp()
                if not chunk:
                    break
                conn.sendall(chunk)
                frame += 1
                print(f"frame: {frame}, first byte: {chunk[0]}, len: {len(chunk)}")
                # time.sleep(0.08)
        else:
            conn.sendall(b'HTTP/1.1 404 Not Found\n\n')
            break
    conn.close()
    print(f'Connection closed with {addr}')

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    print(f'Server started on {HOST}:{PORT}')

    rtsp.connect()
    time.sleep(1)
    rtsp.send_rtsp_request(RtspRequest.SETUP)

    while True:
        conn, addr = s.accept()
        thread = threading.Thread(target=handle_client, args=(conn, addr))
        thread.start()
