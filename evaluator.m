function evaluator(classifiedFiles, actions)

% Generate confustion matrix for classified files
c = confusionmat(string({classifiedFiles.actual}), string({classifiedFiles.classified}));
disp(c)

% Generate the accuracy of the classifier as a percentage of correctly
% identified files over total files
correctlyClassified = 0;
for i=1:length(classifiedFiles)
    if strcmp(classifiedFiles(i).actual, classifiedFiles(i).classified)
        correctlyClassified = correctlyClassified +1;
    end
end

disp('The accuracy for the classifier on this dataset is: ')
accuracy = correctlyClassified / length(classifiedFiles)

end