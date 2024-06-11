package stream

import (
	"fmt"
	"strings"
)

const CHUNK_SIZE = 4096

type VideoStream interface {
	NextFrame() []byte
	FrameNbr() int
}

func NewVideoStream(filename string) VideoStream {
	filenameStrings := strings.Split(filename, ".")
	ext := strings.ToLower(filenameStrings[len(filenameStrings)-1])
	fmt.Println("NewVideoStream(), filename is ", filename, ",ext is ", ext)

	if ext == "mjpg" || ext == "mjpeg" {
		fmt.Println("format is MjpgStream")
		return NewMjpgStream(filename)
	}

	fmt.Println("format is BinaryStream")
	return NewBinaryStream(filename, CHUNK_SIZE)
}
