%% Clean Workspace
clear
clc
%% Variables that can be changed
mac = 0;
dataset='kth'; %Only option currently is KTH
pathname = 'C:/';
peopleDetectorScore = 5;
skipCheck = 0;
trainSetSize = 0.7; % total of 1

%% Set Variables
origin = pwd;
pathToMacScript = fullfile(pwd,'modernize.sh');
fileExt = '.avi';
pathSuffix='avi/';
pathname = fullfile(pathname,dataset,'/');
jpgPath = fullfile(pathname,'jpg');
datasets={'test' 'train'};

%% Script for Mac
if mac
    mkdir pathName mov
    system(pathToMacScript);
    fileExt = '.mov';
    pathSuffix='mov/';
end

%% Make directories if they do not exist
mkdir(pathname,'jpg');

% Get a list of all files and folders in this folder.
classifiers = dir(fullfile(pathname,pathSuffix));
% Get a logical vector that tells which is a directory.
dirFlags = [classifiers.isdir];
% Extract only those that are directories.
classifiers = classifiers(dirFlags);
% Remove Parent and Current Directories
classifiers(ismember( {classifiers.name}, {'.', '..'})) = [];
clear dirFlags

for i=1:length(datasets)
    mkdir(jpgPath,string(datasets(i)));
    setPath = fullfile(jpgPath,string(datasets(i)));
    for j=1:length(classifiers)
        mkdir(setPath,classifiers(j).name);
    end
end

%% Generate Training and Test set
wildcard = strcat('*',fileExt);
clear allFiles
for j=1:length(classifiers)
    currentClass = dir(fullfile(pathname,pathSuffix,classifiers(j).name, wildcard));
    for i=1:length(currentClass)
        if rand > trainSetSize
            class = string(datasets(1));
        else
            class = string(datasets(2));
        end
        currentClass(i).set = class;
        currentClass(i).action = classifiers(j).name;
    end
        
    if ~exist('allFiles','var')
        allFiles = currentClass;
    else
        allFiles = [allFiles; currentClass];
    end
end

%% Extract Video to Jpg
for i=1:length(allFiles)
    extractVideo(jpgPath, allFiles(i).action, allFiles(i).set, allFiles(i).folder, allFiles(i).name, peopleDetectorScore);
end
%% Train Bag of Words
exists = exist(fullfile(origin,'kthClassifier.mat'), 'file');
if exists && ~skipCheck
    prompt = 'It appears that there is already a classified file present. Would you still like to run the BoW classifier? Y/N [N]: ';
    str = input(prompt,'s');
    if str == 'Y';
        exists = 0;
    end
end
if ~exists
    trainBOW(jpgPath);
end

%%

