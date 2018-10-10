

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
mac = 0;
dataset='kth'; %Only option currently is KTH
pathname = 'C:/'; %This is the folder that contains the dataset folder
peopleDetectorScore = 5;
skipCheck = 0;
trainSetSize = 0.7; % total of 1
validationSetSize = 0.3; % total of 1

%% Set Variables
% Do not change if you don't know what you're doing
origin = pwd;
pathToMacScript = fullfile(pwd,'modernize.sh');
fileExt = '.avi';
pathSuffix='avi\';
pathname = fullfile(pathname,dataset,'\');
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
    if exist('allFiles.mat', 'file');
        load allFiles
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
        save allFiles allFiles
    end
    
    %% Extract Video to Jpg
    parfor i=1:length(allFiles)
        extractVideo(jpgPath, allFiles(i).action, allFiles(i).set, allFiles(i).folder, allFiles(i).name, peopleDetectorScore);
    end
else
    if exist('allFiles.mat', 'file');
        load allFiles
    end
end

%% Train Bag of Words
exists = exist(fullfile(origin,'kthClassifier.mat'), 'file');
if exists && ~skipCheck
    prompt = 'It appears that there is already a classifier present. Would you still like to run the BoW classifier? Y/N [N]: ';
    str = input(prompt,'s');
    if str == 'Y'
        exists = 0;
    else
        load kthClassifier
    end
end
if ~exists
    trainBOW(jpgPath, actions, validationSetSize, datasets(2));
end

%% Classify dataset
exists = exist(fullfile(origin,'kthClassifiedFiles.mat'), 'file');
if exists && ~skipCheck
    prompt = 'It appears that a dataset has already been classified. Would you still like to run the prediction on the test set ? Y/N [N]: ';
    str = input(prompt,'s');
    if str == 'Y'
        exists = 0;
    end
end
if ~exists
    predictor(allFiles, datasets(1), jpgPath, categoryClassifier)
end

%% Evaluate dataset
load kthClassifiedFiles
evaluator(classifiedFiles, actions)

%% Close parallel computing cluster
delete(poolObj)