%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  clusters = clustering(img_norm)
%  purpose:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input arguments
%       img_norm:
%  output arguments
%       clusters:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clusters = clustering(img_rgb,parameter)

% Convert to grayscale and normalize (0-1)
img_norm = rgb2gray(double(img_rgb)./255.0);

% Resize image to speed up the process
resize_factor = 0.5;
img_norm = imresize(img_norm, resize_factor);

% Binarize image
img_bin = imbinarize(img_norm,0.5);
img_bin = im2uint8(img_bin);

img_bin = ~img_bin;

img_bin = imfill(img_bin, 'holes');

% % Morphological closing to fill gaps
% se = strel('disk',8);
% img_bin = imclose(img_bin,se);

% Get connected pixels (clusters)
stat = regionprops(img_bin, 'Area', 'BoundingBox', 'PixelIdxList');

area_min_rel = 0.001;
img_size_x = size(img_norm,2);
img_size_y = size(img_norm,1);
area_max = img_size_x*img_size_y;
area_min = area_max*area_min_rel;

clusters = struct;

ii = 1;
bbox_gain = 1.3;

for i=1:length(stat)
    
    % Remove small areas/noise
    area = stat(i).Area;
    
    if area < area_min
        indices = uint32(stat(i).PixelIdxList);
        img_bin(indices) = 0;
        continue;
    end
    
    % Enlarge BoundingBox dimensions
    bbox = round(stat(i).BoundingBox / resize_factor);
    
    bbox_width = bbox(3);
    bbox_height = bbox(4);
    
    bbox_width_delta = round(bbox_width*(bbox_gain-1)/2);
    bbox_height_delta = round(bbox_height*(bbox_gain-1)/2);
    
    bbox(1) = bbox(1) - bbox_width_delta;
    bbox(2) = bbox(2) - bbox_height_delta;
    bbox(3) = bbox(3) + 2*bbox_width_delta;
    bbox(4) = bbox(4) + 2*bbox_height_delta;
    
    % Check if boundary conditions are met
    if bbox(1) < 1
        bbox(1) = 1;
    end
    if bbox(2) < 1
        bbox(2) = 1;
    end
    if bbox(3) > round(img_size_x/resize_factor)
        bbox(3) = round(img_size_x/resize_factor);
    end
    if bbox(4) > round(img_size_y/resize_factor)
        bbox(4) = round(img_size_y/resize_factor);
    end
    
    clusters(ii).bbox = bbox;
    ii = ii + 1;
    
end

if parameter.plots
    figure();
    
    subplot(2, 2, 1);
    imshow(img_norm);
    title('Normalized Image')
    
    subplot(2, 2, 2);
    imshow(img_bin);
    title('Binarized image')
    
    subplot(2, 2, 3);
    imshow(img_bin);
    title('Morphologically closed image')
    
    subplot(2, 2, 4);
    imshow(img_bin);
    title('Small areas removed')
end

end