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

function [element] = determine_element(img_cluster,predicted_label,parameter)

% Image processing
img_norm = rgb2gray(double(img_cluster)./255.0);          
%binary image
img_bin = ~imbinarize(img_norm,parameter.binlevel);   
%remove small areas
area_opening = round(size(img_bin,1)*size(img_bin,2)*parameter.area_sFac);
img = bwareaopen(img_bin,area_opening,8);                       


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
    subplot(3,4,1); imshow(img_norm); title('Normalized');
    subplot(3,4,2); imshow(img_bin); title('äbinarized');
    subplot(3,4,3); imshow(img); title('Removed small areas');
end

