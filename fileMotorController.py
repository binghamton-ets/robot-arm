'''

FILE MOTOR CONTROLLER

This controller issues Armcode commands from a file and interfaces with
the arm motor control hardware via a USB serial port.

'''

import serial
import time

# Open serial port and wait
s = serial.Serial('/dev/cu.usbmodem1411', 9600)
while s.inWaiting() == 0:
    time.sleep(0.1)
print "> %s" % s.readline().strip()

# Begin executing commands
with open('test.armcode') as f:
    for line in f:
        if line == '\n' or line[0] == '#':
            continue
        s.write(line)
        print line.strip()
        while s.inWaiting() == 0:
            time.sleep(0.1)
        print "> %s" % s.readline().strip()

# Close the serial port
s.close()
