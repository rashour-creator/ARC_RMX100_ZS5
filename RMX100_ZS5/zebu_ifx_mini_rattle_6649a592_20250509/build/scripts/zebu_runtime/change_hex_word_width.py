#!/bin/env python
# Usage: [python] change_hex_word_width.py <from_width_bits> <to_width_bits> <xmem_base_addr_hex> <inputhex_file>
import sys
import re

# Get inputs
from_width_bits = int(sys.argv[1])
to_width_bits   = int(sys.argv[2])
base_addr       = int(sys.argv[3].replace('_',''),16)
input_file      = sys.argv[4]

# Internal variables
width_ratio = to_width_bits//from_width_bits
new_line    = []
header_re   = re.compile('// (0x[0-9A-Fa-f]+)')

def print_word():
  global new_line
  if new_line != []:
    while (len(new_line) != width_ratio): # Handle incomplete lines
      new_line.append('00'*(from_width_bits//8))
    print("".join(new_line[::-1]))
    new_line = []

with open(input_file, 'r') as f:
  for line in f:
    if line.startswith("//"): # Keep comments
      print_word() # flush first
      match = header_re.match(line)
      if (match): line = line.strip() + " -> " + "0x{0:X}".format(int(match.group(1),16)-base_addr) # substract base address
      print(line.strip())
    elif line.startswith("@"): # Address tags must be converted from 'from_width_bits' to 'to_width_bits' address
      print_word() # flush first
      print("@{0:X}".format((int(line[1:],16)-base_addr)//width_ratio)) # TODO: check for negative addresses?
    else: # Accumulate data and form words of w_width
      s = line.strip().replace("_","").split()[::-1]
      while (len(s) != 0):
        new_line.append(s.pop())
        if (len(new_line) == width_ratio): print_word()
  print_word() # end flush
