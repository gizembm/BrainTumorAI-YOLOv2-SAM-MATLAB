% 1. Dosya yollarını ayarla
imageFolder = 'C:\Users\Asus\Desktop\brain_tumor_dataset_cleaned\tumor';
imageFiles = dir(fullfile(imageFolder, '*.jpg'));

% 2. YOLOv2 modelini yükle
load('trainedYOLOv2Detector.mat', 'detector');

% 3. SAM modelini yükle
model = segmentAnythingModel;

% 4. Tüm görüntüler için işlem yap
for k = 1:length(imageFiles)
    % Görüntü yolunu al ve oku
    imagePath = fullfile(imageFolder, imageFiles(k).name);
    testImage = imread(imagePath);

    % YOLOv2 ile tümör tespiti
    [bboxes, scores, labels] = detect(detector, testImage);

    % Tespit edilemezse tüm görüntüyü al
    if isempty(bboxes)
        bbox = [1, 1, size(testImage,2), size(testImage,1)];
        disp(['Tümör tespit edilemedi: ', imageFiles(k).name]);
    else
        bbox = bboxes(1,:); % İlk kutuyu al
    end

    % SAM ile embedding çıkar
    embeddings = model.extractEmbeddings(testImage);
    imageSize = size(testImage);

    % SAM ile segmentasyon yap
    masks = model.segmentObjectsFromEmbeddings(embeddings, imageSize, BoundingBox=bbox);

    % Sonuçları göster
    figure;
    imshow(testImage);
    hold on;
    for i = 1:size(masks,3)
        visboundaries(masks(:,:,i), 'Color', 'r', 'LineWidth', 2);
    end
    hold off;
    title(['Segmentasyon: ', imageFiles(k).name]);
end