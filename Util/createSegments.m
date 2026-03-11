function Segment = createSegments(Mask,Settings)

% Extract the settings. This is easier to work with.
dilationDiskSize = Settings.dilationDiskSize; % The size of the dilation disk (circular, in any direction). Can be quite large (e.g., 3) to make sure the mask covers the localizations.

% Create the images of the individual objects.
IndividualImages = extractObjectImages(Mask.maskToDisplay);

% Loop over all the individual objects.
endPoints = cell(1,numel(IndividualImages));
finalPaths = cell(1,numel(IndividualImages));
allSegments = cell(1,numel(IndividualImages));
pathLength = cell(1,numel(IndividualImages));
skeletonImages = cell(1,numel(IndividualImages));
for i = 1:numel(IndividualImages)

    % Create segments. To do this, the longest path (ignoring the ends) inside
    % is first calculated.
    skeletonImages{i} = bwmorph(IndividualImages{i},'thin',Inf); % Create the skeleton.
    [EndpointsRows,EndPointsCols] = find(bwmorph(skeletonImages{i},'endpoints')); % Find the endpoints.
    endPoints{i} = [EndpointsRows,EndPointsCols];
    
    % Determine which segment is the longest one, endpoint to endpoint.
    % This is done on calculating each one with eachother, based on the
    % geodesic distance, and then selecting the longest one.
    pathLength{i} = zeros(numel(EndpointsRows),numel(EndpointsRows));
    for j = 1:numel(EndpointsRows)
        for k = j+1:numel(EndpointsRows)
            Distance1 = bwdistgeodesic(skeletonImages{i}, EndPointsCols(j), EndpointsRows(j), 'quasi-euclidean');
            Distance2 = bwdistgeodesic(skeletonImages{i}, EndPointsCols(k), EndpointsRows(k), 'quasi-euclidean');
            Distance = round((Distance1 + Distance2)*8)/8;
            Distance(isnan(Distance)) = inf;
            paths = imregionalmin(Distance);
            Pathlengths = Distance(paths);
            pathLength{i}(j,k) = Pathlengths(1);
        end
    end
        
    % Segment the mask according to the pre-specified size.
    [finalPaths{i},allSegments{i}] = segmentSplitter(skeletonImages{i},endPoints{i},pathLength{i},Settings,1);
    
end
allSegments = horzcat(allSegments{:});

% Calculate the coordinates of the segments on the Mask.
positionsPolygon = extractPolygons(allSegments,size(Mask.maskAll),Settings);

% Combine the paths into one image.
allPaths = sum(cat(3,finalPaths{:}),3);

% Dilate the path to make sure that it covers the axons.
dilatedPaths = imdilate(allPaths,strel('disk',dilationDiskSize));

% Create the overlay image of the mask.
overlay = bwboundaries(dilatedPaths,'noholes');

% Save all the outputs.
Segment.segmentPositions = positionsPolygon;
Segment.segmentPath = allPaths;
Segment.skeletonImages = skeletonImages;
Segment.finalMask = dilatedPaths;
Segment.pathLengths = pathLength;
Segment.endPoints = endPoints;
Segment.overlay = overlay;
Segment.settings = Settings;

end