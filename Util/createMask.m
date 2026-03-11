function Mask = createMask(Image,Settings)

% Extract the settings. This is easier to work with.
% Mask determination parameters.
contrastPerc = Settings.contrastPerc; % The percentage for contrast (0-1).
minSizeObject = Settings.minSizeObject; % The minimum size of an object to keep it. Not too low, but not too high either to keep axons connected in the end.
maxCircularity = Settings.maxCircularity; % The maximum circularity of the object. A value between 0 (straight line) and 1 (perfect circle). This can be quite stringent (0.2 has worked well in practise for our applications).
numAxons = Settings.numAxons; % The number of axons to keep.

% Create the mask of the image. An image segmentation based on K-means
% clustering is used to achieve the initial segmentation. This has
% worked well in the current application and conditions.
% A security is built in to make sure that a mask can be detected, and
% not "everything" is considered the mask. This is kind of a
% work-around, but should be good enough for this data.
SumPerc = 100;
while SumPerc >= 50
    if SumPerc == 100
        actualContrastPerc = contrastPerc;
    else
        actualContrastPerc = actualContrastPerc / 2;
    end
    adjustedImage = imadjust(mat2gray(Image),stretchlim(mat2gray(Image),actualContrastPerc)); % Image adjust clips the top and bottom x % intensity values.
    kMeansPrediction = imsegkmeans(single(adjustedImage),2); % 2 groups: foreground and background.
    tmp = zeros(size(adjustedImage));
    tmp(kMeansPrediction==2) = 1;

    SumPerc = sum(tmp(:))/numel(tmp)*100;
end

% Clean up the mask so we get just the axon objects.
% We first remove small objects, then dilate the mask. After that, the
% circular objects are being removed, and then only the object with the
% largest major axis is retained.
tmp = bwareaopen(tmp,minSizeObject); % Remove small objects.
CC = bwconncomp(tmp,4); % Extract the properties for the different objects (4-pixel neighborhood).
Props = regionprops('table',CC, 'Circularity'); % Calculate the circularity of the objects.
maskAll = cc2bw(CC,ObjectsToKeep=(Props.Circularity<maxCircularity)); % Only select the objects that fulfill the non-circularity requirement.
mask = bwpropfilt(maskAll,'MajorAxisLength',numAxons); % Only retain the object with the longest major axis length.

% Save all the outputs.
Settings.contrastPerc = actualContrastPerc;
Mask.maskAll = maskAll;
Mask.maskToDisplay = mask;
Mask.settings = Settings;

end