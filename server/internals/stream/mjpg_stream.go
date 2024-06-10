package stream

import (
	"fmt"
	"io"
	"os"
	"strconv"
)

type MjpgStream struct {
	filename string
	file     *os.File
	frameNum int
}

func NewMjpgStream(filename string) *MjpgStream {
	file, err := os.Open(filename)
	if err != nil {
		fmt.Println("Error opening video file:", err)
		return nil
	}

	return &MjpgStream{
		filename: filename,
		file:     file,
		frameNum: -1,
	}
}

func (v *MjpgStream) NextFrame() []byte {
	frameLengthStr := make([]byte, 5)
	v.file.Read(frameLengthStr)
	fmt.Println("frameLengthStr: ", string(frameLengthStr))
	frameLength, err := strconv.Atoi(string(frameLengthStr))
	if err != nil {
		fmt.Println("Error reading frame length:", err)
		if err == io.EOF {
			// Handle end of file
			fmt.Println("EOF")
			return nil
		}
		return nil
	}

	fmt.Println("frameLength: ", frameLength)

	v.frameNum++

	data := make([]byte, frameLength)
	n, err := v.file.Read(data)
	if err != nil {
		fmt.Println("Error reading frame data:", err)
		return nil
	}

	return data[:n]
}

func (v *MjpgStream) FrameNbr() int {
	return v.frameNum
}
