clear
close all

% instrhwinfo('Bluetooth')

b = Bluetooth('raspberrypi',1);

fopen(b);
%%
% fwrite(b,uint8([2,0,1,155]));

[A,count,msg] = fread(b);

fclose(b);

delete(b)
clear bver