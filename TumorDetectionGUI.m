function TumorDetectionApp
    % Ana figür
    fig = uifigure('Name', 'Tumor Detection GUI', 'Position', [100 100 600 500]);

    % Görüntü alanı
    ax = uiaxes(fig, 'Position', [150 20 300 300]);

    % Sonuç yazısı
    resultLbl = uilabel(fig, 'Text', '', ...
        'Position', [30 370 500 30], ...
        'FontSize', 14);

    % Model Seç dropdown
    lbl = uilabel(fig, 'Text', 'Model Seç:', 'Position', [160 430 70 22]);
    dd = uidropdown(fig, ...
        'Items', { ...
            'SqueezeNet (Low LR)', ...
            'SqueezeNet (High LR)', ...
            'MobileNet (Low LR)', ...
            'MobileNet (High LR)', ...
            'ResNet (Low LR)', ...
            'ResNet (High LR)', ...
            'Segmentasyon (SAM)'}, ...
        'Position', [230 430 200 22]);

    % Global benzeri paylaşılan değişken
    selectedImagePath = '';

    % Görüntü Seç butonu
    uibutton(fig, 'push', 'Text', 'Görüntü Seç', ...
        'Position', [30 420 100 30], ...
        'ButtonPushedFcn', @(btn,event) selectImage());

    % Tahmin Et butonu
    uibutton(fig, 'push', 'Text', 'Tahmin Et', ...
        'Position', [460 420 100 30], ...
        'ButtonPushedFcn', @(btn,event) analyzeImage());

    % --- Alt Fonksiyonlar ---
    function selectImage()
        [file, path] = uigetfile({'*.jpg;*.png'}, 'Görüntü Seç', ...
            'C:\Users\Asus\Desktop\brain_tumor_dataset_cleaned');
        if isequal(file, 0)
            return;
        end
        selectedImagePath = fullfile(path, file);
        im = imread(selectedImagePath);
        imshow(im, 'Parent', ax);
        resultLbl.Text = "Görüntü yüklendi. Şimdi 'Tahmin Et' tuşuna bas.";
    end

    function analyzeImage()
        if isempty(selectedImagePath)
            resultLbl.Text = "Lütfen önce bir görüntü seçin.";
            return;
        end

        selectedModel = dd.Value;
        modelPath = '';

        switch selectedModel
            case 'SqueezeNet (Low LR)'
                modelPath = 'C:\Users\Asus\Desktop\odev2_egitimler\trainedYOLOv2Detector_SqueezeNet_dusukayar.mat';
            case 'SqueezeNet (High LR)'
                modelPath = 'C:\Users\Asus\Desktop\odev2_egitimler\trainedYOLOv2Detector_SqueezeNet_yuksekayar.mat';
            case 'MobileNet (Low LR)'
                modelPath = 'C:\Users\Asus\Desktop\odev2_egitimler\trainedYOLOv2Detector_MobileNet_Dusukkayar.mat';
            case 'MobileNet (High LR)'
                modelPath = 'C:\Users\Asus\Desktop\odev2_egitimler\trainedYOLOv2Detector_MobileNet_Yuksekayar.mat';
            case 'ResNet (Low LR)'
                modelPath = 'C:\Users\Asus\Desktop\odev2_egitimler\trainedYOLOv2Detector_Resnet_Dusukayar.mat';
            case 'ResNet (High LR)'
                modelPath = 'C:\Users\Asus\Desktop\odev2_egitimler\trainedYOLOv2Detector_Restnet_Yüksekayar.mat';
            case 'Segmentasyon (SAM)'
                modelPath = 'C:\Users\Asus\Desktop\odev2_egitimler\tumor_segmentations.mat';
        end

        I = imread(selectedImagePath);

        if contains(modelPath, '.mat') && ~contains(modelPath, 'segmentations')
            % YOLO tahmini
            data = load(modelPath);
            detector = data.detector;
            [bboxes, scores] = detect(detector, I);
            if ~isempty(bboxes)
                detectedImg = insertObjectAnnotation(I, 'rectangle', bboxes, ...
                    strcat("Tümör: ", string(round(scores(1)*100)), "%"));
                imshow(detectedImg, 'Parent', ax);
                resultLbl.Text = sprintf("Tümör %.2f%% olasılıkla tespit edildi.", scores(1)*100);
            else
                imshow(I, 'Parent', ax);
                resultLbl.Text = "Tümör tespit edilmedi.";
            end
        else
            % SAM segmentasyonu
            data = load(modelPath);
            [~, name, ext] = fileparts(selectedImagePath);
            index = find(strcmp(data.allFileNames, [name ext]));

            if isempty(index) || isempty(data.allMasks{index})
                imshow(I, 'Parent', ax);
                resultLbl.Text = "Tümör tespit edilmedi (SAM).";
                return;
            end

            mask = data.allMasks{index};
            if iscell(mask), mask = mask{1}; end
            mask = double(mask);

            overlay = I;
            overlay(:,:,1) = uint8(double(I(:,:,1)) + 100 * mask);
            overlay(:,:,2) = uint8(double(I(:,:,2)) .* (1 - 0.5 * mask));
            overlay(:,:,3) = uint8(double(I(:,:,3)) .* (1 - 0.5 * mask));

            imshow(overlay, 'Parent', ax);

            % Eğer doğruluk bilgisi varsa
            if isfield(data, 'allScores') && ~isempty(data.allScores{index})
                score = data.allScores{index};
                resultLbl.Text = sprintf('Tümör segmentasyonu gösterildi (SAM) - %.2f%% doğruluk.', score * 100);
            else
                resultLbl.Text = 'Tümör segmentasyonu gösterildi (SAM).';
            end
        end
    end
end

