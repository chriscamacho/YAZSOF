#!/usr/bin/env python3
import serial
import time
import sys

if len(sys.argv) != 2:
    print('Please specify a Intel hex file to upload.')
    sys.exit(1)



f = open(sys.argv[1], 'r')
print(sys.argv[1])
ser = serial.Serial('/dev/ttyUSB0', 12500, timeout=1)  # open serial port

n=0
for line in f.readlines():
    result=''
    fails=0
    while result!=b'OK\n':
        print(n,' ',line[4:8],end='')
        ser.write(line.encode())
        result = ser.readline()
        print(' ',result.decode(),end='')
        if fails>3:
            print("too many errors bailing!")
            sys.exit(2)
        fails+=1
    n+=1
print()
f.close()
ser.close()             # close port
sys.exit(0)
