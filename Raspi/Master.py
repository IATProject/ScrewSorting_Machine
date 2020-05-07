# !/usr/bin/env python

from UDP import UDPHandler
from Roboter import Roboter

class Master:
    
    def __init__(self):
        self.UDP = UDPHandler()
        self.Roboter = Roboter()
    
    def work(self):
        
        if self.UDP.messageReceived():
            msg = self.UDP.getMessage()
            if msg[0:4] == "Goto":
                pos = list(map(float,msg[5:].split(',')))
                print("Goto " + str(pos))
                self.Roboter.moveJ(pos[0],pos[1],pos[2])
            elif msg[0:6] == "Angles":
                ang = list(map(float,msg[7:].split(',')))
                print("Angles " + str(ang))
                self.Roboter.setAngles(ang[0],ang[1],ang[2])
                self.Roboter.writeAngles()
            elif msg[0:2] == "EM":
                status = bool(int(msg[3:4]))
                print("EM " + str(status))
                self.Roboter.setEM(status)
            elif msg[0:5] == "Light":
                status = bool(int(msg[6:7]))
                print("Light " + str(status))
                self.Roboter.setLight(status)
            elif msg[0:5] == "Shake":
                self.Roboter.shake()
            else:
                print("Invalid command")

