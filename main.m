% The readme is available in this folder written in markdown however it is
% best viewed on the github page.
%
% https://github.com/LizLiu01/kthdemo/tree/morgansChanges
%% Dataset
% The KTH dataset is available at:
% http://www.nada.kth.se/cvap/actions/

%% Toolboxes
% Required: Computer Vision System Toolbox
% Required: Statistics and Machine Learning Toolbox

% Desireable: Parallel Computing Toolbox

%% Clean Workspace
clear
clc

%% Variables that can be changed
% Set this value to 1 if running on a mac, the process is the same however it will convert the avi files to mov to allow the videos to be viewable without additional codecs.
mac = 0;

% Only option currently available is KTH % This will change the folder that the dataset is contained within
dataset='kth';

% This is the folder that contains the dataset folder
rootpath = 'C:/';

% Set sensitivity of person detector, setting to 0 will disable
% It allows for only frames with people to be included however it severely
% slows down video extraction times.
% https://au.mathworks.com/help/vision/ref/detectpeopleacf.html
peopleDetectorScore = 0;

% A quick variable that when set to 1 will not run the overwrite checks in
% place through the code.
% We suggest leaving this set to 0
skipCheck = 0; %

%This is the proportion of the total dataset to be used as the training
%set, 1 - trainSetSize will give the test set proportion.
trainSetSize = 0.7; % 0 < x <= 1

%This is the proportion of the training dataset to be used as the
%validation set, 1 - validationSetSize will give the training set proportion.
validationSetSize = 0.3; % 0 < x <= 1

% Should the video be converted to greyscale.
% The KTH dataset is an rgb video but is in greyscale. Set to 1 to reduce
% rgb image to greyscale to reduce image size and training times but
% possibly reduce accuracy
convertGray = 1;

% Takes a 1x2 double mat e.g. [160,160] or 0 for false
% Useful for reducing the size of images
resize = [160,160];

% Another dataset reduction technique
% Only read every nth frame when converting video to frames, 0 to disable skipping
skipFrame = 3;

% 1 to enable the parallel compute cluster to shutdown after the process is
% complete. Setting to 0 will leave it running until it times out.
% Useful for testing/debugging
shutdownParallel = 1;

%% Set Variables
% Do not change unless you know what you're doing

% sets an orgin
% Variable is not used but may be useful if classification technique
% requires external binaries and the pwd must be changed
origin = pwd;

% Path to the mac modernizer script
pathToMacScript = fullfile(pwd,'modernize.sh');

% This is the default video format
fileExt = '.avi';

% The path suffix for where the videos are stored
pathSuffix='avi\';

