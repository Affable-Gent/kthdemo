function predictor(allFiles, set, imagePath, categoryClassifier, pathname, actions)
% Testing: sets variables without being passed
% load kthClassifier.mat categoryClassifier
% allFiles = allFiles;
% set = 'test';
% imagePath = jpgPath;
% clear classifiedFiles

% change type to string
set = string(set);

% for every video
for i = 1:length(allFiles)
    
    % compare the set of the video to that of the set used for prediction
    % e.g. test
    if strcmp(allFiles(i).set, set)
        % display output for user
        disp('* Currently classifying: ' + string(allFiles(i).name))
        
        % Create wildcard from video filename to list frames of video
        imgWildcard = strcat(allFiles(i).name,'*.jpg');
        m = fullfile(imagePath,set,allFiles(i).action, imgWildcard);
        
        % Create a list of frames in the acion folder
        n = dir(m);
        
        % Create an empty string array to hold frame labels
        imgLabels =  strings(1,length(n));
        
        % Create empty array for a frames scores
        sumScores = zeros(1,6);
        
        parfor j = 1:length(n)
            path = strcat(n(j).folder,'/',n(j).name);
            
            % read the image from disk
            img = imread(path);
            
            % Predict the class of the frame from the classifier
            [labelIdx, scores] = predict(categoryClassifier, img);
            
            % Add the score of each frame to the sumScores to give total
            % score for the video
            sumScores = sumScores + scores;
            tmp = categoryClassifier.Labels(labelIdx);
            imgLabels(j) = tmp;
        end
        % Average the score per video
        sumScores = sumScores ./ length(n);
        
        % Find the action with the greatest score
        index = find(sumScores==max(sumScores));
        
        % Assign the action to the video
        res = actions(index).name;
        disp(['Classified as: ' res])
        
        % Get the most common label from all frames
        % res = mode(imgLabels);
        
        % Build a struct that will hold the classified file details
        if ~exist('classifiedFiles', 'var')
            classifiedFiles = struct();
            pos = 1;
        else
            pos = length(classifiedFiles)+1;
            
        end
        
        % Copy video details and the classifications and scores to the new
        % struct
        classifiedFiles(pos).name = allFiles(i).name;
        classifiedFiles(pos).folder = allFiles(i).folder;
        classifiedFiles(pos).classified = char(res);
        classifiedFiles(pos).actual = allFiles(i).action;
        
        for j=1:length(actions)
            classifiedFiles(pos).(actions(j).name) = sumScores(1,j);
        end
        
        % freqTbl = tabulate(res);
        % tabulate(res);
        
    else
        
    end
    
end
% Save the struct (classifiedFiles) to disk
save(fullfile(pathname, 'svmClassifiedFiles.mat'), 'classifiedFiles');
end
