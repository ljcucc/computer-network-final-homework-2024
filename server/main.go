package main

import (
	"flag"
	"fmt"
	"net"

	"github.com/ljcucc/ccfh2024/server/internals/worker"
)

var (
	port int
)

func init() {
	flag.IntVar(&port, "port", 8080, "Server port")
}

func main() {
	flag.Parse()

	fmt.Printf("Server is starting on port %d...\n", port)

	rtspAddr := fmt.Sprintf(":%d", port)
	rtspListener, err := net.Listen("tcp", rtspAddr)
	if err != nil {
		fmt.Println("Error listening:", err)
		return
	}
	defer rtspListener.Close()

	for {
		conn, err := rtspListener.Accept()
		if err != nil {
			fmt.Println("Error accepting connection:", err)
			continue
		}

		// Create clientInfo struct instead of map
		clientInfo := worker.ClientInfo{
			RtspSocket: &conn,
		}
		worker := worker.NewServerWorker(clientInfo)
		go worker.Run()
	}
}
