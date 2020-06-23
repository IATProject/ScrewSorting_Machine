%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  clusters = clustering(img_norm)
%  purpose:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input arguments
%       img_norm:
%  output arguments
%       clusters:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function element = determine_screw(img,parameter)

% calculate the axes (and many more props)
stat = regionprops(img, 'Orientation', 'Centroid');

% grasping point
grasp_x = stat.Centroid(1,1);
grasp_y = stat.Centroid(1,2);

% rotating the image and fitting a line
img_rot = imrotate(img,-stat.Orientation);
[y_body,x_body] = find(img_rot);
p_fit_rot = polyfit(x_body, y_body, 1);

% calculate the diameter with a voting-histogram
% distance from the IP's to the line
C = detectHarrisFeatures(img_rot);
k1 = p_fit_rot(1);
d1 = p_fit_rot(2);
k2 = -1/k1;
d2 = C.Location(:,2)-k2*C.Location(:,1);
Qx = (d2-d1)/(k1-k2);
Qy = k1*Qx+d1;
d  = sqrt((Qx-C.Location(:,1)).^2+(Qy-C.Location(:,2)).^2);

% Voting-histogram
edges_r = parameter.res_D / parameter.scale;
max_r   = parameter.max_D / parameter.scale;
edges = (0:edges_r:max_r);
N = histcounts(d,edges);
[~,max_index] = max(N);
r = edges_r*max_index;          %besser bearbeiten in diesem Pin, vl auch noch Gewindeinfo nutzen um Holz und Metallschrauben zu unterscheiden!
D_mm = round(2*r*parameter.scale,parameter.digits);

% cut out the area between the two lines, than find the leftmost point or
% the rightest point; cut the image into head and body of the screw
img_cut = img_rot;
x_cp = size(img_cut,2)/2;
y_cp = x_cp*p_fit_rot(1)+p_fit_rot(2);
%cut the image with respect to an error in the radius,
img_cut(round(y_cp-(r*(1+parameter.error_sR))):round(y_cp+(r*(1+parameter.error_sR))),:) = 0;
%remove small remaining areas
area_opening = round(numel(find(img_cut))*parameter.area_sFac);
img_cut = bwareaopen(img_cut,area_opening,8);

%find the leftmost point or the rightest point
[y_cut,x_cut] = find(img_cut);
[x_max_cut,x_maxi_cut] = max(x_cut);
[x_min_cut,x_mini_cut] = min(x_cut);

% calculate the orientation of the screw, than cut the image
L_mm = 0;
if ~isempty(x_cut)
    if x_max_cut  < size(img_rot,2)/2  &&  x_min_cut  < size(img_rot,2)*2/3   %left
        seg_head = img_rot(:,1:x_max_cut);
        seg_body = img_rot(:,x_max_cut+1:end);
    else
        seg_body = img_rot(:,1:x_min_cut);
        seg_head = img_rot(:,x_min_cut+1:end);
    end
% calculate the length
[y_body,x_body] = find(seg_body);
[x_max_body,x_maxi_body] = max(x_body);
[x_min_body,x_mini_body] = min(x_body);
L_mm = abs(x_max_body-x_min_body)*parameter.scale;
L_mm = round(L_mm,parameter.digits);
end

% Parameter to struct, catch error in calculation
if ~isempty(D_mm) && ~isempty(L_mm) ...
        && D_mm <= parameter.max_D && D_mm >= parameter.min_D ...
        && L_mm <= parameter.max_L && L_mm >= parameter.min_L
    
    element.type = 'screw';
    element.grasp_point=[grasp_x,grasp_y];
    element.diameter=D_mm;
    element.length=L_mm;
else
    element.type = 'anything';
    element.grasp_point=[grasp_x,grasp_y];
    error_info(3);
end


% plots
if parameter.plots == 1
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(3,4,5); imshow(img); title('Grasping point');
    hold all
    plot(grasp_x,grasp_y,'*');
    yy = linspace(1, size(img_rot,2), 50);
    subplot(3,4,6);imshow(img_rot); title('Fitted line and rotated');
    hold all
    plot( yy, polyval(p_fit_rot, yy), '-');
    subplot(3,4,7); imshow(img_rot); title('Interest Points');
    hold on
    plot(C.Location(:,1),C.Location(:,2),'r*');
    plot( yy, polyval(p_fit_rot, yy), 'b-');
    subplot(3,4,8); imshow(img_rot); title('Diameter');
    hold all
    plot( yy, polyval(p_fit_rot, yy), '-',yy, polyval(p_fit_rot, yy)+r, '.-',yy, polyval(p_fit_rot, yy)-r, '.-');
    plot(x_cp,y_cp,'g*');
    subplot(3,4,9); imshow(img_cut); title('Cut');
    hold all
    plot(x_max_cut,y_cut(x_maxi_cut),'-*',x_min_cut,y_cut(x_mini_cut),'-*');
    subplot(3,4,10); imshow(seg_head); title('Head');
    subplot(3,4,11); imshow(seg_body); title('Body');
    hold on
    plot(x_max_body,y_body(x_maxi_body),'-*',x_min_body,y_body(x_mini_body),'-*');
    
end