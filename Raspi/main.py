# !/usr/bin/env python

from Master import Master
import time

import RPi.GPIO as GPIO

def main():
    
    GPIO.setmode(GPIO.BOARD)
    
    GPIO.setup(16, GPIO.IN)
    
    m = Master()
    
    if GPIO.input(16) == GPIO.HIGH:
        print("Stromlimit erreicht")
    
    while True:
        m.work()
        time.sleep(0.1)


if __name__ == "__main__":
    main()