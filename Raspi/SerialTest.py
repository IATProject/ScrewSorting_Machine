import serial
import math
import numpy as np
from time import sleep
import time

A = np.zeros((100,100,3), np.uint8)

A[1,1,0] = 255

print(A[1,1,:])

print(A.size)

#quit()

ser = serial.Serial("/dev/ttyAMA0", 115200)

sDemo = "Img\n10\n10\n"

pixel = A[1,1,:]

b = sDemo.encode('utf-8')
ser.write(b)

t = time.time()

for x in range(0, 100):
    for y in range(0, A.shape[1]):
        #sleep(0.01)
        #ser.write(A[x*10:(x+1)*10,y,:])
        ser.write(A[x,y,:])

elapsed = time.time() - t
print(elapsed)