myDir = '/Users/simonschauppenlehner/Desktop/Testimages_1/Mixed_hard'; %gets directory
myFiles = dir(fullfile(myDir,'*.jpg')); %gets all wav files in struct

exportDir = '/Users/simonschauppenlehner/Google Drive/TU/Master/Industrielle Automation Projekt/Testimages_1/Mixed_hard';

for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    fullFileName = fullfile(myDir, baseFileName);

    img = imread(fullFileName);
    %img(:,2801:end,:) = [];

    %img = imrotate(img,90);
    
    i = k-1;
    
    name = sprintf(exportDir + "/img_" + i + ".jpg");
    
    imwrite(img, name);
    
end

%%

img = imread('/Users/simonschauppenlehner/Desktop/demo/IMG_0606.jpg');

img(:,2801:end,:) = [];

img = imrotate(img,90);

imshow(img);

%imwrite(img, 'dummy.jpg');

%%

name = sprintf("Hello %s", "fafd")