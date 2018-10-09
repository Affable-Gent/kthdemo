function exists = personDetector(img, score)

detector = peopleDetectorACF;

[bboxes,scores] = detect(detector,img);
if scores > score
    exists = 1;
else
    exists = 0;
end


