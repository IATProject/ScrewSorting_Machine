clear
close all

global data
global i

i = 0;
data = uint8(0);

u = udp('192.168.1.187',6790,'Localport',6789);
u.DatagramReceivedFcn = @dataReceivedCallback;
fopen(u);

%%

fwrite(u, 'Goto_80,0,120');

%%
fwrite(u, 'Goto_90,40,5') ;

pause(1)  

fwrite(u, 'EM_1');

pause(1)

fwrite(u, 'Goto_90,40,100');

pause(1)

fwrite(u, 'Goto_90,-40,100');

pause(1)

fwrite(u, 'Goto_90,-40,20');

pause(1)

fwrite(u, 'EM_0');

pause(0.5)

fwrite(u, 'Shake');

pause(1)

fwrite(u, 'Goto_90,-40,100');

pause(1)

fwrite(u, 'Light_1');

pause(2)

fwrite(u, 'Light_0');

pause(1)

fwrite(u, 'Goto_90,-40,5');

pause(1)

fwrite(u, 'EM_1');

pause(1)

fwrite(u, 'Goto_90,-40,100');

pause(1)

fwrite(u, 'Goto_0,70,100');

pause(1)

fwrite(u, 'EM_0');

pause(0.5)

fwrite(u, 'Shake');

pause(1)

fwrite(u, 'Goto_80,0,140');

%%

fwrite(u, 'Shake');

%%
fwrite(u, 'Angles_0,20,0');

%%
fwrite(u, 'EM_0');

%%
fwrite(u, 'Light_0');

%%
fwrite(u, 'CaptureImg');

%%
while true
    fwrite(u, 'Goto_80,0,10');
    pause(2)
    fwrite(u, 'Goto_80,0,100');
    pause(2)
end

%%
unicodestr = native2unicode(data, 'UTF-8');

%%

print
value = jsondecode(convertCharsToStrings(unicodestr));

%%
fclose(u);
delete(u);
clear u

function dataReceivedCallback(src, evt)

global data
global i
data = fread(src);

i = i + 1;

end
