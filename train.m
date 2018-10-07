
outputFolder = fullfile('/Users/LL/Downloads/kth/', 'jpg'); 

trainFolder = fullfile(outputFolder, 'training');
testFolder = fullfile(outputFolder, 'test');

categories = {'boxing','handclapping','handwaving','jogging','running','walking'};
imds = imageDatastore(fullfile(trainFolder, categories), 'LabelSource', 'foldernames');

tbl = countEachLabel(imds)

minSetCount = min(tbl{:,2});

imds = splitEachLabel(imds, minSetCount, 'randomize');
 
[trainingSet, validationSet] = splitEachLabel(imds, 0.3, 'randomize');

bag = bagOfFeatures(trainingSet);

img = readimage(imds, 1);
featureVector = encode(bag, img);

categoryClassifier = trainImageCategoryClassifier(trainingSet, bag);

save kthClassifier categoryClassifier

