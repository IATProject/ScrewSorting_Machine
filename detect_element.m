function elements = detect_element(img_rgb_full,detector,scale)

% Parameter
overlapRatio_max = 0.05;

% Mask to get only the left side of the bright table
cut_x = 120;
cut_y = 100;
img_size_x = size(img_rgb_full,1);
img_size_y = size(img_rgb_full,2);
img_rgb = img_rgb_full(cut_x:img_size_x-cut_x,cut_y:img_size_y-cut_y,:);
img_rgb = img_rgb(:,1:round(size(img_rgb,2)/2),:);

% Detect and classify all objects in the image with YOLO
objects = clustering_YOLO(img_rgb, detector.YOLO);

% Handle multiple object detection
if length(objects.label)>1           %multiple objects detected
    for k=1:length(objects.label)     %calculate the overlap ratio between the boxes
        for kk=1:length(objects.label)
            overlapRatio = bboxOverlapRatio(objects.bbox(k,:),objects.bbox(kk,:));
            if overlapRatio > overlapRatio_max && k ~= kk  %overlap is to high to calculate the parameters of the object, return the grasp point to handle that object
                elements.type = 'anything';
                elements.bbox = [objects.bbox(k,1) + cut_y, objects.bbox(k,2) + cut_x, objects.bbox(k,3:4)];
                xCenter = objects.bbox(k,1) + objects.bbox(k,3)/2 + cut_y;
                yCenter = objects.bbox(k,2) + objects.bbox(k,4)/2 + cut_x;
                elements.grasp_point = [xCenter,yCenter];
                return      
            end
        end
    end
end


% Cluster image
clusters = clustering(img_rgb);

% Check if the cluster is empty
if isempty(fieldnames(clusters))
    elements.type = 'anything';
    elements.grasp_point = [-1,-1];
else % Determine objects
    for i=1:length(clusters)
        % Determine cluster image
        cluster_bbox = clusters(i).bbox;
        img_cluster = imcrop(img_rgb, cluster_bbox);
        
        % Calculate parameters
        element = determine_element(img_cluster,detector.CNN,scale);     
        elements(i) = element;
        elements(i).bbox = [cluster_bbox(1) + cut_y, cluster_bbox(2) + cut_x, cluster_bbox(3:4)];  
    end
end







