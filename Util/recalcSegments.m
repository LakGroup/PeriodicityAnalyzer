function newData = recalcSegments(Data,Settings)

if ~isfield(Data,'actualEndpoints')
    % Extract the data that is needed for the calculations.
    skeletonImages = Data.skeletonImages;
    endPoints = Data.endPoints;
    pathLength = Data.pathLengths;
    dilationDiskSize = Settings.dilationDiskSize;
    
    % Segment the mask according to the pre-specified size.
    finalPaths = cell(1,numel(skeletonImages));
    allSegments = cell(1,numel(skeletonImages));
    for i = 1:numel(skeletonImages)
        [finalPaths{i},allSegments{i}] = segmentSplitter(skeletonImages{i},endPoints{i},pathLength{i},Settings,1);
    end
    allSegments = horzcat(allSegments{:});
    
    % Calculate the coordinates of the segments on the Mask.
    positionsPolygon = extractPolygons(allSegments,size(skeletonImages{1}),Settings);
    
    % Combine the paths into one image.
    allPaths = zeros(size(finalPaths{1}));
    for i = 1:numel(finalPaths)
        allPaths = allPaths + finalPaths{i};
    end
    allPaths = logical(allPaths);
    
    % Dilate the path to make sure that it covers the axons.
    dilatedPaths = imdilate(allPaths,strel('disk',dilationDiskSize));
    
    % Create the overlay image of the mask.
    overlay = bwboundaries(dilatedPaths,'noholes');

    % Save all the outputs.
    newData.segmentPositions = positionsPolygon;
    newData.segmentPath = allPaths;
    newData.finalMask = dilatedPaths;
    newData.pathLengths = pathLength;
    newData.skeletonImages = finalPaths;
    newData.endPoints = endPoints;
    newData.overlay = overlay;
    newData.settings = Settings;

else

    % Redo the things when the mask was created by the 'Mask by endpoints'
    % procedure.
    newData = createSegmentsEndpoints(Data.IndividualImages,Data.endPoints,Data.actualEndpoints,Data.pathLengths,Settings);

end

