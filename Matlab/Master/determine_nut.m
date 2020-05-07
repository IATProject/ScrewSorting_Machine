%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  clusters = clustering(img_norm)
%  purpose:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input arguments
%       img_norm:
%  output arguments
%       clusters:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function element = determine_nut(img,parameter)

% Downsample the image to increase the speed
img = imresize(img,parameter.downsample);                         

% Find circle in the image and calculate the radius
Rmin = round(min(size(img))*0.15);              %min/max diameter for searching
Rmax = max(size(img));
[cp_in,r_in] = imfindcircles(img,[Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.9);

% Only keep the radius with the center near the cluster center
if size(cp_in,1)>1
    stat = regionprops(img, 'Centroid');
    cp_x = stat(1).Centroid(1,1);           %always sorted by size?
    cp_y = stat(1).Centroid(1,2);
    err2cp_in = sqrt((cp_in(:,1)-cp_x).^2+(cp_in(:,2)-cp_y).^2);
    [~,minerri_in] = min(err2cp_in);
    cp_in = cp_in(minerri_in,:);
    r_in = r_in(minerri_in,:);
end

% Claculate diameter
Din_mm = round(2*r_in*parameter.scale/parameter.downsample,0);
grasp_point = round(cp_in/parameter.downsample);

% Parameter to struct
element.type = 'nut';
element.inner_radius = Din_mm;
element.grasp_point = grasp_point;

% Plots
if parameter.plots == 1
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(3,4,5); imshow(img); title('inner radius and grasping point');
    viscircles(cp_in,r_in);
    hold on
    plot(cp_in(1,1),cp_in(1,2),'r*');
end
