%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function [element] = determine_element(img_cluster,trained_net,scale)
%  purpose: classify the element in the img_cluster and determine its 
%  parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input arguments
%       img_cluster: image of one clustered element
%       trained_net: trained DL net and its classifier
%       scale: scale factor
%  output arguments
%       % element: struct with following fields
%                  -type='anything'|'screw'|'nut'|'washer'
%                  -grasp_point=[pos_x,pos_y]
%                  specific parameter fields (e.g. screw)
%                  -diameter
%                  -length
%                  specific parameter fields (e.g. washer)
%                  -inner_radius
%                  -outer_radius
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [element] = determine_element(img_cluster,detector,scale)

% Parameter
parameter.plots = 0;            %[1,0] = plots on/off
parameter.area_sFac = 0.05;     %threshold of the removing areas
parameter.error_sR = 0.1;       %threshold of the error in the radius
parameter.downsample = 0.5;     %downsample the image (washer,nut)
parameter.scale = scale;        %scaling factor 
parameter.digits = 0;           %digits after the comma for the results

parameter.max_L = 50;           %max/min length of the elements
parameter.min_L = 5;
parameter.max_D = 10;           %max/min diameter of the elements
parameter.min_D = 1;


% Predict the label
predicted_label = classify_element(img_cluster,detector);
% cluster_info = clustering_YOLO(img_cluster, detector.YOLO);

% Image processing
img_norm = rgb2gray(double(img_cluster)./255.0);          
%binary image
img_bin = ~imbinarize(img_norm);   
%remove small areas
area_opening = round(size(img_bin,1)*size(img_bin,2)*parameter.area_sFac);
img = bwareaopen(img_bin,area_opening,8);                       

% 
% Determine parameter of the element
if isequal('nut',predicted_label)               %detected object is a nut
    element = determine_nut(img,parameter);
elseif isequal('washer',predicted_label)        %detected object is a washer
    element = determine_washer(img,parameter);
elseif isequal('screw',predicted_label)         %detected object is a screw
    element = determine_screw(img,parameter);
end


% Plots
if parameter.plots == 1
    subplot(3,4,1); imshow(img_norm); title('normalized');
    subplot(3,4,2); imshow(img_bin); title('binarized');
    subplot(3,4,3); imshow(img); title('removed small areas');
end

