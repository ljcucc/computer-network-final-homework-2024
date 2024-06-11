import socket
import os
import threading
import time

HOST = '0.0.0.0'  # Standard loopback interface address (localhost)
PORT = 8071        # Port to listen on (non-privileged ports are > 1023)

def handle_client(conn, addr):
    frame = 0
    print(f'Connected by {addr}')
    while True:
        data = conn.recv(1024)
        if not data:
            break

        request = data.decode('utf-8').split('\n')[0]
        if '/video.mp4' in request:
            with open('../../test.mp4', 'rb') as f:
                conn.sendall(b'HTTP/1.1 200 OK\nContent-Type: video/mp4\n\n')
                while True:
                    # print("send a chunk")
                    chunk = f.read(4096)
                    if not chunk:
                        break
                    conn.sendall(chunk)
                    frame += 1
                    print(f"frame: {frame}, first byte: {chunk[0]}, len: {len(chunk)}")
                    time.sleep(0.01)
            break
        else:
            conn.sendall(b'HTTP/1.1 404 Not Found\n\n')
            break
    conn.close()
    print(f'Connection closed with {addr}')

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    print(f'Server started on {HOST}:{PORT}')

    while True:
        conn, addr = s.accept()
        thread = threading.Thread(target=handle_client, args=(conn, addr))
        thread.start()
