from picamera import PiCamera
from picamera.array import PiRGBArray
import numpy as np

class Camera:
        
    def __init__(self):
        self.camera = PiCamera()
        self.camera.resolution = (1088, 720)
        #camera.rotation = 180
        self.camera_array = PiRGBArray(camera)
    
    
    def capture(self):
        self.camera_array.truncate(0)
        self.camera.capture(self.camera_array, format="bgr")
        
    def saveImage(self):
        