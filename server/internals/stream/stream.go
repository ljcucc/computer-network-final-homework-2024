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
		frameNum: -1,
	}
}

func (v *VideoStream) NextFrame() []byte {
	// read first one byte to fit next 4 bits into unit32
	var head byte
	binary.Read(v.file, binary.BigEndian, &head)

	var frameLength uint32
	err := binary.Read(v.file, binary.BigEndian, &frameLength)
	if err != nil {
		fmt.Println("Error reading frame length:", err)
		if err == io.EOF {
			// Handle end of file
			fmt.Println("EOF")
			return nil
		}
		return nil
	}

	v.frameNum++

	data := make([]byte, frameLength)
	n, err := v.file.Read(data)
	if err != nil {
		fmt.Println("Error reading frame data:", err)
		return nil
	}

	return data[:n]
}

func (v *VideoStream) FrameNbr() int {
	return v.frameNum
}
