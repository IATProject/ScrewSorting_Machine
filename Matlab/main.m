clear all
close all
% main.m

global data
data = uint8(0);

% Initialization of communication link to microcontroller
u = udp('192.168.1.187',6790,'Localport',6789);
u.DatagramReceivedFcn = @dataReceivedCallback;
fopen(u);

%%
fclose(u);
delete(u);
clear u

%%
state = "init";

while true

if state == "init"
    goto(u,80,50,100);
    waitForJobCompl(10);
    state = "getProbe";
elseif state == "getProbe"
    ClOnGoto(u,80,50,0);
    waitForJobCompl(10);
    controlEM(u,true);
    waitForJobCompl(1);
    goto(u,80,50,100);
    waitForJobCompl(1);
    goto(u,80,-50,100);
    waitForJobCompl(1);
    goto(u,80,-50,30);
    waitForJobCompl(1);
    controlEM(u,false)
    waitForJobCompl(1);
    shake(u)
    waitForJobCompl(1);
    goto(u,80,-50,140);
    waitForJobCompl(1);
    state = "processImg";
elseif state == "processImg"
    controlLight(u,true)
    waitForJobCompl(5);
    pause(3);
    captureImage(u)
    waitForJobCompl(5);
    controlLight(u,false)
    waitForJobCompl(5);
    img = imread('\\RASPBERRYPI\share\img.jpg');
    state = "exit";
elseif state == "exit"
    break
end

end

%%
goto(u,80,0,40)


%% Helper functions
function goto(u,x,y,z)
fwrite(u, "Goto_" + x + ',' + y + ',' + z);
end

function ClOnGoto(u,x,y,z)
fwrite(u, "ClOnGoto_" + x + ',' + y + ',' + z);
end

function shake(u)
fwrite(u, 'Shake');
end

function controlLight(u,on)
if on == true
    fwrite(u, 'Light_1');
else
    fwrite(u, 'Light_0');
end
end

function controlEM(u,on)
if on == true
    fwrite(u, 'EM_1');
else
    fwrite(u, 'EM_0');
end
end

function captureImage(u)
fwrite(u, 'CaptureImg');
end

function dataReceivedCallback(src, evt)
global data
data = fread(src);
end

function waitForJobCompl(tMax)
global data
tStart = clock();
while true
    if data ~= 0
        data = 0;
        break
    end
    if etime(clock,tStart) > tMax
        data = 0;
        break
    end
    pause(0.2);
end
end
