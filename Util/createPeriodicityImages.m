function Periodicity = createPeriodicityImages(Image,Segment,Settings)

% Extract the settings. This is easier to work with.
% Parameters related to the periodicity quantification.
pixelSize = Settings.pixelSize; % Pixel size of the original image, in µm (according to the ONI microscope).
pixelSize_Rendered = Settings.pixelSize_Rendered; % Pixel size of rendered image, in µm.

segmentPositions = Segment.segmentPositions; % The positions rectangles representing the segments.
dilatedPaths = Segment.finalMask; % The dilated skeleton images.

% Prepare the rendered image by masking it slightly. This is a
% 'finetuning' from the initial one.
upscaledMask = imresize(dilatedPaths,[size(Image,1),size(Image,2)]);

% Convert those coordinates to the rendered image coordinates and
% extract the data for the different segments.
finalImage = cell(1,numel(segmentPositions));
for i = 1:numel(segmentPositions)

    % Upscale the box coordinates and the mask.
    upscaledPositions = segmentPositions{i}*(pixelSize/pixelSize_Rendered);
    mask = poly2mask(upscaledPositions(:,1),upscaledPositions(:,2),size(Image,1),size(Image,2));
    props = regionprops(mask,'BoundingBox');
    boundingCoords = props.BoundingBox;

    % Make the cropped image so it is less memory intensive to work
    % with.
    croppedMask = upscaledMask(round(boundingCoords(2))+(1:boundingCoords(4)),round(boundingCoords(1))+(1:boundingCoords(3)));
    croppedImage_orig = Image(round(boundingCoords(2))+(1:boundingCoords(4)),round(boundingCoords(1))+(1:boundingCoords(3)),:);
    croppedImage = double(croppedImage_orig) .* croppedMask;

    % Rotate the image and the mask to align them horizontally.
    props = regionprops(croppedMask, 'Orientation','Area');
    if numel(props) > 1
        areaObjects = nan(1,numel(props));
        for j = 1:numel(props)
            areaObjects(j) = props(j).Area;
        end
        [~,idxMaxArea] = max(areaObjects);
        props = props(idxMaxArea);
    end
    rotatedCroppedMask = imrotate(croppedMask, -props.Orientation, 'bilinear', 'crop');
    rotatedCroppedImage = imrotate(croppedImage, -props.Orientation, 'bilinear', 'crop');

    % Make the bounding box smaller to exclude noisy signal.
    props = regionprops(rotatedCroppedMask, 'BoundingBox','Area');
    if numel(props) > 1
        areaObjects = nan(1,numel(props));
        for j = 1:numel(props)
            areaObjects(j) = props(j).Area;
        end
        [~,idxMaxArea] = max(areaObjects);
        props = props(idxMaxArea);
    end
    finalImage{i} = imcrop(rotatedCroppedImage, props.BoundingBox);

end

% Save all the outputs.
Periodicity.images = finalImage;
Periodicity.settings = Settings;