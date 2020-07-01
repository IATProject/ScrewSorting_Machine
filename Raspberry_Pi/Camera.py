# !/usr/bin/env python

from picamera import PiCamera
from picamera.array import PiRGBArray
import numpy as np
import scipy.io as sio
import time
import os
import glob


class Camera:
        
    def __init__(self):
        self.camera = PiCamera()
        self.camera.resolution = (1000, 600)
        self.camera.exposure_compensation = 10
        self.camera.awb_mode = 'incandescent'
        self.camera.sharpness = 20
        self.camera.contrast = 100
        self.camera.saturation = 0
        self.camera_array = np.empty((1088,720,3), dtype=np.uint8)
    
    
    def capture(self,id):
        # Remove files
        files = glob.glob('/share/*')
        for f in files:
            os.remove(f)
            
        self.camera.capture('/share/img_' + str(id) + '.jpg',quality=100)
