clear all
close all
% main.m

% Initialization of camera

% Initialization of communication link to microcontroller


%% -------- TRAIN DEEP LEARNING NETWORK --------
% CNN for classifying elements
CNN = load('trained_net.mat');
detector.CNN = CNN.trained_net;

% YOLO for classifying elements
% Load pretrained YOLO detector
detector.YOLO = load('detector.mat');

%% -------- CALIBRATION --------
% needs to be done once (for a specific setup (camera position))

% Read RGB image (full resolution)
coin_rgb = imread('images/Testimages_4_Ref/img_1.jpg');

% cal_obj_size ... mm
cal_obj_size = 21.25;       %referenz size: 5 Cent coin

% scale ... mm/pixel
% scale = calc_scale(coin_rgb, cal_obj_size);
scale = 0.2041;            %have to be very precicly, error 5px ~ 0.32mm


%% -------- DETECT ELEMENT ----------

img_rgb = imread('images/Testimages_4/img_0.jpg');
elements = detect_element(img_rgb,detector,scale);

% Show detected objects
for i=1:length(elements)
    type = string(elements{1,i}.type);
    if isequal('screw',type)
        annotations = sprintf('screw,D=%dmm,L=%dmm', elements{1,i}.diameter, elements{1,i}.length);
    elseif isequal('nut',type)
        annotations = sprintf('nut,Din=%dmm', elements{1,i}.inner_radius);
    elseif isequal('washer',type)
        annotations = sprintf('washer,Din=%dmm,Dout=%dmm', elements{1,i}.inner_radius, elements{1,i}.outer_radius);
    elseif isequal('anything',type)
        annotations = sprintf('anything');
    end
    img_rgb = insertObjectAnnotation(img_rgb,'rectangle',elements{1,i}.bbox,cellstr(annotations));
    img_rgb = insertMarker(img_rgb,[elements{1,i}.grasp_point(1),elements{1,i}.grasp_point(2)],'star','Color','blue','size',5);
end
figure(img);imshow(img_rgb)



