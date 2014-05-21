#!/usr/bin/env python
#
# Test reference parser for SiK firmware in the iGCS project.
#
# Derived entirely from uploader.py (Serial firmware uploader for the SiK bootloader)
#  - https://github.com/tridge/SiK/blob/master/Firmware/tools/uploader.py
#

import sys, argparse, binascii, glob
 
class firmware(object):
	'''Loads a firmware file'''

	# parse a single IntelHex line and obtain the byte array and address
	def __parseline(self, line):
		# ignore lines not beginning with :
		if (line[0] != ":"):
			return;
		# parse the header off the line
		hexstr = line.rstrip()[1:-2]
		binstr = binascii.unhexlify(hexstr)
		command = ord(binstr[3])

		#print(line + " - " + hexstr + " - " + str(command))
		
		# only type 0 records are interesting
		if (command == 0):
			address = (ord(binstr[1]) << 8) + ord(binstr[2])
			bytes   = bytearray(binstr[4:])
			#print("     " + str(address) + "   " + str(len(bytes)) + "   " + str(bytes[0]))
			self.__insert(address, bytes)

	# insert the byte array into the ranges dictionary, merging as we go
	def __insert(self, address, bytes):
		# look for a range that immediately follows this one
		candidate = address + len(bytes)
		if (candidate in self.ranges):
			# found one, remove from ranges and merge it
			nextbytes = self.ranges.pop(candidate)
			bytes.extend(nextbytes)

		# iterate the existing ranges looking for one that precedes this
		for candidate in self.ranges.keys():
			prevlen = len(self.ranges[candidate])
			if ((candidate + prevlen) == address):
				self.ranges[candidate].extend(bytes)
				return
		# just insert it
		self.ranges[address] = bytes

	def __init__(self, path):
		self.ranges = dict()

		# read the file
		# XXX should have some file metadata here too ...
		f = open(path, "r")
		for line in f:
			self.__parseline(line)

	def code(self):
		return self.ranges
	
# Parse commandline arguments
parser = argparse.ArgumentParser(description="Reference test parser")
parser.add_argument('firmware', action="store", help="Firmware file to be parsed")
args = parser.parse_args()

# Load the firmware file, and print out a list of NSDictionary key literals
fw = firmware(args.firmware)
code = fw.code()
for address in sorted(code.keys()):
	bytes = code[address]
	print("@\"" + str(address) + "\" : @[@" + str(len(bytes)) + ", @" + str(bytes[0]) + "],")
