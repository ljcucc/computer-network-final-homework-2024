package rtp

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
	if padding {
		p.header[0] |= byte(1 << 5)
	}
	if extension {
		p.header[0] |= byte(1 << 4)
	}
	p.header[0] |= byte(cc)

	if marker {
		p.header[1] = byte(1 << 7)
	}
	p.header[1] |= byte(pt & 0xFF)

	p.header[2] = byte(seqnum>>8) & 0xFF
	p.header[3] = byte(seqnum & 0xFF)

	p.header[4] = byte((timestamp >> 24) & 0xFF)
	p.header[5] = byte((timestamp >> 16) & 0xFF)
	p.header[6] = byte((timestamp >> 8) & 0xFF)
	p.header[7] = byte(timestamp & 0xFF)

	p.payload = payload
}

func (p *RtpPacket) Decode(byteStream []byte) {
	p.header = byteStream[:HEADER_SIZE]
	p.payload = byteStream[HEADER_SIZE:]
}

func (p *RtpPacket) Version() int {
	return int(p.header[0]>>6) & 0b11
}

func (p *RtpPacket) SeqNum() int {
	return int(
		uint(p.header[2])<<8 | uint(p.header[3]),
	)
}

func (p *RtpPacket) Timestamp() int {
	return int(
		uint(p.header[4])<<24 | uint(p.header[5])<<16 | uint(p.header[6])<<8 | uint(p.header[7]),
	)
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
