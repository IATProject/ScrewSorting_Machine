from picamera import PiCamera
from picamera.array import PiRGBArray
import numpy as np
import scipy.io as sio
import time


class Camera:
        
    def __init__(self):
        self.camera = PiCamera()
        self.camera.resolution = (1000, 600)
        #self.camera.quality = 100
        self.camera.exposure_compensation = 10
        self.camera.awb_mode = 'incandescent'
        self.camera.sharpness = 20
        self.camera.contrast = 100
        self.camera.saturation = 0
        #camera.rotation = 180
        self.camera_array = np.empty((1088,720,3), dtype=np.uint8)
        #self.camera_array = PiRGBArray(self.camera)
    
    
    def capture(self):
        #self.camera.start_preview()
        #self.camera_array.truncate(0)
        #self.camera.capture(self.camera_array, format="rgb")
        self.camera.capture('/share/img.jpg',quality=100)
        #time.sleep(3)
        #self.camera.stop_preview()
        
        
    #def saveImage(self):
        #print(self.camera_array.shape)
        #np.savetxt('/share/testmat1.mat',self.camera_array)
        #sio.savemat('/share/testmat.mat', {'img' : self.camera_array})
        
