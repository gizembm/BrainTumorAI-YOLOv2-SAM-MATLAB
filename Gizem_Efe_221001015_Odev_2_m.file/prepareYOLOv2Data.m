% Dataset yolunu belirt
digitDatasetPath = 'C:\Users\Asus\Desktop\brain_tumor_dataset_cleaned';

% Ground Truth verisini yükle
load('C:\Users\Asus\Desktop\YOLOv2_dataset.mat'); % gTruth değişkeni yüklendi

% Eğitim verisini tabloya çevir (imageFilename, bbox, label sütunları)
dataTbl = objectDetectorTrainingData(gTruth, 'SamplingFactor', 1);

% Verileri karıştır
dataTbl = dataTbl(randperm(height(dataTbl)), :);

% Eğitim, validasyon ve test setlerine böl
numTrain = round(0.7 * height(dataTbl));
numVal = round(0.15 * height(dataTbl));

trainTbl = dataTbl(1:numTrain, :);
valTbl = dataTbl(numTrain+1:numTrain+numVal, :);
testTbl = dataTbl(numTrain+numVal+1:end, :);

% ImageDatastore ve BoxLabelDatastore oluştur (eğitim, validasyon, test için)
imdsTrain = imageDatastore(trainTbl.imageFilename);
bldsTrain = boxLabelDatastore(trainTbl(:, 2:end));
trainingData = combine(imdsTrain, bldsTrain);

imdsVal = imageDatastore(valTbl.imageFilename);
bldsVal = boxLabelDatastore(valTbl(:, 2:end));
validationData = combine(imdsVal, bldsVal);

imdsTest = imageDatastore(testTbl.imageFilename);
bldsTest = boxLabelDatastore(testTbl(:, 2:end));
testData = combine(imdsTest, bldsTest);

% Anchor kutularını tahmin et
[anchorBoxes, meanIoU] = estimateAnchorBoxes(trainingData, 1);
fprintf('Mean IoU: %.4f\n', meanIoU); 