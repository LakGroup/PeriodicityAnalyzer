function Segment = createSegmentsEndpoints(IndividualImages,endPoints,actualEndpoints,pathLengths,Settings)

% Loop over all the images.
finalPaths = cell(1,numel(IndividualImages));
allSegments = cell(1,numel(IndividualImages));
currentPathLength = cell(1,numel(IndividualImages));
for i = 1:numel(IndividualImages)

    % Extract the skeleton image of the current object and the
    % other parameters.
    skeletonImage = bwmorph(IndividualImages{i},'thin',Inf);
    currentEndpoints = endPoints{i};

    finalPaths{i} = cell(1,size(actualEndpoints{i},1));
    allSegments{i} = cell(1,size(actualEndpoints{i},1));
    currentPathLength{i} = cell(1,size(actualEndpoints{i},1));
    for j = 1:size(actualEndpoints{i},1)

        % Perform the calculation for the specific pre-specified
        % axon by endpoints.
        currentPathLength{i}{j} = NaN(size(pathLengths{i}));
        currentPathLength{i}{j}(actualEndpoints{i}(j,1),actualEndpoints{i}(j,2)) = pathLengths{i}(actualEndpoints{i}(j,1),actualEndpoints{i}(j,2));
        [finalPaths{i}{j},allSegments{i}{j}] = segmentSplitter(skeletonImage,currentEndpoints,currentPathLength{i}{j},Settings,2);

    end
    finalPaths{i} = sum(cat(3,finalPaths{i}{:}),3);
    allSegments{i} = horzcat(allSegments{i}{:});

end

% Combine all the data for the image.
allSegments = horzcat(allSegments{:});
allPaths = sum(cat(3,finalPaths{:}),3);

% Calculate the coordinates of the segments on the Mask.
positionsPolygon = extractPolygons(allSegments,size(IndividualImages{1}),Settings);

% Dilate the path to make sure that it covers the axons.
dilatedPaths = imdilate(allPaths,strel('disk',Settings.dilationDiskSize));

% Create the overlay image of the mask.
overlay = bwboundaries(dilatedPaths,'noholes');

% Save all the outputs.
Segment.segmentPositions = positionsPolygon;
Segment.segmentPath = allPaths;
Segment.finalMask = dilatedPaths;
Segment.pathLengths = pathLengths;
Segment.endPoints = endPoints;
Segment.skeletonImages = finalPaths;
Segment.overlay = overlay;
Segment.settings = Settings;
Segment.actualEndpoints = actualEndpoints;
Segment.IndividualImages = IndividualImages;