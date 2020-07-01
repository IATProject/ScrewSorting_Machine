%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  clusters = clustering(img_norm)
%  purpose:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input arguments
%       img_norm:
%  output arguments
%       clusters:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function element = determine_washer(img,parameter)

% Downsample the image to increase the speed
img = imresize(img,parameter.downsample);

% Find circles in the image and calculate the radius
Rmin = round(parameter.min_D/(2*parameter.scale));              %min/max diameter for searching
Rmax = max(size(img));
[cp_in,r_in] = imfindcircles(img,[Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.9);
[cp_out,r_out] = imfindcircles(img,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.9);

% Only keep the pair with the center near the cluster center
if size(cp_in,1)>1 || size(cp_out,1)>1
    stat = regionprops(img, 'Centroid');
    cp_x = stat(1).Centroid(1,1);           %always sorted?
    cp_y = stat(1).Centroid(1,2);
    err2cp_in = sqrt((cp_in(:,1)-cp_x).^2+(cp_in(:,2)-cp_y).^2);
    err2cp_out = sqrt((cp_out(:,1)-cp_x).^2+(cp_out(:,2)-cp_y).^2);
    [~,minerri_in] = min(err2cp_in);
    [~,minerri_out] = min(err2cp_out);
    cp_in = cp_in(minerri_in,:);
    r_in = r_in(minerri_in,:);
    cp_out = cp_out(minerri_out,:);
    r_out = r_out(minerri_out,:);
end

% Claculate diameter
Din_mm = round(2*r_in*parameter.scale/parameter.downsample,parameter.digits);
Dout_mm = round(2*r_out*parameter.scale/parameter.downsample,parameter.digits);
grasp_point = round(cp_in/parameter.downsample);

% Parameter to struct, catch error in calculation
if ~isempty(Din_mm) && ~isempty(Dout_mm) ...
        && Din_mm <= parameter.max_D && Din_mm >= parameter.min_D 
    
    element.type = 'washer';
    element.inner_radius = Din_mm;
    element.outer_radius = Dout_mm;
    element.grasp_point = grasp_point;
else
    element.type = 'anything';
    element.grasp_point = grasp_point;
    error_info(3);
end


% Plots
if parameter.plots == 1
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(3,4,5); imshow(img); title('inner/outer radius and grasping point');
    viscircles([cp_in;cp_out],[r_in;r_out]);
    hold on
    plot(cp_in(1,1),cp_in(1,2),'r*');
end
