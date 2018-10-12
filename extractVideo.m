function extractVideo(pathName, action, datasetType, filePath, fileName, score, gray, resize, skipFrame)

% set temp file path and file name to the video
f = fullfile(filePath, fileName);

% console ouptut for user
disp(['Generating image files from frame of: ' f]);

% initiate the built in VideoReader object
I = VideoReader(f);

% set the number of frames in the video
% this is an approximation based off the current time and fps
nFrames = I.numberofFrames;

% set the video height and width
vidHeight =  I.Height;
vidWidth =  I.Width;

% generate an empty struct that will store the extracted frames
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 1, 'uint8'),...
    'colormap', []);

% utilise the parallel compute loop to loop over each frame in the video
parfor k = 1:nFrames
    
    % check if frames should be skipped to increase extraction speed
     if ~skipFrame || ~mod(k, skipFrame)
         
        % read a frame from the video 
        currentFrame = read(I, k);
        
        if gray
            % if the frame should be converted to greyscale, run the process
            currentFrame = rgb2gray(currentFrame);
        end
        if resize
            % if the frame should be resized, resize
            currentFrame = imresize(currentFrame,resize);
        end
        
        % insert the frame into the image holder mov struct
        mov(k).cdata = currentFrame;
        
        % check if the personDetector should be used
        if  ~score || personDetector(mov(k).cdata, score)
            
            % if the frame contains a person or the personDetector is
            % skipped the inside of tis IF will run
            
            %create image name from the original video name and the frame
            %number
            imageName = strcat(fileName,'_',num2str(k),'.jpg');
            
            % set the full file path
            imageFullFile = fullfile(pathName,datasetType,action,imageName);
            
            % console ouptut for user
            disp(['Image created from frame: '+ imageFullFile])
            
            % check if the file already exists on disk and skipp if it does
            % otherwise write to disk
            if ~exist(imageFullFile, 'file');
                imwrite(mov(k).cdata,char(imageFullFile));
            else
                disp('Skipping, file already exists')
            end
        end
    end
end
end

