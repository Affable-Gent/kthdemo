function scoring(allFiles, set, imagePath, categoryClassifier)

%TODO: Use the scores from each individual image as opposed to their final
%labels. Therefore we weight the strong signal frames over the weak

% Testing: sets variables without being passed
% load kthClassifier.mat categoryClassifier
% allFiles = allFiles;
% set = 'test';
% imagePath = jpgPath;
% clear classifiedFiles

set = string(set);
setSize = 0; % Counter
correctlyClassified = 0; % Counter
for i = 1:length(allFiles)
    if strcmp(allFiles(i).set, set)
        setSize = setSize + 1; % Add to the counter
        disp('Currently classifying: ' + string(allFiles(i).name))
        
        imgWildcard = strcat(allFiles(i).name,'*.jpg');
        m = fullfile(imagePath,set,allFiles(i).action, imgWildcard);
        n = dir(m);
        imgLabels =  strings(1,length(m));
        
        for j = 1:length(n)
            path = strcat(n(j).folder,'/',n(j).name);
            img = imread(path);
            [labelIdx, scores] = predict(categoryClassifier, img);
            tmp = categoryClassifier.Labels(labelIdx);
            imgLabels(j) = tmp;
        end
        
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
        classifiedFiles(pos).classified = res;
        classifiedFiles(pos).actual = allFiles(i).action;
        
        
        % freqTbl = tabulate(res);
        % tabulate(res);
        
    else
      
    end
    
end
save kthClassifiedFiles classifiedFiles
a = correctlyClassified/setSize;
disp('The accuracy of the classifier on this set is: ' + string(a));

end
