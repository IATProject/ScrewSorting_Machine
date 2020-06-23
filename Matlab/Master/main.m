clear all
close all

%%
global tClient
tClient = tcpclient('192.168.1.243', 3000);

%% -------- TRAIN DEEP LEARNING NETWORK --------
% CNN for classifying elements
% CNN = load('trained_net.mat');
% detector.CNN = CNN.trained_net;

% YOLO for classifying elements
% Load pretrained YOLO detector
detector.YOLO = load('detector.mat');


%% -------- CALIBRATION --------
% needs to be done once (for a specific setup (camera position))

% Read RGB image (full resolution)
%coin_rgb = imread('scale_img/img.jpg');

% cal_obj_size ... mm
cal_obj_size = 21.25;       %referenz size: 5 Cent coin

% scale ... mm/pixel
%scale = calc_scale(coin_rgb, cal_obj_size);
scale = 0.1911;            %have to be very precicly, error 5px ~ 0.32mm

%%
state = "init";
repeateProcess = false;

while true
    
    if state == "init"
        moveL(80,50,140,false);
        controlLight(true);
        pause(2);
        state = "getProbe";
    elseif state == "getProbe"
        moveL(80,50,140,false);
        captureImage();
        gp = getGraspingPointRight();
        if gp(1) == -1
            state = "exit";
            continue;
        end
        [x,y,z] = cam2roboterRight(gp(1),gp(2));
        moveL(x,y,50,false);
        moveL(x,y,0,true);
        controlEM(true);
        moveL(x,y,50,false);
        moveL(80,-40,50,false);
        controlEM(false);
        moveL(80,-90,20,false);
        moveL(90,-120,20,false); % End Position for dropping
        moveL(80,-40,140,false);
        state = "processImg";
    elseif state == "processImg"
        repeateProcess = false;
        captureImage();
        img_rgb = getImageLeft();
        elements = detect_element(img_rgb,detector,scale);
        displayDetectedElements(img_rgb,elements);
        
        for i=1:length(elements)
            type = string(elements{1,i}.type);
            if isequal('screw',type)
                gp = elements{1,i}.grasp_point;
                [x,y,z] = cam2roboter(gp(1), gp(2));
                moveL(x,y,50,false);
                moveL(x,y,z,true);
                controlEM(true);
                moveL(x,y,100,false);
                moveL(0,-100,100,false);
                moveL(0,-100,60,false);
                controlEM(false);
                moveL(0,-100,38,false);
                moveL(0,-50,38,false);
                moveL(0,-50,100,false);;
                moveJ(70,0,100,false)
            elseif isequal('nut',type)
                gp = elements{1,i}.grasp_point;
                [x,y,z] = cam2roboter(gp(1), gp(2));
                moveL(x,y,50,false);
                moveL(x,y,z,true);
                controlEM(true);
                moveL(x,y,100,false);
                moveJ(15,80,100,false);
                moveL(15,80,53,false);
                controlEM(false);
                moveL(15,40,53,false);
                moveL(15,40,100,false);
                moveJ(70,0,100,false)
            elseif isequal('washer',type)
                gp = elements{1,i}.grasp_point;
                [x,y,z] = cam2roboter(gp(1), gp(2));
                moveL(x,y,50,false);
                moveL(x,y,z,true);
                controlEM(true);
                moveL(x,y,100,false);
                moveJ(-10,80,100,false);
                moveL(-10,80,53,false);
                controlEM(false);
                moveL(-10,40,53,false);
                moveL(-10,40,100,false);
                moveJ(70,0,100,false)
            elseif isequal('anything',type)
                gp = elements{1,i}.grasp_point;
                [x,y,z] = cam2roboter(gp(1), gp(2));
                moveL(x,y,50,false);
                moveL(x,y,z,true);
                controlEM(true);
                moveL(80,-40,70,false);
                controlEM(false);
                moveL(80,-90,20,false);
                moveL(90,-120,20,false); % End Position for dropping
                moveL(80,-40,140,false);
                repeateProcess = true;
                %elseif isequal('nothing',type)
            end
        end
        if repeateProcess == true
            moveL(80,-40,140,false);
            state = "processImg";
        else
            state = "getProbe";
        end
    elseif state == "exit"
        break
    end
end

