% main.m

% Initialization of camera

% Initialization of communication link to microcontroller

%% -------- CALIBRATION --------
% needs to be done once (for a specific setup (camera position))

% Read RGB image (full resolution)
img_rgb = imread('images/calibration/image_0.jpg');

% Convert to grayscale and normalize (0-1)
img_norm = rgb2gray(double(img_rgb)./255.0);

% cal_obj_size ... mm
cal_obj_size = 20;

% scale ... mm/pixel
%scale = calc_scale(img_norm, cal_obj_size);
scale = 10;

%% -------- CLUSTERING --------

% Read RGB image (full resolution)
img_rgb = imread('images/test/image_4.jpg');

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
%     img_cluster = imcrop(img_norm, cluster_bbox);
%     
%     % element ... struct with following fields
%     % type='anything'|'screw'|'nut'|'washer'
%     % grasp_point=[pos_x,pos_y]
%     % specific parameter fields (e.g. screw)
%     % diameter=6
%     % length=100
%     % specific parameter fields (e.g. washer)
%     % inner_radius=4
%     % outer_radius=10
%     element = determine_element(img_cluster,scale);
%     
%     clusters(i).element = element;
    
    % draw boundingbox
    rectangle('Position',[cluster_bbox(1),cluster_bbox(2),cluster_bbox(3),cluster_bbox(4)],'EdgeColor','b','LineWidth',1 );
    
    % labeling of elements
%     if strcmp(element.type, 'screw')
%         label = sprintf('screw\ndiameter=%dmm\nlength=%dmm', element.diameter, element.length);
%         text(10+cluster_bbox(1)+cluster_bbox(3),cluster_bbox(2),label,'Color','blue','FontSize',12,'FontWeight','bold');
%     elseif strcmp(element.type, 'washer')
%         label = sprintf('washer\ninner_radius=%dmm\nouter_radius=%dmm', element.inner_radius, element.outer_radius);
%         text(10+cluster_bbox(1)+cluster_bbox(3),cluster_bbox(2),label,'Color','blue','FontSize',12,'FontWeight','bold');
%     end
    
end

hold off;


%% Questions

% Greifer als magnet ausführen? Freiheitsgrade
% Termin für Zwischenpräsentation früher?
% Aufbau? Wie? (Holzrahmen, Licht, ...) Kaufen? Budget (1000+ ?)
% Kinect abholen möglich?
% 3-D notwendig? JA!
% Kinemtik

