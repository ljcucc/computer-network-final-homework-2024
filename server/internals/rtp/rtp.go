package main

import (
	"bytes"
	"time"
)

const HEADER_SIZE = 12

type RtpPacket struct {
	header  []byte
	payload []byte
}

func NewRtpPacket() *RtpPacket {
	return &RtpPacket{header: make([]byte, HEADER_SIZE)}
}

func (p *RtpPacket) Encode(version int, padding bool, extension bool, cc int, seqnum int, marker bool, pt int, ssrc int, payload []byte) {
	timestamp := time.Now().UnixNano() / int64(time.Millisecond)

	p.header[0] = (0b11 << 6) & 0xFF // version bits
	p.header[0] |= (padding ? 1 << 5 : 0)
	p.header[0] |= (extension ? 1 << 4 : 0)
	p.header[0] |= cc & 0xFF

	p.header[1] = (marker ? 1 << 7 : 0) & 0xFF
	p.header[1] |= pt & 0xFF

	p.header[2] = (seqnum >> 8) & 0xFF
	p.header[3] = seqnum & 0xFF

	p.header[4] = (timestamp >> 24) & 0xFF
	p.header[5] = (timestamp >> 16) & 0xFF
	p.header[6] = (timestamp >> 8) & 0xFF
	p.header[7] = timestamp & 0xFF

	p.payload = payload
}

func (p *RtpPacket) Decode(byteStream []byte) {
	p.header = byteStream[:HEADER_SIZE]
	p.payload = byteStream[HEADER_SIZE:]
}

func (p *RtpPacket) Version() int {
	return int(p.header[0] >> 6) & 0b11
}

func (p *RtpPacket) SeqNum() int {
	return int(p.header[2]<<8 | p.header[3])
}

func (p *RtpPacket) Timestamp() int {
	return int(p.header[4]<<24 | p.header[5]<<16 | p.header[6]<<8 | p.header[7])
}

func (p *RtpPacket) PayloadType() int {
	return int(p.header[1] & 127)
}

func (p *RtpPacket) GetPayload() []byte {
	return p.payload
}

func (p *RtpPacket) GetPacket() []byte {
	return bytes.Join([][]byte{p.header, p.payload}, nil)
}
