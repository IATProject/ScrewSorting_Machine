# !/usr/bin/env python

import pigpio
import time
import math
from math import sin, cos, acos, sqrt, atan2, copysign
import RPi.GPIO as GPIO


class Roboter:
    
    def __init__(self):
        self.pi = pigpio.pi()
        self.alpha = 0
        self.beta = 0
        self.gamma = 90
        self.steps = 100
        self.tSleep = 0.003
        self.lightOn = False
        self.EMOn = False
        self.deltaAngleMin = 1
        self.shakeLevel = 10
        GPIO.setmode(GPIO.BOARD)
        GPIO.setup(18, GPIO.OUT) # light
        GPIO.setup(22, GPIO.OUT) # electro magnet
        GPIO.output(18, GPIO.HIGH)
        GPIO.output(22, GPIO.LOW)
    
    
    def setLight(self, on):
        if on == True:
            GPIO.output(18, GPIO.LOW)
        else:
            GPIO.output(18, GPIO.HIGH)


    def setEM(self, on):
        if on == True:
            GPIO.output(22, GPIO.HIGH)
        else:
            GPIO.output(22, GPIO.LOW)

        
    def moveJ(self,x,y,z):
        [alphaSoll, betaSoll, gammaSoll] = self.xyz2abg(x,y,z)
        
        alphaErreicht = False
        betaErreicht = False
        gammaErreicht = False
        
        deltaAlpha = (alphaSoll - self.alpha)/self.steps
        deltaBeta = (betaSoll - self.beta)/self.steps
        deltaGamma = (gammaSoll - self.gamma)/self.steps
        
        while (not alphaErreicht or not betaErreicht or not gammaErreicht):
            
            if abs(alphaSoll-self.alpha) <= self.deltaAngleMin:
                self.alpha = alphaSoll
                alphaErreicht = True
            elif abs(alphaSoll-self.alpha) <= abs(2*deltaAlpha):
                self.alpha = alphaSoll
                alphaErreicht = True
            else:
                self.alpha = self.alpha + deltaAlpha
            
            if abs(betaSoll-self.beta) <= self.deltaAngleMin:
                self.beta = betaSoll
                betaErreicht = True
            elif abs(betaSoll-self.beta) <= abs(deltaBeta):
                self.beta = betaSoll
                betaErreicht = True
            else:
                self.beta = self.beta + deltaBeta
            
            if abs(gammaSoll-self.gamma) <= self.deltaAngleMin:
                self.gamma = gammaSoll
                gammaErreicht = True
            elif abs(gammaSoll-self.gamma) <= abs(deltaGamma):
                self.gamma = gammaSoll
                gammaErreicht = True
            else:
                self.gamma = self.gamma + deltaGamma
            
            time.sleep(self.tSleep)
            
            self.writeAngles()
        
    
    def writePosition(self,x,y,z):
        [self.alpha, self.beta, self.gamma] = self.xyz2abg(x,y,z)
        self.writeAngles()
    
    def shake(self):
        [xOld,yOld,zOld] = self.abg2xyz()
        self.writePosition(xOld,yOld,zOld+self.shakeLevel)
        time.sleep(0.1)
        self.writePosition(xOld,yOld,zOld)
        time.sleep(0.1)
        self.writePosition(xOld,yOld,zOld+self.shakeLevel)
        time.sleep(0.1)
        self.writePosition(xOld,yOld,zOld)
    
    
    def setAngles(self,alpha,beta,gamma):
        self.alpha = alpha
        self.beta = beta
        self.gamma = gamma
    
    
    def writeAngles(self):        
        alpha_min = -77
        alpha_max = 103
        
        beta_min = -35
        beta_max = 145
        
        gamma_min = -62
        gamma_max = 118
        
        if self.alpha > alpha_max:
            alpha = alpha_max
            print("Alpha max reached")
        elif self.alpha < alpha_min:
            alpha = alpha_min
            print("Alpha min reached")
        else:
            alpha = self.alpha
        
        if self.beta > beta_max:
            beta = beta_max
            print("Beta max reached")
        elif self.beta < beta_min:
            beta = beta_min
            print("Beta min reached")
        else:
            beta = self.beta
            
        if self.gamma > gamma_max:
            gamma = gamma_max
            print("Gamma max reached")
        elif self.gamma < gamma_min:
            gamma = gamma_min
            print("Gamma min reached")
        else:
            gamma = self.gamma
        
        alpha_us = 500 + (alpha+77)/180*2000
        beta_us = 500 + (beta+35)/180*2000
        gamma_us = 500 + (gamma+62)/180*2000
        #gamma_us = 500 + (gamma*100/90+52)/180*2000
        
        # 500us ... 2500us
        self.pi.set_servo_pulsewidth(14, alpha_us)
        self.pi.set_servo_pulsewidth(15, beta_us)
        self.pi.set_servo_pulsewidth(18, gamma_us)


    def xyz2xza(self,x,y,z):
        z_ = z
        r = (x**2 + y**2 + z**2)**(1/2)

        if(r==0):
            x_ = 0
        else:
            if (z/r > 1):
                x_ = 0
            else:
                x_ = r*sin(acos(z/r))
           
        if(x==0 and y==0):
            alpha = 0
        else:
            if x/x_ > 1:
                alpha = 0
            else:
                alpha = acos(x/x_)*copysign(1,y)

        return [x_, z_, alpha]
    
    
    def abg2xyz(self):
        alpha_ = self.alpha/180*math.pi
        beta_ = self.beta/180*math.pi
        gamma_ = self.gamma/180*math.pi
        
        z0 = 58
        l1 = 80
        l2 = 80
        
        x_ = l1*sin(beta_) + l2*sin(gamma_)
        z_ = l1*cos(beta_) - l2*cos(gamma_)
        
        x = x_*cos(alpha_)
        y = x_*sin(alpha_)
        z = z_ + z0
        
        return [x, y, z]

    
    def xyz2abg(self,x,y,z):

        [x_, z_, alpha] = self.xyz2xza(x,y,z)

        z0 = 58
        l1 = 80
        l2 = 80

        # Avoid singularity
        delta = 0.001
        if z_ > z0-delta and z_< z0+delta:
            z_ = z0+delta

        if(z<58):
            beta = atan2((z0**2*x_ - 2*z0*x_*z_ + l1**2*x_ - l2**2*x_ + x_**3 + x_*z_**2 + sqrt(-z0**6 + 6*z0**5*z_ + 2*z0**4*l1**2 + 2*z0**4*l2**2 - 2*z0**4*x_**2 - 15*z0**4*z_**2 - 8*z0**3*l1**2*z_ - 8*z0**3*l2**2*z_ + 8*z0**3*x_**2*z_ + 20*z0**3*z_**3 - z0**2*l1**4 + 2*z0**2*l1**2*l2**2 + 2*z0**2*l1**2*x_**2 + 12*z0**2*l1**2*z_**2 - z0**2*l2**4 + 2*z0**2*l2**2*x_**2 + 12*z0**2*l2**2*z_**2 - z0**2*x_**4 - 12*z0**2*x_**2*z_**2 - 15*z0**2*z_**4 + 2*z0*l1**4*z_ - 4*z0*l1**2*l2**2*z_ - 4*z0*l1**2*x_**2*z_ - 8*z0*l1**2*z_**3 + 2*z0*l2**4*z_ - 4*z0*l2**2*x_**2*z_ - 8*z0*l2**2*z_**3 + 2*z0*x_**4*z_ + 8*z0*x_**2*z_**3 + 6*z0*z_**5 - l1**4*z_**2 + 2*l1**2*l2**2*z_**2 + 2*l1**2*x_**2*z_**2 + 2*l1**2*z_**4 - l2**4*z_**2 + 2*l2**2*x_**2*z_**2 + 2*l2**2*z_**4 - x_**4*z_**2 - 2*x_**2*z_**4 - z_**6))/(z0**2 - 2*z0*z_ + x_**2 + z_**2), (x_*(z0**2*x_ - 2*z0*x_*z_ + l1**2*x_ - l2**2*x_ + x_**3 + x_*z_**2 + sqrt(-z0**6 + 6*z0**5*z_ + 2*z0**4*l1**2 + 2*z0**4*l2**2 - 2*z0**4*x_**2 - 15*z0**4*z_**2 - 8*z0**3*l1**2*z_ - 8*z0**3*l2**2*z_ + 8*z0**3*x_**2*z_ + 20*z0**3*z_**3 - z0**2*l1**4 + 2*z0**2*l1**2*l2**2 + 2*z0**2*l1**2*x_**2 + 12*z0**2*l1**2*z_**2 - z0**2*l2**4 + 2*z0**2*l2**2*x_**2 + 12*z0**2*l2**2*z_**2 - z0**2*x_**4 - 12*z0**2*x_**2*z_**2 - 15*z0**2*z_**4 + 2*z0*l1**4*z_ - 4*z0*l1**2*l2**2*z_ - 4*z0*l1**2*x_**2*z_ - 8*z0*l1**2*z_**3 + 2*z0*l2**4*z_ - 4*z0*l2**2*x_**2*z_ - 8*z0*l2**2*z_**3 + 2*z0*x_**4*z_ + 8*z0*x_**2*z_**3 + 6*z0*z_**5 - l1**4*z_**2 + 2*l1**2*l2**2*z_**2 + 2*l1**2*x_**2*z_**2 + 2*l1**2*z_**4 - l2**4*z_**2 + 2*l2**2*x_**2*z_**2 + 2*l2**2*z_**4 - x_**4*z_**2 - 2*x_**2*z_**4 - z_**6))/(z0**2 - 2*z0*z_ + x_**2 + z_**2) - z0**2 + 2*z0*z_ - l1**2 + l2**2 - x_**2 - z_**2)/(z0 - z_))
            gamma = atan2(-(z0**2*x_ - 2*z0*x_*z_ + l1**2*x_ - l2**2*x_ + x_**3 + x_*z_**2 + sqrt(-z0**6 + 6*z0**5*z_ + 2*z0**4*l1**2 + 2*z0**4*l2**2 - 2*z0**4*x_**2 - 15*z0**4*z_**2 - 8*z0**3*l1**2*z_ - 8*z0**3*l2**2*z_ + 8*z0**3*x_**2*z_ + 20*z0**3*z_**3 - z0**2*l1**4 + 2*z0**2*l1**2*l2**2 + 2*z0**2*l1**2*x_**2 + 12*z0**2*l1**2*z_**2 - z0**2*l2**4 + 2*z0**2*l2**2*x_**2 + 12*z0**2*l2**2*z_**2 - z0**2*x_**4 - 12*z0**2*x_**2*z_**2 - 15*z0**2*z_**4 + 2*z0*l1**4*z_ - 4*z0*l1**2*l2**2*z_ - 4*z0*l1**2*x_**2*z_ - 8*z0*l1**2*z_**3 + 2*z0*l2**4*z_ - 4*z0*l2**2*x_**2*z_ - 8*z0*l2**2*z_**3 + 2*z0*x_**4*z_ + 8*z0*x_**2*z_**3 + 6*z0*z_**5 - l1**4*z_**2 + 2*l1**2*l2**2*z_**2 + 2*l1**2*x_**2*z_**2 + 2*l1**2*z_**4 - l2**4*z_**2 + 2*l2**2*x_**2*z_**2 + 2*l2**2*z_**4 - x_**4*z_**2 - 2*x_**2*z_**4 - z_**6))/(2*(z0**2 - 2*z0*z_ + x_**2 + z_**2)) + x_, (x_*(z0**2*x_ - 2*z0*x_*z_ + l1**2*x_ - l2**2*x_ + x_**3 + x_*z_**2 + sqrt(-z0**6 + 6*z0**5*z_ + 2*z0**4*l1**2 + 2*z0**4*l2**2 - 2*z0**4*x_**2 - 15*z0**4*z_**2 - 8*z0**3*l1**2*z_ - 8*z0**3*l2**2*z_ + 8*z0**3*x_**2*z_ + 20*z0**3*z_**3 - z0**2*l1**4 + 2*z0**2*l1**2*l2**2 + 2*z0**2*l1**2*x_**2 + 12*z0**2*l1**2*z_**2 - z0**2*l2**4 + 2*z0**2*l2**2*x_**2 + 12*z0**2*l2**2*z_**2 - z0**2*x_**4 - 12*z0**2*x_**2*z_**2 - 15*z0**2*z_**4 + 2*z0*l1**4*z_ - 4*z0*l1**2*l2**2*z_ - 4*z0*l1**2*x_**2*z_ - 8*z0*l1**2*z_**3 + 2*z0*l2**4*z_ - 4*z0*l2**2*x_**2*z_ - 8*z0*l2**2*z_**3 + 2*z0*x_**4*z_ + 8*z0*x_**2*z_**3 + 6*z0*z_**5 - l1**4*z_**2 + 2*l1**2*l2**2*z_**2 + 2*l1**2*x_**2*z_**2 + 2*l1**2*z_**4 - l2**4*z_**2 + 2*l2**2*x_**2*z_**2 + 2*l2**2*z_**4 - x_**4*z_**2 - 2*x_**2*z_**4 - z_**6))/(z0**2 - 2*z0*z_ + x_**2 + z_**2) + z0**2 - 2*z0*z_ - l1**2 + l2**2 - x_**2 + z_**2)/(2*(z0 - z_)))
        else:
            beta = atan2(-(-z0**2*x_ + 2*z0*x_*z_ - l1**2*x_ + l2**2*x_ - x_**3 - x_*z_**2 + sqrt(-z0**6 + 6*z0**5*z_ + 2*z0**4*l1**2 + 2*z0**4*l2**2 - 2*z0**4*x_**2 - 15*z0**4*z_**2 - 8*z0**3*l1**2*z_ - 8*z0**3*l2**2*z_ + 8*z0**3*x_**2*z_ + 20*z0**3*z_**3 - z0**2*l1**4 + 2*z0**2*l1**2*l2**2 + 2*z0**2*l1**2*x_**2 + 12*z0**2*l1**2*z_**2 - z0**2*l2**4 + 2*z0**2*l2**2*x_**2 + 12*z0**2*l2**2*z_**2 - z0**2*x_**4 - 12*z0**2*x_**2*z_**2 - 15*z0**2*z_**4 + 2*z0*l1**4*z_ - 4*z0*l1**2*l2**2*z_ - 4*z0*l1**2*x_**2*z_ - 8*z0*l1**2*z_**3 + 2*z0*l2**4*z_ - 4*z0*l2**2*x_**2*z_ - 8*z0*l2**2*z_**3 + 2*z0*x_**4*z_ + 8*z0*x_**2*z_**3 + 6*z0*z_**5 - l1**4*z_**2 + 2*l1**2*l2**2*z_**2 + 2*l1**2*x_**2*z_**2 + 2*l1**2*z_**4 - l2**4*z_**2 + 2*l2**2*x_**2*z_**2 + 2*l2**2*z_**4 - x_**4*z_**2 - 2*x_**2*z_**4 - z_**6))/(2*(z0**2 - 2*z0*z_ + x_**2 + z_**2)), (-x_*(-z0**2*x_ + 2*z0*x_*z_ - l1**2*x_ + l2**2*x_ - x_**3 - x_*z_**2 + sqrt(-z0**6 + 6*z0**5*z_ + 2*z0**4*l1**2 + 2*z0**4*l2**2 - 2*z0**4*x_**2 - 15*z0**4*z_**2 - 8*z0**3*l1**2*z_ - 8*z0**3*l2**2*z_ + 8*z0**3*x_**2*z_ + 20*z0**3*z_**3 - z0**2*l1**4 + 2*z0**2*l1**2*l2**2 + 2*z0**2*l1**2*x_**2 + 12*z0**2*l1**2*z_**2 - z0**2*l2**4 + 2*z0**2*l2**2*x_**2 + 12*z0**2*l2**2*z_**2 - z0**2*x_**4 - 12*z0**2*x_**2*z_**2 - 15*z0**2*z_**4 + 2*z0*l1**4*z_ - 4*z0*l1**2*l2**2*z_ - 4*z0*l1**2*x_**2*z_ - 8*z0*l1**2*z_**3 + 2*z0*l2**4*z_ - 4*z0*l2**2*x_**2*z_ - 8*z0*l2**2*z_**3 + 2*z0*x_**4*z_ + 8*z0*x_**2*z_**3 + 6*z0*z_**5 - l1**4*z_**2 + 2*l1**2*l2**2*z_**2 + 2*l1**2*x_**2*z_**2 + 2*l1**2*z_**4 - l2**4*z_**2 + 2*l2**2*x_**2*z_**2 + 2*l2**2*z_**4 - x_**4*z_**2 - 2*x_**2*z_**4 - z_**6))/(z0**2 - 2*z0*z_ + x_**2 + z_**2) - z0**2 + 2*z0*z_ - l1**2 + l2**2 - x_**2 - z_**2)/(2*(z0 - z_)))
            gamma = atan2((-z0**2*x_ + 2*z0*x_*z_ - l1**2*x_ + l2**2*x_ - x_**3 - x_*z_**2 + sqrt(-z0**6 + 6*z0**5*z_ + 2*z0**4*l1**2 + 2*z0**4*l2**2 - 2*z0**4*x_**2 - 15*z0**4*z_**2 - 8*z0**3*l1**2*z_ - 8*z0**3*l2**2*z_ + 8*z0**3*x_**2*z_ + 20*z0**3*z_**3 - z0**2*l1**4 + 2*z0**2*l1**2*l2**2 + 2*z0**2*l1**2*x_**2 + 12*z0**2*l1**2*z_**2 - z0**2*l2**4 + 2*z0**2*l2**2*x_**2 + 12*z0**2*l2**2*z_**2 - z0**2*x_**4 - 12*z0**2*x_**2*z_**2 - 15*z0**2*z_**4 + 2*z0*l1**4*z_ - 4*z0*l1**2*l2**2*z_ - 4*z0*l1**2*x_**2*z_ - 8*z0*l1**2*z_**3 + 2*z0*l2**4*z_ - 4*z0*l2**2*x_**2*z_ - 8*z0*l2**2*z_**3 + 2*z0*x_**4*z_ + 8*z0*x_**2*z_**3 + 6*z0*z_**5 - l1**4*z_**2 + 2*l1**2*l2**2*z_**2 + 2*l1**2*x_**2*z_**2 + 2*l1**2*z_**4 - l2**4*z_**2 + 2*l2**2*x_**2*z_**2 + 2*l2**2*z_**4 - x_**4*z_**2 - 2*x_**2*z_**4 - z_**6))/(2*(z0**2 - 2*z0*z_ + x_**2 + z_**2)) + x_, (-x_*(-z0**2*x_ + 2*z0*x_*z_ - l1**2*x_ + l2**2*x_ - x_**3 - x_*z_**2 + sqrt(-z0**6 + 6*z0**5*z_ + 2*z0**4*l1**2 + 2*z0**4*l2**2 - 2*z0**4*x_**2 - 15*z0**4*z_**2 - 8*z0**3*l1**2*z_ - 8*z0**3*l2**2*z_ + 8*z0**3*x_**2*z_ + 20*z0**3*z_**3 - z0**2*l1**4 + 2*z0**2*l1**2*l2**2 + 2*z0**2*l1**2*x_**2 + 12*z0**2*l1**2*z_**2 - z0**2*l2**4 + 2*z0**2*l2**2*x_**2 + 12*z0**2*l2**2*z_**2 - z0**2*x_**4 - 12*z0**2*x_**2*z_**2 - 15*z0**2*z_**4 + 2*z0*l1**4*z_ - 4*z0*l1**2*l2**2*z_ - 4*z0*l1**2*x_**2*z_ - 8*z0*l1**2*z_**3 + 2*z0*l2**4*z_ - 4*z0*l2**2*x_**2*z_ - 8*z0*l2**2*z_**3 + 2*z0*x_**4*z_ + 8*z0*x_**2*z_**3 + 6*z0*z_**5 - l1**4*z_**2 + 2*l1**2*l2**2*z_**2 + 2*l1**2*x_**2*z_**2 + 2*l1**2*z_**4 - l2**4*z_**2 + 2*l2**2*x_**2*z_**2 + 2*l2**2*z_**4 - x_**4*z_**2 - 2*x_**2*z_**4 - z_**6))/(z0**2 - 2*z0*z_ + x_**2 + z_**2) + z0**2 - 2*z0*z_ - l1**2 + l2**2 - x_**2 + z_**2)/(2*(z0 - z_)))
        
        alpha = alpha.real*180/math.pi
        beta = beta.real*180/math.pi
        gamma = gamma.real*180/math.pi
        
        return [alpha, beta, gamma]
