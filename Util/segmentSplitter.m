function [finalPath,Segments] = segmentSplitter(SkeletonImage,endPoints,Pathlength,Settings,ShortLong)

% Extract the settings. This is easier to work with.
pixelSize = Settings.pixelSize; % Pixel size of the original image, in µm (according to the ONI microscope).
segmentLength = Settings.segmentLength; % The length of the axon to consider for a single quantification, in µm.
distanceBetweenSegments = Settings.distanceBetweenSegments; % The distance between the boxes that consider a single axon, in µm.

% Calculate the actual path.
if ShortLong == 1
    [Length,Idx] = max(Pathlength(:));
elseif ShortLong == 2
    [Length,Idx] = min(Pathlength(:));
end
[point1, point2] = ind2sub(size(Pathlength),Idx);
Distance1 = bwdistgeodesic(SkeletonImage, endPoints(point1,2), endPoints(point1,1), 'quasi-euclidean');
Distance2 = bwdistgeodesic(SkeletonImage, endPoints(point2,2), endPoints(point2,1), 'quasi-euclidean');
Distance = round((Distance1 + Distance2)*8)/8;
Distance(isnan(Distance)) = inf;
finalPath = imregionalmin(Distance);

% Divide the path into different segments.
numSegments = floor(Length/ceil((segmentLength+distanceBetweenSegments)/pixelSize));
Segments = cell(1,numSegments);

pathImage = finalPath;
startPoint = [endPoints(point1,2) endPoints(point1,1)];
for j = 1:numSegments

    % Extract a segment that has a length equal to the one that was
    % specified in the initialization.
    Distance = bwdistgeodesic(pathImage, startPoint(1), startPoint(2), 'quasi-euclidean');
    currentSegment = Distance<(segmentLength/pixelSize);
    [yCoords,xCoords] = find(bwmorph(currentSegment,'endpoints'));
    if ~isempty(yCoords)
        Segments{j} = [xCoords,yCoords];
    else
        break;
    end

    % Determine the new starting point to continue the process. A few
    % pixels are skipped to leave some space between the boxes.
    SegmentIncludingSpace = Distance<=((segmentLength+distanceBetweenSegments)/pixelSize);
    pathImage(SegmentIncludingSpace) = 0;

    if nnz(pathImage) ~= 0

        % Determins the new starting points and check if it is different
        % from the final endpoint.
        [newEndPoints(:,2),newEndPoints(:,1)] = find(bwmorph(pathImage,'endpoints'));
        validNewPoints = setdiff(newEndPoints,[endPoints(point2,2) endPoints(point2,1)],'rows');

        if ~isempty(validNewPoints)
            startPoint = validNewPoints(1,:);
            newEndPoints = [];
        else
            break;
        end

    else

        break;

    end

end
Segments(cellfun(@isempty,Segments)) = [];