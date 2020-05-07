% serialportlist

s = serialport("/dev/cu.SLAB_USBtoUART",115200);

%%

data = readline(s);

%%

write(s,512,"uint8");

%%
while 1
    for i=0:8
        
        write(s,2^i,"uint8");

        pause(1/10);

    end

    for i=0:8

        write(s,2^(8-i),"uint8");

        pause(1/10);

    end
end