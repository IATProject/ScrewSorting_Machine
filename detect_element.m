function elements = detect_element(img_rgb_full,detector,scale)

% Parameter
parameter.plots = 0;            %[1,0] = plots on/off
parameter.area_sFac = 0.05;     %threshold of the removing areas
parameter.error_sR = 0.05;      %threshold of the error in the calculated radius (screw)
parameter.binlevel = 0.8;      %binarize level
parameter.downsample = 0.5;     %downsample the image (washer,nut)
parameter.olapRatio_max = 0.26; %max overlap ratio between two bbox's
parameter.olapRatio_min = 0.7;  %min overlap ratio between two bbox's
parameter.scale = scale;        %scaling factor
parameter.res_D = 0.1;         %resolution in the calculation of the diameter
parameter.digits = 1;           %digits after the comma for the results
parameter.max_L = 60;           %max/min length of the elements
parameter.min_L = 5;
parameter.max_D = 20;           %max/min diameter of the elements
parameter.min_D = 2.5;


% Mask to get only the left side of the bright table (old mask up, new mask down)
cut_up = 1;
cut_down = 0;
cut_left = 1;
cut_right = 0;
img_size_x = size(img_rgb_full,1);
img_size_y = size(img_rgb_full,2);
% figure(); subplot(1,2,1); imshow(img_rgb_full);
img_rgb = img_rgb_full(cut_up:img_size_x-cut_down,cut_left:img_size_y-cut_right,:);
% subplot(1,2,2);imshow(img_rgb);

% Detect single or multiple objects in the image with YOLO
objects = clustering_YOLO(img_rgb, detector.YOLO, parameter);

if length(objects.label)>1           %multiple objects detected
    for k=1:length(objects.label)     %calculate the overlap ratio between the boxes
        for kk=1:length(objects.label)
            overlapRatio = bboxOverlapRatio(objects.bbox(k,:),objects.bbox(kk,:),'Min');
            if overlapRatio > parameter.olapRatio_max && k ~= kk  %overlap is to high to calculate the parameters of the object, return the grasp point to handle that object
                elements{1}.type = 'anything';
                elements{1}.bbox = [objects.bbox(k,1) + cut_left, objects.bbox(k,2) + cut_up, objects.bbox(k,3:4)];
                xCenter = objects.bbox(k,1) + objects.bbox(k,3)/2 + cut_left;
                yCenter = objects.bbox(k,2) + objects.bbox(k,4)/2 + cut_up;
                elements{1}.grasp_point = [xCenter,yCenter];
                error_info(1);
                return
            end
        end
    end
end


% Cluster image (to get more precisely bbox's)
clusters = clustering(img_rgb,parameter);

if isempty(fieldnames(clusters))    % Check if the cluster is empty
    elements{1}.type = 'nothing';
    error_info(2);
else % Determine objects
    for i=1:length(clusters)
        % Determine cluster image
        cluster_bbox = clusters(i).bbox;
        img_cluster = imcrop(img_rgb, cluster_bbox);
        
        % Determine object label (label of the highest overlap ratio
        % with YOLO bbox)
        predicted_label = 'anything';       
        for j=1:length(objects.label)
            overlapRatio = bboxOverlapRatio(objects.bbox(j,:),cluster_bbox,'Min');
            if overlapRatio > parameter.olapRatio_min
                predicted_label = objects.label(j);
            end
        end
        
        %in case no YOLO bbox exist, but a cluster bbox (unknown object)
        if isequal('anything',predicted_label)
            elements{i}.type = 'anything';
            elements{i}.bbox = [cluster_bbox(1) + cut_left, cluster_bbox(2) + cut_up, cluster_bbox(3:4)];
            xCenter = cluster_bbox(1) + cluster_bbox(3)/2;
            yCenter = cluster_bbox(2) + cluster_bbox(4)/2;
            elements{i}.grasp_point = [xCenter,yCenter];
            error_info(4);
            return
        end
        
        % Calculate parameters
        element = determine_element(img_cluster,predicted_label,parameter);
        elements{i} = element;
        elements{i}.bbox = [cluster_bbox(1) + cut_left, cluster_bbox(2) + cut_up, cluster_bbox(3:4)];
        elements{i}.grasp_point = elements{i}.grasp_point + [elements{i}.bbox(1),elements{i}.bbox(2)];
    end
end







