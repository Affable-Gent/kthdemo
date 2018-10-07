load kthClassifier

aa = dir('/Users/LL/Downloads/kth/jpg/training/handclapping/person11_handclapping_d1*')

res =  strings(1,length(aa));
for i = 1:length(aa)
  path = strcat(aa(i).folder,'/',aa(i).name);
  img = imread(path);
  [labelIdx, scores] = predict(categoryClassifier, img);
  tmp = categoryClassifier.Labels(labelIdx);
  res(i) = tmp;
end

tbl = tabulate(res)
tabulate(res)