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
detector.YOLO = load('detector_Testimages_4_dataset1_left_rand_200');

%% -------- CALIBRATION --------
% needs to be done once (for a specific setup (camera position))

% Read RGB image (full resolution)
coin_rgb = imread('images/Testimages_2/coin/img_0.jpg');

% cal_obj_size ... mm
cal_obj_size = 21.25;       %referenz size: 5 Cent coin

% scale ... mm/pixel
%scale = calc_scale(coin_rgb, cal_obj_size);
scale = 0.14676;            %have to be very precicly, error 5px ~ 0.32mm


%% -------- DETECT ELEMENT ----------

img_rgb = imread('images/Testimages_4/img_44.jpg');
elements = detect_element(img_rgb,detector,scale);

% Show detected objects
annotations = string(elements.type);
I = insertObjectAnnotation(img_rgb,'rectangle',elements.bbox,cellstr(annotations));
figure();imshow(I)
hold on
plot(elements.grasp_point(1),elements.grasp_point(2),'*');


