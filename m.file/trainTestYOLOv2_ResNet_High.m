inputSize = [224 224 3]; % ResNet50 de 224x224 bekler
numClasses = 1;

featureExtractionNetwork = resnet50;
featureLayer = 'activation_40_relu'; % ResNet50 ara katmanlarından biri

lgraph = yolov2Layers(inputSize, numClasses, anchorBoxes, featureExtractionNetwork, featureLayer);

options = trainingOptions('adam', ...
    'InitialLearnRate',1e-3, ...
    'MiniBatchSize',16, ...
    'MaxEpochs',20, ...
    'ValidationData',validationData, ...
    'ValidationFrequency',5, ...
    'Verbose',false, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress');

% Eğitim için verileri resnet boyutuna göre resize eden augment fonksiyonu kullanabilirsin
% Örneğin augmentDataResnet fonksiyonu (aşağıda örneği var)
trainingData = transform(trainingData,@(data)augmentDataResnet(data));

[detector, info] = trainYOLOv2ObjectDetector(trainingData, lgraph, options);

detectionResults = detect(detector, testData);

[ap, recall, precision] = evaluateDetectionPrecision(detectionResults, testData);
F1 = 2 * (precision .* recall) ./ (precision + recall);

fprintf('mAP: %.4f\nRecall: %.4f\nPrecision: %.4f\nF1 Score: %.4f\n', ap(end), recall(end), precision(end), F1(end));

save('C:\Users\Asus\Desktop\trainedYOLOv2Detector_ResNet50.mat', 'detector');

% Test görüntüsü
testImage = imread(testImagePath);
testImage = imresize(testImage, inputSize(1:2));

[bboxes, scores, labels] = detect(detector, testImage);

if ~isempty(bboxes)
    detectedImg = insertObjectAnnotation(testImage, 'rectangle', bboxes, ...
        string(labels) + ": " + string(scores, '%.2f'));
else
    detectedImg = testImage;
    disp("Tümör tespit edilmedi.");
end

figure;
imshow(detectedImg);
title('Tümör Tespiti - YOLOv2 (ResNet50)');
