package stream

import (
	"fmt"
	"io"
	"os"
)

type BinaryStream struct {
	filename  string
	file      *os.File
	frameNum  int
	chunkSize int
}

func NewBinaryStream(filename string, chunkSize int) *BinaryStream {
	file, err := os.Open(filename)
	if err != nil {
		fmt.Println("Error opening video file:", err)
		return nil
	}

	return &BinaryStream{
		filename:  filename,
		file:      file,
		frameNum:  0,
		chunkSize: chunkSize,
	}
}

func (v *BinaryStream) NextFrame() []byte {
	v.frameNum++

	data := make([]byte, v.chunkSize)
	n, err := v.file.Read(data)
	fmt.Println("readed from file sized: ", n, ", first byte: ", data[0])
	if err != nil {
		fmt.Println("Error reading frame data:", err)
		if err == io.EOF {
			// Handle end of file
			fmt.Println("EOF")
		}

		if n == 0 {
			return []byte{0, 1}
		}
	}

	return data[:n]
}

func (v *BinaryStream) FrameNbr() int {
	return v.frameNum
}