controlLight(false);

%%
global tClient
tClient = tcpclient('192.168.1.243', 3000);

%%
writeAngles(0,0,90);
controlEM(false);
%pause(10);
%controlEM(false);

%%
controlLight(true);
pause(4);
captureImage();
controlLight(false)


%%
img_rgb = getImageRight();
imshow(img_rgb);

%%
gp = getGraspingPointRight();
%img_bw = rgb2gray(img_rgb);
%imshow(img_bw);

%% Helper functions
function id = getId(newId)
persistent persistent_id;
if isempty(persistent_id)
    persistent_id = 0;
end
if newId
    if persistent_id >= 9
        persistent_id = 0;
    else
        persistent_id = persistent_id + 1;
    end
end
id = persistent_id;
end

function captureImage()
global tClient
write(tClient, uint8(char("captureImg_" + getId(true))));
waitForJobCompl();
end

function img_rgb = getImage()
filename = '\\RASPBERRYPI\share\img_' + string(getId(false)) + '.jpg';

cnt = 0;
fileExists = false;
while true
   if isfile(filename)
       fileExists = true;
       break;
   else
       pause(0.1);
   end
   cnt = cnt + 1;
   if cnt >= 10*5 
       break;
   end
end

if ~fileExists
    error('No image on server');
end

img_rgb = imread(filename);
end

function img_rgb = getImageRight()
img_rgb = getImage();

X = [645;976;998;648];
Y = [93;90;563;566];

x=[1;350;350;1];
y=[1;1;480;480];

A=zeros(8,8);
A(1,:)=[X(1),Y(1),1,0,0,0,-1*X(1)*x(1),-1*Y(1)*x(1)];
A(2,:)=[0,0,0,X(1),Y(1),1,-1*X(1)*y(1),-1*Y(1)*y(1)];

A(3,:)=[X(2),Y(2),1,0,0,0,-1*X(2)*x(2),-1*Y(2)*x(2)];
A(4,:)=[0,0,0,X(2),Y(2),1,-1*X(2)*y(2),-1*Y(2)*y(2)];

A(5,:)=[X(3),Y(3),1,0,0,0,-1*X(3)*x(3),-1*Y(3)*x(3)];
A(6,:)=[0,0,0,X(3),Y(3),1,-1*X(3)*y(3),-1*Y(3)*y(3)];

A(7,:)=[X(4),Y(4),1,0,0,0,-1*X(4)*x(4),-1*Y(4)*x(4)];
A(8,:)=[0,0,0,X(4),Y(4),1,-1*X(4)*y(4),-1*Y(4)*y(4)];

v = [x(1);y(1);x(2);y(2);x(3);y(3);x(4);y(4)];

u = A\v;
U = reshape([u;1],3,3)';

