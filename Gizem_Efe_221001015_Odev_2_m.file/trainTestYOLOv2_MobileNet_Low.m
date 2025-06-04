inputSize = [224 224 3]; % MobileNet genelde 224x224 kullanır
numClasses = 1;

featureExtractionNetwork = mobilenetv2;
featureLayer = 'block_13_expand_relu'; % MobileNetV2'de özellik çıkarım katmanı

lgraph = yolov2Layers(inputSize, numClasses, anchorBoxes, featureExtractionNetwork, featureLayer);

options = trainingOptions('adam', ...
    'InitialLearnRate',1e-4, ...
    'MiniBatchSize',16, ...
    'MaxEpochs',20, ...
    'ValidationData',validationData, ...
    'ValidationFrequency',5, ...
    'Verbose',false, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress');

% Eğitim için verileri mobilenet boyutuna göre resize eden augment fonksiyonu kullanabilirsin
% Eğitim için Data Augmentation fonksiyonu örneği:
trainingData = transform(trainingData,@(data)augmentDataMobilenet(data));

[detector, info] = trainYOLOv2ObjectDetector(trainingData, lgraph, options);

detectionResults = detect(detector, testData);

[ap, recall, precision] = evaluateDetectionPrecision(detectionResults, testData);
F1 = 2 * (precision .* recall) ./ (precision + recall);

fprintf('mAP: %.4f\nRecall: %.4f\nPrecision: %.4f\nF1 Score: %.4f\n', ap(end), recall(end), precision(end), F1(end));

save('C:\Users\Asus\Desktop\trainedYOLOv2Detector_MobileNet.mat', 'detector');

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
title('Tümör Tespiti - YOLOv2 (MobileNet)');
