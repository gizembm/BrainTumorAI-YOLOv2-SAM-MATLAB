function data = augmentDataResnet(data)
    I = data{1};
    bbox = data{2};

    I = imresize(I, [224 224]); % ResNet50 için input boyutu
    if rand > 0.5
        I = fliplr(I);
        bbox(:,1) = size(I,2) - bbox(:,1) - bbox(:,3);
    end

    data{1} = I;
    data{2} = bbox;
end