% The default path for the entire code
% Typically C:\kth\
pathname = fullfile(rootpath,dataset,'\');

% Set the jpg path as one folder deeper than the pathname
jpgPath = fullfile(pathname,'jpg');

% store data sets as variables
% reduces the chance of incorrectly referencing the string
datasets={'test' 'train'};

%% Setup Parallel Computation
% Uses default 'local' profile available in parallel compute preferences
poolObj = gcp;

% Ensure that the extractVideo function is available to the parallel loop
addAttachedFiles( poolObj, {'extractVideo.m'})

%% Get list of actions
% Get a list of all files and folders in this folder.
actions = dir(fullfile(pathname,pathSuffix));
% Get a logical vector that tells which is a directory.
dirFlags = [actions.isdir];
% Extract only those that are directories.
actions = actions(dirFlags);
% Remove Parent and Current Directories
actions(ismember( {actions.name}, {'.', '..'})) = [];
clear dirFlags

%% Script for Mac
if mac
    % Create mov folder
    mkdir pathName mov;
    
    % For each action
    for i=1:length(actions)
        % Replicate the avi folder in mov
        strCommandLine = strcat(pathToMacScript, " '",fullfile(pathname,'avi',actions(i).name),"' '",fullfile(pathname,'mov',actions(i).name),"'")
        system(strCommandLine);
    end
    % Change the default video file extension
    fileExt = '.mov';
    % change the default video folder reference
    pathSuffix='mov/';
end

%% Jpg extraction check

% Check if jpg folder exists
% If the folder exists, the allFiles.mat should exists as it declares which
% videos belong to which test. If the jpg folder exists but not
% allFiles.mat, the jpg folder should be deleted and the process of video
% extraction rerun.
exists = exist(fullfile(pathname,'jpg'), 'dir');
if exists && ~skipCheck
    prompt = 'It appears that the folders may have already been created and images have already been processed. Doing this process again without deleting the old jpg folder may conflict with the accuracy of the dataset. Would you still like to run the image extraction. Y/N [N]: ';
    str = input(prompt,'s');
    if str == 'Y'
        exists = 0;
    end
end
if ~exists
    %% Make directories if they do not exist
    
    %
    dirJpg = strcat(pathname,'jpg');
    mkdir(dirJpg);
    
    % for each dataset type (e.g, train, test)
    for i=1:length(datasets)
        % create directory paths from sets
        datasetDir = strcat(jpgPath,'/',string(datasets(i)));
        
        % convert to character vector
        datasetDir = convertStringsToChars(datasetDir);
        
        % create directories
        mkdir(datasetDir);
        
        % for each action
        for j=1:length(actions)
            
            % create directory paths from actions
            mkdir(datasetDir,actions(j).name);
        end
    end
    
    %% Generate Training and Test set
    
    % create a wildcard in in the format '*.avi' dependent upon the default
    % video file extension
    wildcard = strcat('*',fileExt);
    
    % if allFiles exists in memory, remove it
    clear allFiles;
    
    % check if the allFiles.mat exists in the main path.
    %  e.g C:\kth\allfiles.mat
    if exist(fullfile(pathname, 'allFiles.mat'), 'file');
        
        % if the files exists, load it into the workspace
        load(fullfile(pathname, 'allFiles.mat'), 'allFiles');
    else
        
        % for each action
        for j=1:length(actions)
            
            % create a struct that contains every video file for the
            % current action
            currentClass = dir(fullfile(pathname,pathSuffix,actions(j).name, wildcard));
            
            % foe each video in the current action
            for i=1:length(currentClass)
                
                % the videos need to be randomly assigned a set
                % (e.g. train, test)
                %
                % rand will create a uniformly random value between 0 and 1
                % and test if the random number is above or below the
                % training set size and assign the set name to the video
                %
                % e.g. (rand = 0.9) > (trainSetSize = 0.7)
                % therefore assign to test.
                % a is a temporary variable
                
                if rand > trainSetSize
                    
                    % assign to test
                    a = string(datasets(1));
                else
                    
                    % assign to train
                    a = string(datasets(2));
                end
                
                % assign the set to the video in the list of videos
                currentClass(i).set = a;
                
                % assign the action to the video in the list of videos
                % this will set its actual value
                currentClass(i).action = actions(j).name;
            end
            
            % check if the allFiles struct exists
            if ~exist('allFiles','var')
                
                % if it doesn't exists, create it and assign the list of
                % videos for the current action to it
                allFiles = currentClass;
            else
                
                % if it does exists, append the current actions list to it
                allFiles = [allFiles; currentClass];
            end
        end
        
        % save the allFiles list to disk
        save(fullfile(pathname, 'allFiles.mat'), 'allFiles');
        
    end
    
    %% Extract Video to Jpg
    
    % parfor is a parallel computing for loop that will run multithreaded
    % if the toolbox is not exist it will rever to a regular for loop
    
    % for each video in the entire dataset
    parfor i=1:length(allFiles)
        
        % run the extract video process to convert the video frames to
        % individual jpgs and save them to disk
        extractVideo(jpgPath, allFiles(i).action, allFiles(i).set, allFiles(i).folder, allFiles(i).name, peopleDetectorScore, convertGray, resize, skipFrame);
    end
else
    % check if allFiles.mat exists
    if exist(fullfile(pathname,'allFiles.mat'), 'file');
        
        % if it exists, load it into memory
        load(fullfile(pathname,'allFiles.mat'),'allFiles')
    end
end

%% Train Bag of Words

% check if the SVM classifier already exists
exists = exist(fullfile(pathname,'svmBoWClassifier.mat'), 'file');

if exists && ~skipCheck
    % If it exists, check if it should be recreated and overwritten.
    prompt = 'It appears that there is already a classifier present. Would you still like to run the BoW classifier? Y/N [N]: ';
    str = input(prompt,'s');
    if str == 'Y'
        exists = 0;
    else
        % if it is not to be overwritten, load it from disk to memory
        load(fullfile(pathname,'svmBoWClassifier.mat'),'svmClassifier')
    end
end
if ~exists
    
    % if the SVm classifier does not exists run the training process that
    % includes generating a bag of features and running the classifier
    trainBOW(jpgPath, actions, validationSetSize, datasets(2), pathname);
    
    % after the process completes, load the save SVM classifier back into
    % memory after saving to disk.
    load(fullfile(pathname,'svmBoWClassifier.mat'),'svmClassifier')
end

%% Classify dataset

% check if the 'test' set as been classified into the file svmClassifiedFiles.mat
exists = exist(fullfile(pathname,'svmClassifiedFiles.mat'), 'file');
if exists && ~skipCheck
    prompt = 'It appears that a dataset has already been classified. Would you still like to run the prediction on the test set ? Y/N [N]: ';
    str = input(prompt,'s');
    if str == 'Y'
        exists = 0;
    end
end
if ~exists
    
    % if it does not exist or should be overwritten, run the prediction
    % process that uses the SVM classifier to classify features of the test
    % set and save these predictions
    predictor(allFiles, datasets(1), jpgPath, svmClassifier, pathname, actions)
end

%% Evaluate dataset

% check if the list of predicted/classified video files exists
exists = exist(fullfile(pathname,'svmClassifiedFiles.mat'), 'file');

if exists
    
    % if the evaluated files exists, load them into memory
    load(fullfile(pathname,'svmClassifiedFiles.mat'),'classifiedFiles');
    
    % run the evaluation stage on the classified videos.
    evaluator(classifiedFiles, actions)
end

%% Close parallel computing cluster

% check if the parallel compute cluster should be shutdown
if shutdownParallel
    
    % if it should, shutdown the cluster
    delete(poolObj)
end