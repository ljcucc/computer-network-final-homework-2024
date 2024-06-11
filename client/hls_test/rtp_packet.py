import sys
from time import time
HEADER_SIZE = 12

class RtpPacket:
	header = bytearray(HEADER_SIZE)

	def __init__(self):
		pass

	def encode(self, version, padding, extension, cc, seqnum, marker, pt, ssrc, payload):
		"""Encode the RTP packet with header fields and payload."""
		timestamp = int(time())
		header = bytearray(HEADER_SIZE)
		#--------------
		# TO COMPLETE
		#--------------
		# Fill the header bytearray with RTP header fields

		header[0] = 0
		header[0] = header[0] | (0b11 << 6)  & 0xFF # version bits
		header[0] = header[0] | (padding << 5)  & 0xFF
		header[0] = header[0] | (extension << 4)  & 0xFF
		header[0] = header[0] | cc & 0xFF

		header[1] = 0
		header[1] = header[1] | (marker << 7) & 0xFF
		header[1] = header[1] | 26 # payload type field (PT): MJPEG

		header[2] = (seqnum >> 8) & 0xFF
		header[3] = seqnum & 0xFF

		t = int(time())

		header[4] = (t >> 24) & 0xFF
		header[5] = (t >> 16 ) & 0xFF
		header[6] = (t >> 8) & 0xFF
		header[7] = t & 0xFF

		# Get the payload from the argument
		self.payload = payload
		self.header = header

	def decode(self, byteStream):
		"""Decode the RTP packet."""
		self.header = bytearray(byteStream[:HEADER_SIZE])
		self.payload = byteStream[HEADER_SIZE:]

	def version(self):
		"""Return RTP version."""
		return int(self.header[0] >> 6)

	def seqNum(self):
		"""Return sequence (frame) number."""
		seqNum = self.header[2] << 8 | self.header[3]
		return int(seqNum)

	def timestamp(self):
		"""Return timestamp."""
		timestamp = self.header[4] << 24 | self.header[5] << 16 | self.header[6] << 8 | self.header[7]
		return int(timestamp)

	def payloadType(self):
		"""Return payload type."""
		pt = self.header[1] & 127
		return int(pt)

	def getPayload(self):
		"""Return payload."""
		return self.payload

	def getPacket(self):
		"""Return RTP packet."""
		print(len(self.payload))
		return self.header + self.payload
