clear;
close all;

% Get raspberry pi object
mypi = raspi('192.168.1.2','pi','raspberry');

%%

% 1024x768
% 1280x720
% 1920x1080

clear picamera;

picamera = cameraboard(mypi, 'Resolution', '1280x720', 'Quality', 100, 'ExposureMode', 'auto', ...
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
writePWMDutyCycle(mypi, 18, 0.01);
%writePWMFrequency(pi, 18, 1000);

%%

% showPins(pi)

clear s_alpha;
clear s_gamma;
clear s_beta;

s_alpha = servo(mypi,14,'MinPulseDuration',0.5e-3,'MaxPulseDuration',2.5e-3);
s_gamma = servo(mypi,15,'MinPulseDuration',0.5e-3,'MaxPulseDuration',2.5e-3);
s_beta = servo(mypi,18,'MinPulseDuration',0.5e-3,'MaxPulseDuration',2.5e-3);

configurePin(mypi,23,'DigitalOutput');

%%

writeDigitalPin(mypi,23,0);
%%

writePosition(s_alpha,90); % 0 ... 180
writePosition(s_beta,90); % 50 ... 160
writePosition(s_gamma,90); % 0 ... 120

%%

for i=1:50
    
    angle = 180 - (i/50)*180;
    writePosition(s_alpha,angle);
    pause(0.02);
end
