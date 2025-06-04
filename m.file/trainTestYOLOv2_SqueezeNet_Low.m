inputSize = [227 227 3];
numClasses = 1; % Tümör sınıfı

% Backbone ve feature layer
featureExtractionNetwork = squeezenet;
featureLayer = 'fire9-concat';

% YOLOv2 ağı oluştur
lgraph = yolov2Layers(inputSize, numClasses, anchorBoxes, featureExtractionNetwork, featureLayer);

% Eğitim seçenekleri
options = trainingOptions('adam', ...
    'InitialLearnRate',1e-4, ...
    'MiniBatchSize',16, ...
    'MaxEpochs',20, ...
    'ValidationData',validationData, ...
    'ValidationFrequency',5, ...
    'Verbose',false, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress');

% Modeli eğit
[detector, info] = trainYOLOv2ObjectDetector(trainingData, lgraph, options);

% Test verisi üzerinde tespit yap
detectionResults = detect(detector, testData);

% Performans ölçümleri
[ap, recall, precision] = evaluateDetectionPrecision(detectionResults, testData);
F1 = 2 * (precision .* recall) ./ (precision + recall);

fprintf('mAP: %.4f\nRecall: %.4f\nPrecision: %.4f\nF1 Score: %.4f\n', ap(end), recall(end), precision(end), F1(end));

% Modeli kaydet
save('C:\Users\Asus\Desktop\trainedYOLOv2Detector_SqueezeNet.mat', 'detector');

% Test için örnek görüntü
testImagePath = 'C:\Users\Asus\Desktop\brain_tumor_dataset_cleaned\tumor\tumor_0043.jpg';
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
title('Tümör Tespiti - YOLOv2 (SqueezeNet)');
