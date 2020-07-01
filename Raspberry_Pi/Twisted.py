# !/usr/bin/env python

from twisted.internet import protocol, reactor
from Roboter import Roboter
from Camera import Camera
from subprocess import call

class ServerProtocol(protocol.Protocol):
    Roboter = Roboter()
    Camera = Camera()

    def dataReceived(self,data):
        msg = data.decode("utf-8")
        
        if msg[0:7] == "moveJCl":
            pos = list(map(float,msg[8:].split(',')))
            print("moveJCl " + str(pos))
            self.Roboter.moveJ(pos[0],pos[1],pos[2],True)
        elif msg[0:5] == "moveJ":
            pos = list(map(float,msg[6:].split(',')))
            print("moveJ " + str(pos))
            self.Roboter.moveJ(pos[0],pos[1],pos[2],False)
        elif msg[0:7] == "moveLCl":
            pos = list(map(float,msg[8:].split(',')))
            print("moveL " + str(pos))
            self.Roboter.moveL(pos[0],pos[1],pos[2],True)
        elif msg[0:5] == "moveL":
            pos = list(map(float,msg[6:].split(',')))
            print("moveL " + str(pos))
            self.Roboter.moveL(pos[0],pos[1],pos[2],False)
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
        elif msg[0:5] == "shake":
            print("shake")
            self.Roboter.shake()
        elif msg[0:10] == "captureImg":
            id = int(msg[11:])
            print("capture image")
            self.Camera.capture(id)
        elif msg[0:8] == "shutdown":
            print("Shutdowm")
            call("sudo poweroff", shell=True)
        else:
            print("Invalid command")
        
        msg = "done"
        self.transport.write(msg.encode('utf-8'))
        
factory = protocol.ServerFactory()
factory.protocol = ServerProtocol
reactor.listenTCP(3000,factory)
reactor.run()

    