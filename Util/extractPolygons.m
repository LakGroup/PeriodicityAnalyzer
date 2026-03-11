function PositionsPolygons = extractPolygons(Segments,sizeImage,Settings)

% Extract the settings. This is easier to work with.
pixelSize = Settings.pixelSize; % Pixel size of the original image, in µm (according to the ONI microscope).
segmentLength = Settings.segmentLength; % The length of the axon to consider for a single quantification, in µm.
segmentWidth = Settings.segmentWidth; % The length of the axon to consider for a single quantification, in µm.

PositionsPolygons = cell(1,numel(Segments));
outsideBoundaryPolygons = false(1,numel(Segments));
for j = 1:numel(Segments)
    Angle = atan2(Segments{j}(2,2) - Segments{j}(1,2),Segments{j}(2,1) - Segments{j}(1,1));
    newPos = horzcat(Segments{j}(1,1) + floor(segmentLength/pixelSize) * cos(Angle),Segments{j}(1,2) + floor(segmentLength/pixelSize) * sin(Angle));
    OrigPosition = vertcat(Segments{j}(1,:),newPos);
    Pos1 = horzcat(OrigPosition(1,1) + floor((segmentWidth)/pixelSize) * sin(Angle),OrigPosition(1,2) - floor((segmentWidth)/pixelSize) * cos(Angle));
    Pos2 = horzcat(OrigPosition(1,1) - floor((segmentWidth)/pixelSize) * sin(Angle),OrigPosition(1,2) + floor((segmentWidth)/pixelSize) * cos(Angle));
    Pos3 = horzcat(OrigPosition(2,1) - floor((segmentWidth)/pixelSize) * sin(Angle),OrigPosition(2,2) + floor((segmentWidth)/pixelSize) * cos(Angle));
    Pos4 = horzcat(OrigPosition(2,1) + floor((segmentWidth)/pixelSize) * sin(Angle),OrigPosition(2,2) - floor((segmentWidth)/pixelSize) * cos(Angle));
    PositionsPolygons{j} = vertcat(Pos1,Pos2,Pos3,Pos4);

    % Check if the segments are within the image boundaries to avoid
    % problems later on.
    tmp = inpolygon(PositionsPolygons{j}(:,1),PositionsPolygons{j}(:,2),[1 1 sizeImage(2) sizeImage(2)],[1 sizeImage(1) sizeImage(1) 1]);
    outsideBoundaryPolygons(j) = (sum(tmp) == 4);
end
PositionsPolygons = PositionsPolygons(outsideBoundaryPolygons);