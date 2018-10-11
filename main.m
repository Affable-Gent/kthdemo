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

convertGray = 1; % Should the video be converted to greyscale
resize = [160,160]; % Takes a 1x2 double mat e.g. [160,160] or 0 for false
skipFrame = 3; % Only read every nth frame, 0 to disable skipping
shutdownParallel = 0;

%% Set Variables
% Do not change if you don't know what you're doing
origin = pwd;
pathToMacScript = fullfile(pwd,'modernize.sh');
fileExt = '.avi';
pathSuffix='avi\';
pathname = fullfile(rootpath,dataset,'\');
jpgPath = fullfile(pathname,'jpg');
datasets={'test' 'train'};

%% Setup Parallel Computation
% Uses default 'local' profile available in parallel compute preferences
poolObj = gcp;
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
    mkdir pathName mov;
    for i=1:length(actions)
        strCommandLine = strcat(pathToMacScript, " '",fullfile(pathname,'avi',actions(i).name),"' '",fullfile(pathname,'mov',actions(i).name),"'")
        system(strCommandLine);
    end
    fileExt = '.mov';
    pathSuffix='mov/';
end

%% Jpg extraction check
exists = exist(fullfile(pathname,'jpg'), 'dir');
if exists && ~skipCheck
    prompt = 'It appears that the folders may have already been created and images have already been process. Doing this process again without deleting the old jpg folder may conflict with the accuracy of the datase. Would you still like to run the image extraction. Y/N [N]: ';
    str = input(prompt,'s');
    if str == 'Y'
        exists = 0;
    end
end
if ~exists
    %% Make directories if they do not exist
    mkdir(pathname,'jpg');
    for i=1:length(datasets)
        mkdir(jpgPath,string(datasets(i)));
        setPath = fullfile(jpgPath,string(datasets(i)));
        for j=1:length(actions)
            mkdir(setPath,actions(j).name);
        end
    end
    
    %% Generate Training and Test set
    wildcard = strcat('*',fileExt);
    clear allFiles;
    if exist(fullfile(pathname, 'allFiles.mat'), 'file');
        load(fullfile(pathname, 'allFiles.mat'), 'allFiles');
    else
        for j=1:length(actions)
            currentClass = dir(fullfile(pathname,pathSuffix,actions(j).name, wildcard));
            for i=1:length(currentClass)
                if rand > trainSetSize
                    class = string(datasets(1));
                else
                    class = string(datasets(2));
                end
                currentClass(i).set = class;
                currentClass(i).action = actions(j).name;
            end
            
            if ~exist('allFiles','var')
                allFiles = currentClass;
            else
                allFiles = [allFiles; currentClass];
            end
        end
        save(fullfile(pathname, 'allFiles.mat'), 'allFiles');
        
    end
    
    %% Extract Video to Jpg
    parfor i=1:length(allFiles)
        extractVideo(jpgPath, allFiles(i).action, allFiles(i).set, allFiles(i).folder, allFiles(i).name, peopleDetectorScore, convertGray, resize, skipFrame);
    end
else
    if exist(fullfile(pathname,'allFiles.mat'), 'file');
        load(fullfile(pathname,'allFiles.mat'),'allFiles')
    end
end

%% Train Bag of Words
exists = exist(fullfile(pathname,'svmBoWClassifier.mat'), 'file');
if exists && ~skipCheck
    prompt = 'It appears that there is already a classifier present. Would you still like to run the BoW classifier? Y/N [N]: ';
    str = input(prompt,'s');
    if str == 'Y'
        exists = 0;
    else
        load(fullfile(pathname,'svmBoWClassifier.mat'),'svmClassifier')
    end
end
if ~exists
    trainBOW(jpgPath, actions, validationSetSize, datasets(2), pathname);
    load(fullfile(pathname,'svmBoWClassifier.mat'),'svmClassifier')
end

%% Classify dataset
exists = exist(fullfile(pathname,'svmClassifiedFiles.mat'), 'file');
if exists && ~skipCheck
    prompt = 'It appears that a dataset has already been classified. Would you still like to run the prediction on the test set ? Y/N [N]: ';
    str = input(prompt,'s');
    if str == 'Y'
        exists = 0;
    end
end
if ~exists
    predictor(allFiles, datasets(1), jpgPath, svmClassifier, pathname, actions)
end

%% Evaluate dataset
load(fullfile(pathname,'svmClassifiedFiles.mat'),'classifiedFiles');
evaluator(classifiedFiles, actions)

%% Close parallel computing cluster
if shutdownParallel
    delete(poolObj)
end