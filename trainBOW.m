function trainBOW(path, actions)

trainFolder = fullfile(path, 'train');
testFolder = fullfile(path, 'test');

categories = struct2cell(actions)
categories = categories(1,:)

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

