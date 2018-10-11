function extractVideo(pathName, action, datasetType, filePath, fileName, score, gray, resize, skipFrame)
f = fullfile(filePath, fileName);
disp(['Generating image files from frame of: ' f]);
I = VideoReader(f);

nFrames = I.numberofFrames;
vidHeight =  I.Height;
vidWidth =  I.Width;

mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 1, 'uint8'),...
    'colormap', []);

parfor k = 1:nFrames
     if ~skipFrame || ~mod(k, skipFrame)
        currentFrame = read(I, k);
        if gray
            currentFrame = rgb2gray(currentFrame);
        end
        if resize
            currentFrame = imresize(currentFrame,resize);
        end
        mov(k).cdata = currentFrame;
        
        if  ~score || personDetector(mov(k).cdata, score)
            imageName = strcat(fileName,'_',num2str(k),'.jpg');
            imageFullFile = fullfile(pathName,datasetType,action,imageName);
            disp(['Image created from frame: '+ imageFullFile])
            if ~exist(imageFullFile, 'file');
                imwrite(mov(k).cdata,char(imageFullFile));
            else
                disp('Skipping, file already exists')
            end
        end
    end
end
end

