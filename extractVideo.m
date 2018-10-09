function extractVideo(pathName, action, datasetType, filePath, fileName, score)

    disp(fullfile(filePath, fileName));
    I = VideoReader(fullfile(filePath, fileName));
    
    nFrames = I.numberofFrames;
    vidHeight =  I.Height;
    vidWidth =  I.Width;
    
    mov(1:nFrames) = ...
        struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
        'colormap', []);
    
     for k = 1:nFrames
        mov(k).cdata = read(I, k);
        mov(k).cdata = imresize(mov(k).cdata,[256,256]);
        if personDetector(mov(k).cdata, score)
            imageName = strcat(fileName,'_',num2str(k),'.jpg');
            imagePath = fullfile(pathName,datasetType,action,imageName);
            disp(imagePath)
            imwrite(mov(k).cdata,char(imagePath));
        end
    end
end

