function IndividualImages = extractObjectImages(Image)

% Make a labeled image of the individual objects.
[labeledImage, numberOfBlobs] = bwlabel(Image);

% Extract the individual images of each of the objects.
IndividualImages = cell(1,numberOfBlobs);
for i = 1:numberOfBlobs
    IndividualImages{i} = zeros(size(labeledImage));
    tmp = labeledImage==i;
    IndividualImages{i}(tmp) = 1;
end