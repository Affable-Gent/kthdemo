function predictor(allFiles, set, imagePath, categoryClassifier, pathname)
% Testing: sets variables without being passed
% load kthClassifier.mat categoryClassifier
% allFiles = allFiles;
% set = 'test';
% imagePath = jpgPath;
% clear classifiedFiles

set = string(set); % change type to string
for i = 1:length(allFiles)
    if strcmp(allFiles(i).set, set)
        setSize = setSize + 1; % Add to the counter
        disp('Currently classifying: ' + string(allFiles(i).name))
        
        imgWildcard = strcat(allFiles(i).name,'*.jpg');
        m = fullfile(imagePath,set,allFiles(i).action, imgWildcard);
        n = dir(m);
        imgLabels =  strings(1,length(n));
        
        sumScores = zeros(1,6);
        parfor j = 1:length(n)
            path = strcat(n(j).folder,'/',n(j).name);
            img = imread(path);
            [labelIdx, scores] = predict(categoryClassifier, img);
            % Add the score of each frame to the sumScores
            sumScores = sumScores + scores;
            tmp = categoryClassifier.Labels(labelIdx);
            imgLabels(j) = tmp;
        end
        % Average the score per video
        sumScores = sumScores ./ length(n)
        index = find(sumScores==max(sumScores))
        res = actions(index).name
        
        % Get the most common label from all frames
        res = mode(imgLabels)
        
        % Build a struct that will hold
        if ~exist('classifiedFiles', 'var')
            classifiedFiles = struct();
            pos = 1;
        else
            pos = length(classifiedFiles)+1;
            
        end
        
        if strcmp(allFiles(i).action, res)
            correctlyClassified = correctlyClassified + 1;
        end
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
save(fullfile(pathname, 'svmClassifiedFiles.mat'), 'classifiedFiles');
a = correctlyClassified/setSize;
disp('The accuracy of the classifier on this set is: ' + string(a));

end
