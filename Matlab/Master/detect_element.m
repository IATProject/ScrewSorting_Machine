function elements = detect_element(img_rgb_full,detector,scale)

% Mask to get only the bright table
cut_x = 120;
cut_y = 100;
img_size_x = size(img_rgb_full,1);
img_size_y = size(img_rgb_full,2);
img_rgb = img_rgb_full(cut_x:img_size_x-cut_x,cut_y:img_size_y-cut_y,:);

% Cluster image
% clusters ... struct with field BoundingBox (from regionprops)
% coordinates from full resolution image
clusters = clustering(img_rgb);


% Check if the cluster is empty
if isempty(fieldnames(clusters))
    element.type = 'anything';
    element.grasp_point = [-1,-1];
else
    figure();
    imshow(img_rgb);
    hold on;
    
    for i=1:length(clusters)
        
        cluster_bbox = clusters(i).bbox;
        
        % image of cluster in full resolution
        img_cluster = imcrop(img_rgb, cluster_bbox);
        
        element = determine_element(img_cluster,detector,scale);
        element.grasp_point(1) = element.grasp_point(1) + cluster_bbox(1,1) + cut_y;
        element.grasp_point(2) = element.grasp_point(2) + cluster_bbox(1,2) + cut_x;
        
        elements(i) = element;
        
        % draw boundingbox
        rectangle('Position',[cluster_bbox(1),cluster_bbox(2),cluster_bbox(3),cluster_bbox(4)],'EdgeColor','b','LineWidth',1 );
        % draw grasping points
        plot(element.grasp_point(1)-cut_y,element.grasp_point(2)-cut_x,'*');
        
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
    
    % Display the results.
    %annotations = string(elements.type);
    %I = insertObjectAnnotation(img_rgb,'rectangle',clusters.bbox,cellstr(elements.type));
%     I = insertShape(img_rgb,'rectangle',clusters.bbox);
%     figure();
%     imshow(I);
    
end



