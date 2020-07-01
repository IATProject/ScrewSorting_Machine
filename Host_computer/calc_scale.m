function scale = calc_scale(img_rgb, cal_obj_size)

% Camera calibration
% Since a 2D image is processed, we need a reference object to be able to
% calculate the parameters of the screws (diameter, length). Therefore a
% coins with known diameter were used and a scaling factor was calculated.

downsample = 1;

% Convert to grayscale and normalize (0-1)
img_norm = rgb2gray(double(img_rgb)./255.0);
img = imresize(img_norm,downsample);     %read grayscale and normalized image
img = imbinarize(img);                   %binary image

% Parameter
Rmin = round(min(size(img))*0.05);              %min/max diameter for searching
Rmax = round(min(size(img))*0.4);       
Rref1 = cal_obj_size;      
     
% Find circles in the image and calculate the radius
[centers,radii] = imfindcircles(img,[Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.9);
figure(); imshow(img);
h = viscircles(centers,radii);

% Calculate the scale factor and the relative error of the second reference
% object in respect to the first object
scale = Rref1/(2*radii(1)*1/downsample);

%%calculated error
%Rref2 = 24.25; 
%errorRef = abs((Rref2-2*radii(2)*px2mm)/Rref2);

