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

// ClientInfo struct to hold client-specific information
type ClientInfo struct {
	RtspSocket  *net.Conn
	VideoStream *stream.VideoStream
	Session     int
	RtpPort     string
	RtpSocket   *net.UDPConn
	Event       chan bool
}

type ServerWorker struct {
	clientInfo ClientInfo
	state      int
	sync.Mutex
}

func NewServerWorker(clientInfo ClientInfo) *ServerWorker {
	return &ServerWorker{
		clientInfo: clientInfo,
		state:      INIT,
	}
}

func (w *ServerWorker) Run() {
	go w.recvRtspRequest()
}

func (w *ServerWorker) recvRtspRequest() {
	connSocket := w.clientInfo.RtspSocket

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

			w.clientInfo.VideoStream = stream.NewVideoStream(filename)
			w.state = READY

			// Generate a randomized RTSP session ID
			w.clientInfo.Session = rand.Intn(900000) + 100000

			// Send RTSP reply
			w.replyRtsp(OK_200, seq[1])

			// Get the RTP/UDP port from the last line
			w.clientInfo.RtpPort = strings.Split(request[2], " ")[3]
		}
	case PLAY:
		if w.state == READY {
			fmt.Println("processing PLAY\n")
			w.state = PLAYING

			// Create a new socket for RTP/UDP
			rtpAddr, err := net.ResolveUDPAddr("udp", ":"+w.clientInfo.RtpPort)
			if err != nil {
				fmt.Println("Error resolving address:", err)
				return
			}
			rtpSocket, err := net.DialUDP("udp", nil, rtpAddr)
			if err != nil {
				fmt.Println("Error creating UDP socket:", err)
				return
			}
			w.clientInfo.RtpSocket = rtpSocket

			w.replyRtsp(OK_200, seq[1])

			// Create a new thread and start sending RTP packets
			event := make(chan bool)
			w.clientInfo.Event = event
			go w.sendRtp(event)
		}
	case PAUSE:
		if w.state == PLAYING {
			fmt.Println("processing PAUSE\n")
			w.state = READY

			w.clientInfo.Event <- true

			w.replyRtsp(OK_200, seq[1])
		}
	case TEARDOWN:
		fmt.Println("processing TEARDOWN\n")

		w.clientInfo.Event <- true

		w.replyRtsp(OK_200, seq[1])

		// Close the RTP socket
		w.clientInfo.RtpSocket.Close()
	}
}

func (w *ServerWorker) sendRtp(event chan bool) {
	for {
		select {
		case <-event:
			return
		default:
			data := w.clientInfo.VideoStream.NextFrame()
			if len(data) > 0 {
				frameNumber := w.clientInfo.VideoStream.FrameNbr()
				rtpPacket := rtp.NewRtpPacket()
				rtpPacket.Encode(2, false, false, 0, frameNumber, false, 26, 0, data)

				_, err := w.clientInfo.RtpSocket.Write(rtpPacket.GetPacket())
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
		reply := "RTSP/1.0 200 OK\nCSeq: " + seq + "\nSession: " + strconv.Itoa(w.clientInfo.Session)
		(*w.clientInfo.RtspSocket).Write([]byte(reply + "\n"))
	} else if code == FILE_NOT_FOUND_404 {
		fmt.Println("404 NOT FOUND")
	} else if code == CON_ERR_500 {
		fmt.Println("500 CONNECTION ERROR")
	}
}
