function clusters = clustering_YOLO(img_rgb, YOLO, parameter)

detector = YOLO.detector;
inputSize = YOLO.inputSize;

% resize the image to the same size as the training images.
I = imresize(img_rgb,inputSize(1:2));
[bbox, score, label] = detect(detector,I);

% Resize to normal size 
scale = size(img_rgb,[1 2])./inputSize(1:2);
I = imresize(I,size(img_rgb,[1 2]));
bbox = bboxresize(bbox,scale);

clusters.bbox = bbox;
clusters.score = score;
clusters.label = string(label);

if isempty(label)
    error_info(4);
end

% Display the results.
if parameter.plots && ~isempty(label)
annotations = string(label) + ": " + string(score);
I = insertObjectAnnotation(I,'rectangle',bbox,cellstr(annotations));
figure
imshow(I)
end

