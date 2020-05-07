clear;
close all;

% Get raspberry pi object
pi = raspi('192.168.1.106','pi','raspberry');

%%

% 1024x768
% 1280x720
% 1920x1080

clear picamera;

picamera = cameraboard(pi, 'Resolution', '1280x720', 'Quality', 100, 'ExposureMode', 'auto', ...
    'ExposureCompensation', 10, 'AWBMode', 'cloud', 'Sharpness', 0, 'Contrast', 20, ...
    'Saturation', 0);

%%

img = snapshot(picamera);
imshow(img);

%%
imwrite(img, 'img_'+string(i)+'.jpg');
i = i+1;

%% PWM

servo = 0;

%duty_cycle_rel = 0.05 + servo*0.05;

%duty_cycle_ms = 0.5;
duty_cycle = duty_cycle_ms / 20;

%configurePin(pi, 18, 'PWM');
writePWMDutyCycle(pi, 18, 0.01);
%writePWMFrequency(pi, 18, 1000);

%%

% showPins(pi)

clear s_base;
clear s_left;
clear s_right;

s_base = servo(pi,14,'MinPulseDuration',0.5e-3,'MaxPulseDuration',2.5e-3);
s_left = servo(pi,15,'MinPulseDuration',0.5e-3,'MaxPulseDuration',2.5e-3);
s_right = servo(pi,18,'MinPulseDuration',0.5e-3,'MaxPulseDuration',2.5e-3);

%%

writePosition(s_base,0); % 0 ... 180
writePosition(s_left,0); % 0 ... 120
writePosition(s_right,155); % 50 ... 160

%%

for i=1:50
    
    angle = 180 - (i/50)*180;
    writePosition(s_base,angle);
    pause(0.02);
end
