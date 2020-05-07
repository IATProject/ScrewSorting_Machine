%% Read and normalize image
img_orig = double(imread('images/image_0.jpg'))./255.0;
img = rgb2gray(img_orig);

resize_factor = 0.5;

img = imresize(img, resize_factor);

subplot(3, 3, 1);
imshow(img);
title('Normalized Image')

% Extract illuminated area 
imageSizeX = size(img,2);
imageSizeY = size(img,1);

[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);

centerX = imageSizeX/2;
centerY = imageSizeY/2;
radius = (imageSizeX-50)/2;

mask_circle = (rowsInImage - centerY).^2 + ...
              (columnsInImage - centerX).^2 <= radius.^2;

indices_mask = mask_circle < 1;

% Rectangular mask
% mask_rect = zeros(imageSizeY,imageSizeX);
% 
% top_left_per = [0.2, 0.2];
% bottom_right_per = [0.8, 0.8];
% 
% a = uint16(round(imageSizeX*top_left_per(1):imageSizeX*bottom_right_per(1)));
% b = uint16(round(imageSizeY*top_left_per(2):imageSizeY*bottom_right_per(2)));
% mask_rect(b,a) = 1;
%
% img = img .* mask_rect;

img_masked = img;
img_masked(indices_mask) = 1;

subplot(3, 3, 2);
imshow(img_masked);
title('Illuminated area only')

% Binarize image
img_bin = imbinarize(img_masked,0.3);
img_bin = im2uint8(img_bin);

img_bin = ~img_bin;

img_bin = imfill(img_bin, 'holes');

subplot(3, 3, 3);
imshow(img_bin);
title('Binarized image')

% Morphological closing to fill gaps
se = strel('disk',8);
img_bin = imclose(img_bin,se);

subplot(3, 3, 4);
imshow(img_bin);
title('Morphologically closed image')

% Remove small areas/noise
stat = regionprops(img_bin, 'Area', 'BoundingBox', 'PixelIdxList');

area_min_rel = 0.001;
area_max = imageSizeX*imageSizeY;
area_min = area_max*area_min_rel;

clusters = struct;

ii = 1;

for i=1:length(stat)
    
    area = stat(i).Area;
    
    if area < area_min
        indices = uint32(stat(i).PixelIdxList);
        img_bin(indices) = 0;
        continue;
    end
    
    bbox = round(stat(i).BoundingBox / resize_factor);
    
    clusters(ii).BoundingBox = bbox;
    ii = ii + 1;
    
end

subplot(3, 3, 5);
imshow(img_bin);
title('Small areas removed')


%%
labeledImage = bwlabel(img_bin, 8);     % Label each blob so we can make measurements of it
imshow(labeledImage, []);

coloredLabels = label2rgb(labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels
imshow(coloredLabels);

hold on;

measurements = regionprops(labeledImage, 'BoundingBox');
for k = 1 : length(measurements)
    thisBB = measurements(k).BoundingBox;
    rectangle('Position',[thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','b','LineWidth',1 );
end
hold off;
%% Active contours

s = regionprops(img_bin,'basic');
centroids = cat(1,s.Centroid);

figure;
imshow(img_bin);
hold on;
plot(centroids(:,1),centroids(:,2),'b*');
hold off;
