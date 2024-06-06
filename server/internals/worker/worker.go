package worker

import (
	"fmt"
	"math/rand"
	"net"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/ljcucc/ccfh2024/server/internals/rtp"
	"github.com/ljcucc/ccfh2024/server/internals/stream"
)

const (
	SETUP              = "SETUP"
	PLAY               = "PLAY"
	PAUSE              = "PAUSE"
	TEARDOWN           = "TEARDOWN"
	INIT               = 0
	READY              = 1
	PLAYING            = 2
	OK_200             = 0
	FILE_NOT_FOUND_404 = 1
	CON_ERR_500        = 2
)

type ServerWorker struct {
	clientInfo map[string]interface{}
	state      int
	sync.Mutex
}

func NewServerWorker(clientInfo map[string]interface{}) *ServerWorker {
	return &ServerWorker{
		clientInfo: clientInfo,
		state:      INIT,
	}
}

func (w *ServerWorker) Run() {
	go w.recvRtspRequest()
}

func (w *ServerWorker) recvRtspRequest() {
	connSocket := w.clientInfo["rtspSocket"].(*net.Conn)

	for {
		buf := make([]byte, 256)
		n, err := (*connSocket).Read(buf)
		if err != nil {
			fmt.Println("Error reading from socket:", err)
			return
		}
		data := string(buf[:n])
		fmt.Println("Data received:\n" + data)
		w.processRtspRequest(data)
	}
}

func (w *ServerWorker) processRtspRequest(data string) {
	request := strings.Split(data, "\n")
	line1 := strings.Split(request[0], " ")
	requestType := line1[0]
	filename := line1[1]
	seq := strings.Split(request[1], " ")

	w.Lock()
	defer w.Unlock()
	switch requestType {
	case SETUP:
		if w.state == INIT {
			fmt.Println("processing SETUP\n")

			w.clientInfo["videoStream"] = stream.NewVideoStream(filename)
			w.state = READY

			// Generate a randomized RTSP session ID
			w.clientInfo["session"] = rand.Intn(900000) + 100000

			// Send RTSP reply
			w.replyRtsp(OK_200, seq[1])

			// Get the RTP/UDP port from the last line
			w.clientInfo["rtpPort"] = strings.Split(request[2], " ")[3]
		}
	case PLAY:
		if w.state == READY {
			fmt.Println("processing PLAY\n")
			w.state = PLAYING

			// Create a new socket for RTP/UDP
			rtpAddr, err := net.ResolveUDPAddr("udp", ":"+w.clientInfo["rtpPort"].(string))
			if err != nil {
				fmt.Println("Error resolving address:", err)
				return
			}
			rtpSocket, err := net.DialUDP("udp", nil, rtpAddr)
			if err != nil {
				fmt.Println("Error creating UDP socket:", err)
				return
			}
			w.clientInfo["rtpSocket"] = rtpSocket

			w.replyRtsp(OK_200, seq[1])

			// Create a new thread and start sending RTP packets
			event := make(chan bool)
			w.clientInfo["event"] = event
			go w.sendRtp(event)
		}
	case PAUSE:
		if w.state == PLAYING {
			fmt.Println("processing PAUSE\n")
			w.state = READY

			event := w.clientInfo["event"].(chan bool)
			event <- true

			w.replyRtsp(OK_200, seq[1])
		}
	case TEARDOWN:
		fmt.Println("processing TEARDOWN\n")

		event := w.clientInfo["event"].(chan bool)
		event <- true

		w.replyRtsp(OK_200, seq[1])

		// Close the RTP socket
		rtpSocket := w.clientInfo["rtpSocket"].(*net.UDPConn)
		rtpSocket.Close()
	}
}

func (w *ServerWorker) sendRtp(event chan bool) {
	for {
		select {
		case <-event:
			return
		default:
			data := w.clientInfo["videoStream"].(*stream.VideoStream).NextFrame()
			if len(data) > 0 {
				frameNumber := w.clientInfo["videoStream"].(*stream.VideoStream).FrameNbr()
				rtpPacket := rtp.NewRtpPacket()
				rtpPacket.Encode(2, false, false, 0, frameNumber, false, 26, 0, data)

				rtpSocket := w.clientInfo["rtpSocket"].(*net.UDPConn)
				_, err := rtpSocket.Write(rtpPacket.GetPacket())
				if err != nil {
					fmt.Println("Error sending RTP packet:", err)
				}
			}
			time.Sleep(40 * time.Millisecond) // Adjust this for your frame rate
		}
	}
}

func (w *ServerWorker) replyRtsp(code int, seq string) {
	if code == OK_200 {
		reply := "RTSP/1.0 200 OK\nCSeq: " + seq + "\nSession: " + strconv.Itoa(w.clientInfo["session"].(int))
		connSocket := w.clientInfo["rtspSocket"].(*net.Conn)
		(*connSocket).Write([]byte(reply + "\n"))
	} else if code == FILE_NOT_FOUND_404 {
		fmt.Println("404 NOT FOUND")
	} else if code == CON_ERR_500 {
		fmt.Println("500 CONNECTION ERROR")
	}
}
