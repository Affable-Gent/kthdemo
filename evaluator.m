function evaluator(classifiedFiles, actions)


c = confusionmat(string({classifiedFiles.actual}), string({classifiedFiles.classified}));
disp(c)

correctlyClassified = 0;
for i=1:length(classifiedFiles)
    if strcmp(classifiedFiles(i).actual, classifiedFiles(i).classified)
        correctlyClassified = correctlyClassified +1;
    end
end
accuracy = correctlyClassified / length(classifiedFiles)

end