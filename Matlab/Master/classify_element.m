function [predictedLabel] = classify_element(testimage,trained_net)

net = trained_net.net;
classifier = trained_net.classifier;

imageSize = net.Layers(1).InputSize;
augmentedimage = augmentedImageDatastore(imageSize, testimage, 'ColorPreprocessing', 'gray2rgb');
imageFeature = activations(net, augmentedimage, 'fc1000', 'OutputAs', 'columns');

% Pass CNN image features to trained classifier
predictedLabel = string(predict(classifier, imageFeature, 'ObservationsIn', 'columns'));



