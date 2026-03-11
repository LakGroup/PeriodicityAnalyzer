function Data = calcPeriodicity(Data)

if ~isempty(Data)

    % Show a waitbar.
    wb = waitbar(0,['Performing calculations: ' num2str(0) '/' num2str(numel(Data))]);
    
    % Do the calculations for each of the data sets.
    for i = 1:numel(Data)

        % Update the waitbar.
        waitbar(i/numel(Data),wb,['Performing calculations: ' num2str(i) '/' num2str(numel(Data))]);
        drawnow;

        % Set the default mask settings.
        if ~isfield(Data{i},'mask') || ~isfield(Data{i}.mask,'settings')
            Data{i}.mask.settings.contrastPerc = 0.025;
            Data{i}.mask.settings.minSizeObject = 250;
            Data{i}.mask.settings.maxCircularity = 0.2;
            Data{i}.mask.settings.numAxons = 1;
        end
        
        % Set the default segment settings.
        if ~isfield(Data{i},'segments') || ~isfield(Data{i}.segments,'settings')
            Data{i}.segments.settings.pixelSize = 0.117;
            Data{i}.segments.settings.segmentLength = 3;
            Data{i}.segments.settings.segmentWidth = 2;
            Data{i}.segments.settings.distanceBetweenSegments = 0.5;
            Data{i}.segments.settings.dilationDiskSize = 5;
        end

        % Set the default periodicity quantification settings.
        if ~isfield(Data{i},'periodicity') || ~isfield(Data{i}.periodicity,'settings')
            Data{i}.periodicity.settings.pixelSize = Data{i}.segments.settings.pixelSize;
            Data{i}.periodicity.settings.pixelSize_Rendered = 0.003;
        end

        % Calculate the mask, segments, and quantify the periodicity
        % for that image.
        Data{i}.mask = createMask(Data{i}.data.maskImage,Data{i}.mask.settings);
        Data{i}.segments = createSegments(Data{i}.mask,Data{i}.segments.settings);
        Data{i}.periodicity = createPeriodicityImages(Data{i}.data.renderedImage,Data{i}.segments,Data{i}.periodicity.settings);
        Data{i}.periodicity = quantifyPeriodicity(Data{i}.periodicity,Data{i}.periodicity.settings);

    end

    % Close the waitbar.
    close(wb)

end