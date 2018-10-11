function trainBOW(path, actions, validationSetSize, set, rootPath)
% Testing: sets variables without being passed
% path = jpgPath
% validationSetSize = 0.3
% set = 'train'
% rootPath = pathname

set = string(set);
exists = exist(fullfile(path, set,'bof.mat'), 'file');
if exists
    load(fullfile(path, set,'bof.mat'),'bag', 'trainingSet', 'imds')
else
    
    datasetFolder = fullfile(path, set);
    
    % Pull the categories from the actions computed by folders
    categories = struct2cell(actions);
    categories = categories(1,:);
    
    imds = imageDatastore(fullfile(datasetFolder, categories), 'LabelSource', 'foldernames');
    
    tbl = countEachLabel(imds);
    disp(tbl)
    % determine the smallest amount of images in a category
    minSetCount = min(tbl{:,2});
    
    % Use splitEachLabel method to trim the set so that there are an equal number of images per category.
    imds = splitEachLabel(imds, minSetCount, 'randomize');
    
    disp(countEachLabel(imds));
    
    % Randomly split the datatstore into training and validation sets
    [trainingSet, validationSet] = splitEachLabel(imds, validationSetSize, 'randomize');
    
    % Testing: view examples from the training set
    % running = find(trainingSet.Labels == 'running', 1);
    % boxing = find(trainingSet.Labels == 'boxing', 1);
    % walking = find(trainingSet.Labels == 'walking', 1);
    %
    % subplot(1,3,1);
    % imshow(readimage(trainingSet,running))
    % subplot(1,3,2);
    % imshow(readimage(trainingSet,boxing))
    % subplot(1,3,3);
    % imshow(readimage(trainingSet,walking))
    
    % Computes a bag of features using SURF and then reduces these features using k-means clustering
    bag = bagOfFeatures(trainingSet, 'UseParallel', true, 'StrongestFeatures',0.8);
    % Save bag of features to the set directory (train) directory inside of
    % the jpg directory
    save(fullfile(path,set,'bof.mat'), 'bag', 'trainingSet', 'imds')
    
end
% % Testing: view a histogram of the transformed frames to features
% img = readimage(imds, 1);
% featureVector = encode(bag, img);
%
% % Plot the histogram of visual word occurrences
% figure
% bar(featureVector)
% title('Visual word occurrences')
% xlabel('Visual word index')
% ylabel('Frequency of occurrence')


% This is the training process that creates a classifier from the training
% set and features
svmClassifier = trainImageCategoryClassifier(trainingSet, bag, 'UseParallel', true);

save(fullfile(rootPath,'svmBoWClassifier.mat'), 'svmClassifier')

% confMatrix = evaluate(categoryClassifier, trainingSet);
% % Compute average accuracy
% mean(diag(confMatrix)); % Acuracy of 0.76
end