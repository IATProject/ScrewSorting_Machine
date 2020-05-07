# !/usr/bin/env python

import socket
import numpy as np
import json
import threading


class UDPHandler:
    
    def __init__(self):
        self.host = "192.168.1.217"
        self.port = 6789
        self.UDPSock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.buffersize = 512
        # Server
        self.portServer = 6790
        self.SockServer = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.SockServer.bind(('', self.portServer))
        self.ThreadServer = threading.Thread(target=self.dataReceived)
        self.ThreadServerRunning = True
        self.ThreadServer.start()
        self.Message = ""
           
       
    def writeImg(self, img):
        data_bytes = img.tobytes()
        self.UDPSock.sendto(data_bytes, (self.host, self.port))


    def writeDataSerialized(self, data):
        serialized = json.dumps(data)
        data_bytes = bytes(serialized, 'UTF-8')
        
        print("Packages: " + str(len(data_bytes)/self.buffersize))
        
        i = 0
        while True:  
            
            if i+self.buffersize > len(data_bytes):
                self.UDPSock.sendto(data_bytes[i:], (self.host, self.port))
                break
            else:
                self.UDPSock.sendto(data_bytes[i:i+self.buffersize], (self.host, self.port))
        
            i = i + self.buffersize


    def dataReceived(self):
        while self.ThreadServerRunning:
            data, addr = self.SockServer.recvfrom(self.buffersize)
            self.Message = data.decode("utf-8")
            # print("Msg received: " + str(data))
    
    
    def messageReceived(self):
        if self.Message == "":
            return False
        else:
            return True
    
    
    def getMessage(self):
        msg = self.Message
        self.Message = ""
        return msg

    
    def writeString(self, data):
        data_bytes = data.encode('utf-8')
        self.UDPSock.sendto(data_bytes, (self.host, self.port))


    def close(self):
        self.UDPSock.close()
        self.ThreadServerRunning = False
        #self.ThreadServer.join()