T = maketform('projective',U');
img_rgb = imtransform(img_rgb,T,'XData',[1 350],'YData',[1 480]);

end

function img_rgb = getImageLeft()
img_rgb = getImage();

X = [100;555;555;85];
Y = [105;105;555;550];

x=[1;500;500;1]; % 500
y=[1;1;500;500]; % 500

A=zeros(8,8);
A(1,:)=[X(1),Y(1),1,0,0,0,-1*X(1)*x(1),-1*Y(1)*x(1)];
A(2,:)=[0,0,0,X(1),Y(1),1,-1*X(1)*y(1),-1*Y(1)*y(1)];

A(3,:)=[X(2),Y(2),1,0,0,0,-1*X(2)*x(2),-1*Y(2)*x(2)];
A(4,:)=[0,0,0,X(2),Y(2),1,-1*X(2)*y(2),-1*Y(2)*y(2)];

A(5,:)=[X(3),Y(3),1,0,0,0,-1*X(3)*x(3),-1*Y(3)*x(3)];
A(6,:)=[0,0,0,X(3),Y(3),1,-1*X(3)*y(3),-1*Y(3)*y(3)];

A(7,:)=[X(4),Y(4),1,0,0,0,-1*X(4)*x(4),-1*Y(4)*x(4)];
A(8,:)=[0,0,0,X(4),Y(4),1,-1*X(4)*y(4),-1*Y(4)*y(4)];

v = [x(1);y(1);x(2);y(2);x(3);y(3);x(4);y(4)];

u = A\v;
U = reshape([u;1],3,3)';

T = maketform('projective',U');
img_rgb = imtransform(img_rgb,T,'XData',[1 500],'YData',[1 500]);
end

function gp = getGraspingPointRight()

img_rgb = getImageRight();

% Convert to grayscale and normalize (0-1)
img_norm = rgb2gray(double(img_rgb)./255.0);

% Binarize image
img_bin = imbinarize(img_norm,0.5);
img_bin = im2uint8(img_bin);

img_bin = ~img_bin;
img_bin = imfill(img_bin, 'holes');

sz_original = size(img_bin);

img_bin = imresize(img_bin, 0.1);

if max(img_bin(:)) > 0
    
    [val,idx] = sort(img_bin(:),'descend');
    
    r = randi([1 sum(val)],1);
    
    sz = size(img_bin);
    [ind1,ind2] = ind2sub(sz,idx(r));
    
    ind1_original = ind1/sz(1)*sz_original(1)-sz_original(1)/sz(1)/2;
    ind1_original = round(ind1_original);
    ind2_original = ind2/sz(2)*sz_original(2)-sz_original(2)/sz(2)/2;
    ind2_original = round(ind2_original);
    
    img_rgb = insertMarker(img_rgb,[ind2_original,ind1_original],'star','Color','red','size',5);
    figure(1);
    subplot(1,2,1); imshow(img_rgb); title('Container');
    %imshow(img_rgb);
    
    gp = [ind2_original, ind1_original];
else
    gp = [-1, -1];
end
end

function displayDetectedElements(img_rgb,elements)
% Display detected Objects
for i=1:length(elements)
    type = string(elements{1,i}.type);
    annotations = "";
    if isequal('screw',type)
        annotations = sprintf('screw,D=%dmm,L=%dmm', elements{1,i}.diameter, elements{1,i}.length);
    elseif isequal('nut',type)
        annotations = sprintf('nut,Din=%dmm', elements{1,i}.inner_radius);
    elseif isequal('washer',type)
        annotations = sprintf('washer,Din=%dmm,Dout=%dmm', elements{1,i}.inner_radius, elements{1,i}.outer_radius);
    elseif isequal('nothing',type)
        annotations = sprintf('nothing');
    end
    if ~isequal('nothing',type)
        img_rgb = insertObjectAnnotation(img_rgb,'rectangle',elements{1,i}.bbox,cellstr(annotations));
        img_rgb = insertMarker(img_rgb,[elements{1,i}.grasp_point(1),elements{1,i}.grasp_point(2)],'star','Color','blue','size',5);
    end
end
%figure(2);
%imshow(img_rgb)
figure(1);
subplot(1,2,2); imshow(img_rgb); title('Object detection');
end

function writeAngles(a,b,g)
global tClient
write(tClient, uint8(char("Angles_" + a + ',' + b + ',' + g)));
waitForJobCompl();
end

function [x,y,z] = cam2roboter(gp_x,gp_y)
x = 40+120*gp_y/500;
y = -80+88*gp_x/500;
z = 0;
end

function [x,y,z] = cam2roboterRight(gp_x,gp_y)
x = 50+50*gp_y/240;
y = 20+65*gp_x/350;
z = 0;
end

function moveL(x,y,z,ClOn)
global tClient
if ClOn
    write(tClient, uint8(char("moveLCl_" + x + ',' + y + ',' + z)));
else
    write(tClient, uint8(char("moveL_" + x + ',' + y + ',' + z)));
end
waitForJobCompl();
end

function moveJ(x,y,z,ClOn)
global tClient
if ClOn
    write(tClient, uint8(char("moveJCl_" + x + ',' + y + ',' + z)));
else
    write(tClient, uint8(char("moveJ_" + x + ',' + y + ',' + z)));
end
waitForJobCompl();
end

function shake()
global tClient
write(tClient, uint8('shake'));
waitForJobCompl();
end

function controlLight(on)
global tClient
if on == true
    write(tClient, uint8('Light_1'));
else
    write(tClient, uint8('Light_0'));
end
waitForJobCompl();
end

function controlEM(on)
global tClient
if on == true
    write(tClient, uint8('EM_1'));
else
    write(tClient, uint8('EM_0'));
end
waitForJobCompl();
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


