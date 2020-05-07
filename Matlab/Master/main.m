clear all
close all
% main.m

%%
global tClient
tClient = tcpclient('192.168.1.187', 3000);

%% -------- TRAIN DEEP LEARNING NETWORK --------
% CNN for classifying elements
CNN = load('trained_net.mat');
detector = CNN.trained_net;

% % YOLO for classifying elements
% % Load pretrained YOLO detector 
% detector = load('detector.mat');


%% -------- CALIBRATION --------
% needs to be done once (for a specific setup (camera position))

% Read RGB image (full resolution)
%coin_rgb = imread('images/Testimages_2/coin/img_0.jpg');

% cal_obj_size ... mm
cal_obj_size = 21.25;       %referenz size: 5 Cent coin

% scale ... mm/pixel
%scale = calc_scale(coin_rgb, cal_obj_size);
scale = 0.14676;            %have to be very precicly, error 5px ~ 0.32mm

%%
state = "init";

while true

if state == "init"
    goto(80,50,100);
    waitForJobCompl();
    state = "getProbe";
elseif state == "getProbe"
    ClOnGoto(80,50,0);
    waitForJobCompl();
    controlEM(true);
    waitForJobCompl();
    goto(80,50,100);
    waitForJobCompl();
    goto(80,-50,100);
    waitForJobCompl();
    goto(80,-50,30);
    waitForJobCompl();
    controlEM(false)
    waitForJobCompl();
    shake()
    waitForJobCompl();
    goto(80,-50,140);
    waitForJobCompl();
    state = "processImg";
elseif state == "processImg"
    controlLight(true)
    waitForJobCompl();
    pause(3);
    captureImage()
    waitForJobCompl();
    controlLight(false)
    waitForJobCompl();
    img_rgb = imread('\\RASPBERRYPI\share\img.jpg');
    elements = detect_element(img_rgb,detector,scale);
    gp = elements(1).grasp_point;
    [x,y,z] = cam2roboter(gp(1), gp(2));
    goto(x,y,100);
    waitForJobCompl();
    ClOnGoto(x,y,z);
    waitForJobCompl();
    controlEM(true);
    waitForJobCompl();
    goto(80,-50,100);
    waitForJobCompl();
    goto(-5,70,100);
    waitForJobCompl();
    controlEM(false)
    waitForJobCompl();
    shake();
    waitForJobCompl();
    goto(80,50,100);
    waitForJobCompl();
    state = "exit";
elseif state == "exit"
    break
end
end

close all

%%
%i = 0;
controlLight(false);

%%
captureImage();
pause(1);
thisFileName = '\\RASPBERRYPI\share\img.jpg';
copyfile(thisFileName, 'testimages\img_' + string(i) + '.jpg');
i = i + 1;

%%
controlEM(false);

%%
goto(80,0,120);
%writeAngles(-40,0,90);
%captureImage();

%% Helper functions
function writeAngles(a,b,g)
global tClient
write(tClient, uint8(char("Angles_" + a + ',' + b + ',' + g)));
end

function [x,y,z] = cam2roboter(gp_x,gp_y)
x = 35+60*gp_y/300;
y = -95+190*gp_x/1000;
z = 0;
end

function goto(x,y,z)
global tClient
write(tClient, uint8(char("Goto_" + x + ',' + y + ',' + z)));
end

function ClOnGoto(x,y,z)
global tClient
write(tClient, uint8(char("ClOnGoto_" + x + ',' + y + ',' + z)));
end

function shake()
global tClient
write(tClient, uint8('Shake'));
end

function controlLight(on)
global tClient
if on == true
    write(tClient, uint8('Light_1'));
else
    write(tClient, uint8('Light_0'));
end
end

function controlEM(on)
global tClient
if on == true
    write(tClient, uint8('EM_1'));
else
   	write(tClient, uint8('EM_0'));
end
end

function captureImage()
global tClient
write(tClient, uint8('CaptureImg'));
end

function waitForJobCompl()
global tClient
tMax = 10;
tStart = clock();
while true
    data = read(tClient);
    data = string(char(data));
    if data ~= ""
        %disp(data)
        break
    end
    if etime(clock,tStart) > tMax
        break
    end
    pause(0.1);
end
end


