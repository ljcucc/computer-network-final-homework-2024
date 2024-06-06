package stream

import (
	"encoding/binary"
	"fmt"
	"io"
	"os"
)

type VideoStream struct {
	filename string
	file     *os.File
	frameNum int
}

func NewVideoStream(filename string) *VideoStream {
	file, err := os.Open(filename)
	if err != nil {
		fmt.Println("Error opening video file:", err)
		return nil
	}

	return &VideoStream{
		filename: filename,
		file:     file,
		frameNum: 0,
	}
}

func (v *VideoStream) NextFrame() []byte {
	var frameLength uint32
	err := binary.Read(v.file, binary.BigEndian, &frameLength)
	if err != nil {
		if err == io.EOF {
			// Handle end of file
			return nil
		}
		fmt.Println("Error reading frame length:", err)
		return nil
	}

	data := make([]byte, frameLength)
	n, err := v.file.Read(data)
	if err != nil {
		fmt.Println("Error reading frame data:", err)
		return nil
	}

	v.frameNum++

	return data[:n]
}

func (v *VideoStream) FrameNbr() int {
	return v.frameNum
}
