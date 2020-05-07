clear all
close all
% main.m

% Initialization of communication link to microcontroller
u = udp('192.168.1.187',6790,'Localport',6789);
u.DatagramReceivedFcn = @dataReceivedCallback;
fopen(u);

%%

fclose(u);
delete(u);
clear u

%%

goto(u,80,0.153,10)
%controlLight(u,false)
%shake(u)
%% -------- CALIBRATION --------
% needs to be done once (for a specific setup (camera position))

% Read RGB image (full resolution)
img_rgb = imread('images/Testimages_2/coin/img_0.jpg');

% Convert to grayscale and normalize (0-1)
img_norm = rgb2gray(double(img_rgb)./255.0);

% cal_obj_size ... mm
cal_obj_size = 21.25;       %referenz size: 5 Cent coin

% scale ... mm/pixel
%scale = calc_scale(img_norm, cal_obj_size);
scale = 0.14676;            %have to be very precicly, error 5px ~ 0.32mm


%% -------- CLUSTERING --------

% Read RGB image (full resolution)
img_rgb = imread('images/Testimages_2/m/img_0.jpg');
% Convert to grayscale and normalize (0-1)
img_norm = rgb2gray(double(img_rgb)./255.0);

% Cluster image
% clusters ... struct with field BoundingBox (from regionprops)
% coordinates from full resolution image
clusters = clustering(img_norm);

% -------- START LOOP --------

figure(1);
imshow(img_rgb);
hold on;

for i=1:length(clusters)
    
    cluster_bbox = clusters(i).BoundingBox;
    
    % image of cluster in full resolution
    img_cluster = imcrop(img_norm, cluster_bbox);
    
    % element ... struct with following fields
    % type='anything'|'screw'|'nut'|'washer'
    % grasp_point=[pos_x,pos_y]
    % specific parameter fields (e.g. screw)
    % diameter=6
    % length=100
    % specific parameter fields (e.g. washer)
    % inner_radius=4
    % outer_radius=10
    element = determine_element(img_cluster,scale);
    
    clusters(i).element = element;
    
    % draw boundingbox
    rectangle('Position',[cluster_bbox(1),cluster_bbox(2),cluster_bbox(3),cluster_bbox(4)],'EdgeColor','b','LineWidth',1 );
    
    % labeling of elements
    if strcmp(element.type, 'screw')
        label = sprintf('screw\ndiameter=%dmm\nlength=%dmm', element.diameter, element.length);
        text(10+cluster_bbox(1)+cluster_bbox(3),cluster_bbox(2),label,'Color','blue','FontSize',7,'FontWeight','bold');
    elseif strcmp(element.type, 'washer')
        label = sprintf('washer\ninner radius=%dmm\nouter radius=%dmm', element.inner_radius, element.outer_radius);
        text(10+cluster_bbox(1)+cluster_bbox(3),cluster_bbox(2),label,'Color','blue','FontSize',7,'FontWeight','bold');
    elseif strcmp(element.type, 'nut')
        label = sprintf('nut\ninner radius=%dmm', element.inner_radius);
        text(10+cluster_bbox(1)+cluster_bbox(3),cluster_bbox(2),label,'Color','blue','FontSize',7,'FontWeight','bold');
    end
    
end

hold off;

%% Helper functions
function goto(u,x,y,z)
fwrite(u, "Goto_" + x + ',' + y + ',' + z);
end

function gotoCL(u,x,y,z)
fwrite(u, "GotoCL_" + x + ',' + y + ',' + z);
end

function shake(u)
fwrite(u, 'Shake');
end

function controlLight(u,on)
if on == true
    fwrite(u, 'Light_1');
else
    fwrite(u, 'Light_0');
end
end

function controlEM(u,on)
if on == true
    fwrite(u, 'EM_1');
else
    fwrite(u, 'EM_0');
end
end

function captureImage(u)
fwrite(u, 'CaptureImg');
end
