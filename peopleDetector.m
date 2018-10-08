
base_path = '/Users/LL/Downloads/kth/jpg/training/';
aa = dir(strcat(base_path,'running/*.jpg'));

detector = peopleDetectorACF;

for i = 1:length(aa)
  path = strcat(aa(i).folder,'/',aa(i).name);
  img = imread(path);
  [bboxes,scores] = detect(detector,img);
  if scores > 5
      copyfile(path,strcat(base_path,'running-new/',aa(i).name));
  end
end



