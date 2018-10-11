%% Readme
% Everyone contributed equally to the code and the project overall.

% Students:
% 98054998 Morgan Pollock
%
%
%
% 
%

% *Workspace Setup and folder
% The folder structure required for the classifier and dataset is as
% follows. Ideally the root directory is the C:/ drive as this means no
% variables need to be changed.

% C:\kth\avi\walking\{walking videos.avi}
% The structure denoted by the variables is rootpath\datasetName\{avi and jpeg folders}
%
% The avi folder must exist and contain folders labelled with each of the
% actions. For example, the KTH dataset when extracted from the downloaded
% zip files contains 6 folders each with the action label as the folder
% name. The code with will pull the folder names to label the videos and
% hence changing these folder names will change the label.
%
% *Video Extraction
%
%
% *Feature Extraction
% 
% 
% *Classifier Creation
%
% 
% *Prediction
%
%
% *Evaluation 
%

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
rootpath = 'C:/'; %This is the folder that contains the dataset folder
peopleDetectorScore = 0; %Value between 0 and 10; 0 disables peopleDetector
skipCheck = 0;
trainSetSize = 0.7; % total of 1
validationSetSize = 0.3; % total of 1
convertGray = 1; % Should the video be converted to greyscale
resize = [160,160]; % Takes a 1x2 double mat e.g. [160,160] or 0 for false
skipFrame = 3; % Only read every nth frame, 0 to disable skipping

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
    if exist('allFiles.mat', 'file');
        load(fullfile(pathname,'allFiles.mat'),'allFiles')
    end
end

%% Train Bag of Words
exists = exist(fullfile(pathname,'kthClassifier.mat'), 'file');
if exists && ~skipCheck
    prompt = 'It appears that there is already a classifier present. Would you still like to run the BoW classifier? Y/N [N]: ';
    str = input(prompt,'s');
    if str == 'Y'
        exists = 0;
    else
        load(fullfile(pathname,'svmBoWClassifier.mat'),'kthClassifier')
    end
end
if ~exists
    trainBOW(jpgPath, actions, validationSetSize, datasets(2), pathname);
end

%% Classify dataset
exists = exist(fullfile(origin,'svmClassifiedFiles.mat'), 'file');
if exists && ~skipCheck
    prompt = 'It appears that a dataset has already been classified. Would you still like to run the prediction on the test set ? Y/N [N]: ';
    str = input(prompt,'s');
    if str == 'Y'
        exists = 0;
    end
end
if ~exists
    predictor(allFiles, datasets(1), jpgPath, categoryClassifier, pathname)
end

%% Evaluate dataset
load(fullfile(pathname,'kthClassifiedFiles'),'classifiedFiles')
evaluator(classifiedFiles, actions)

%% Close parallel computing cluster
delete(poolObj)