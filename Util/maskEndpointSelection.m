function newData = maskEndpointSelection(Data)

% Show a confirmation dialog first that everything was done correctly.
Selection = questdlg('Is the mask in the ''Mask'' plot the correct one that you want to work on?','Mask by endpoint selection', 'Yes', 'No', 'No');
newData = Data;

% Only continue if 'Yes' is clicked.
switch Selection
    case 'No'

        return

    case 'Yes'

        % Make a new figure to show the data.
        maskEndpointFig = figure('Name','Mask by endpoint selection','NumberTitle','Off','Color','w','Units','Normalized','Position',[0.15 0.1 0.275 0.65],'Menubar','None','Toolbar','None','Resize','off');
        axData = axes(maskEndpointFig,'Units','Normalized','Position',[0.04,0.04,0.92,0.92],'Visible','Off');
        
        % Create the images of the individual axons.
        IndividualImages = extractObjectImages(Data.mask.maskToDisplay);

        % Extract some parameters.
        pixelSize = Data.segments.settings.pixelSize;

        % Loop over the individual objects to then select the right
        % endpoints for each of them.
        actualEndpoints = cell(1,numel(IndividualImages));
        for i = 1:numel(IndividualImages)

            % Extract the data to be plotted.
            imagePlot = mat2gray(IndividualImages{i});
    
            % Do the plotting of the object data.
            imagesc(axData,imagePlot);axis equal;axis tight;axis off;
            colormap(gray);
            line(axData,[size(imagePlot,2)*0.07 size(imagePlot,2)*0.07+5/pixelSize],[size(imagePlot,1)*0.975 size(imagePlot,1)*0.975],'LineWidth',5,'Color','w');
            text(axData,size(imagePlot,2)*0.07+5/pixelSize/2,size(imagePlot,1)*0.94,'5 µm','Color','w','FontUnits','Normalized','FontSize',0.04,'FontWeight','bold','HorizontalAlignment','center');

            % Plot the endpoints and specify the function for when a button
            % is pressed that it shows the identifier.
            hold on;
            endPointPlot = plot(axData,Data.segments.endPoints{i}(:,2),Data.segments.endPoints{i}(:,1),'.r','MarkerSize',20);
            endPointPlot.ButtonDownFcn = @showIdentifier;
            hold off

            % Create the input dialog for the axon selection.
            options.Resize = 'off';
            options.Interpreter = 'tex';
            options.WindowStyle = 'normal';
            input_values = inputdlg({'\fontsize{12}Please specify the desired start and end identifier(s) of the axons (e.g., [1 5; 2 4]): '},['Axon(s) start and end for object ' num2str(i) ' (Total endpoints: ' num2str(size(Data.segments.endPoints{i},1)) '):'],[1 110],{'[1 5; 2 4]'},options);
            
            % Wait for the dialog to be completed, and then save the actual
            % endpoint values.
            waitfor(input_values);
            if isempty(input_values)
                actualEndpoints{i} = [0 0];
            else
                actualEndpoints{i} = str2num(input_values{1});

                % Do a check on validity of the input values. If something
                % is wrong, show a message box saying so and then return to
                % the Segmentation Visualizer without making any changes to
                % the data.
                if any(actualEndpoints{i} > size(Data.segments.endPoints{i},1),'all') || any(actualEndpoints{i} < 0,'all')
                    waitfor(msgbox({'Invalid endpoint identifiers were provided. The module will be canceled.','To skip an object, please give [0 0] as input, or leave the input blank.'}));
                    close(maskEndpointFig);
                    return
                end
            end

        end

        % Check if none of the objects have to be done.
        if all(~all(vertcat(actualEndpoints{:}),2))
            waitfor(msgbox({'All objects were skipped. No calculations have to be performed. The module will be canceled.'}));
            close(maskEndpointFig);
            return
        end

        % Close the figure because it is not needed anymore.
        close(maskEndpointFig);

        % Perform the calculations for the new mask paths.
        wb = waitbar(0,'Performing calculations...');

        % Update the data to only recalculate the objects that have to be
        % recalculated.
        keepObjects = cellfun(@(x) all(x,'all'),actualEndpoints);
        IndividualImages = IndividualImages(keepObjects);
        endPoints = newData.segments.endPoints(keepObjects);
        pathLengths = newData.segments.pathLengths(keepObjects);
        actualEndpoints = actualEndpoints(keepObjects);

        % First perform the segment extraction.
        waitbar(0.25,wb,'Performing calculations...');
        drawnow
        Settings = newData.segments.settings;
        newData.segments = createSegmentsEndpoints(IndividualImages,endPoints,actualEndpoints,pathLengths,Settings);

        % Then perform the periodicity image extraction.
        Settings = newData.periodicity.settings;
        waitbar(0.5,wb,'Performing calculations...');
        drawnow
        newData.periodicity = createPeriodicityImages(newData.data.renderedImage,newData.segments,Settings);

        % Perform the periodicity image quantification.
        waitbar(0.75,wb,'Performing calculations...');
        drawnow
        newData.periodicity = quantifyPeriodicity(newData.periodicity,Settings);

        % Finish up.
        waitbar(1,wb,'Performing calculations...');
        drawnow
        pause(0.1)
        close(wb)

end

    function showIdentifier(endPointPlot, event)

        % Find the nearest endpoint.
        x = endPointPlot.XData;
        y = endPointPlot.YData;

        % Find the closest endpoint.
        selectedPoint = event.IntersectionPoint;
        selectedPoint = selectedPoint(1:2);
        endPointsPlotted = [x(:),y(:)];
        distanceToEndPoint = pdist2(selectedPoint,endPointsPlotted);
        [~, selectedEndPoint] = min(distanceToEndPoint);
        title(['Endpoint identifier: ' num2str(selectedEndPoint)])

    end

end