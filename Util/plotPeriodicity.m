function Data = plotPeriodicity(Data)

% Calculate the mask that is being used to determine what is an axon and
% what is not. Only do this if there is no mask yet.
if ~isempty(Data)
    MasksCalculated = zeros(1,numel(Data));
    for i = 1:numel(Data)
        MasksCalculated(i) = isfield(Data{i},'mask') && isfield(Data{i},'segments') && isfield(Data{i},'periodicity') && numel(Data{i}.periodicity.autoCorrelationFunction) > 1;
    end
    doMasks = sum(MasksCalculated) ~= numel(Data);
end

if ~isempty(Data) & doMasks

    % Calculate the periodicity.
    Data(~MasksCalculated) = calcPeriodicity(Data(~MasksCalculated));

end

% Do the actual plotting of the mask.
if ~isempty(Data)

    % Create a new figure for the visualization.
    figPlot = figure('Name','Data Visualizer','NumberTitle','Off','Color','w','Units','Normalized','Position',[0.25 0.15 0.5 0.7],'Menubar','None','Toolbar','None','Resize','off','CloseRequestFcn',@close_callback);
    axPlotFigure = axes(figPlot,'Units','Normalized','Position',[0.05,0.15,0.4,0.725],'Visible','Off');
    axPlotProfile = axes(figPlot,'Units','Normalized','Position',[0.55,0.15,0.4,0.35],'Visible','Off');
    axPlotZoom = axes(figPlot,'Units','Normalized','Position',[0.55,0.55,0.4,0.35],'Visible','Off');

    % Set the name of the current data.
    nameText = uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.05,0.905,0.9,0.03],'String',Data{1}.name,'FontUnits','Normalized','FontSize',0.8,'FontWeight','bold','HorizontalAlignment','center');

    % Determine whether or not the file has multiple segments. If yes, then
    % show a slider on the side so that the visualization can be changed
    % between them.
    if numel(Data{1}.periodicity.autoCorrelationFunction) > 1
        sliderSecondaryStep = [1,1] ./ (numel(Data{1}.periodicity.autoCorrelationFunction)-1);
    else
        sliderSecondaryStep = [0.9 0.9];
    end
    if numel(Data{1}.periodicity.autoCorrelationFunction) ~= 0
        sliderSecondaryText = uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.55,0.01,0.4,0.03],'String',['Segment 1 / ' num2str(numel(Data{1}.periodicity.autoCorrelationFunction))],'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center');
    else
        sliderSecondaryText = uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.55,0.01,0.4,0.03],'String',['Segment 0 / ' num2str(0)],'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Visible','Off');
    end
    if numel(Data{1}.periodicity.autoCorrelationFunction) > 1
        sliderSecondary = uicontrol(figPlot,'Style','Slider','Units','Normalized','Position',[0.55,0.04,0.4,0.03],'Value',1,'Min',1,'Max',numel(Data{1}.periodicity.autoCorrelationFunction),'Sliderstep',sliderSecondaryStep,'Callback',{@sliderSecondary_callback});
    else
        sliderSecondary = uicontrol(figPlot,'Style','Slider','Units','Normalized','Position',[0.55,0.04,0.4,0.03],'Value',1,'Min',1,'Max',1,'Sliderstep',sliderSecondaryStep,'Visible','Off','Callback',{@sliderSecondary_callback});
    end
    
    % Determine whether or not multiple files were selected. If yes, then
    % show a slider on the side so that the visualization can be changed
    % between them.
    if numel(Data) > 1
        sliderStep = [1,1] ./ (numel(Data)-1);
        sliderText = uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.05,0.01,0.4,0.03],'String',['Dataset 1 / ' num2str(numel(Data))],'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center');
        slider = uicontrol(figPlot,'Style','Slider','Units','Normalized','Position',[0.05,0.04,0.4,0.03],'Value',1,'Min',1,'Max',numel(Data),'Sliderstep',sliderStep,'Callback',{@slider_callback});
    end
    
    % Toggle the segment rectangle indications on or off.
    boxHandles = [];
    textHandles = [];
    showSegmentBox = uicontrol(figPlot,'Style','togglebutton','String','Toggle Segments','Units','Normalized','Position',[0.025,0.95,0.2,0.04],'Value',0,'FontUnits','Normalized','FontSize',0.6,'FontWeight','bold','Callback',{@showSegmentToggle_callback});

    % Remove segments if needed.
    removeSegment = uicontrol(figPlot,'Style','togglebutton','String','Remove Segment','Units','Normalized','Position',[0.235,0.95,0.2,0.04],'Value',0,'FontUnits','Normalized','FontSize',0.6,'FontWeight','bold','Callback',{@removesegment_callback});

    % Save the plots.
    uicontrol(figPlot,'Style','togglebutton','String','Save Plots','Units','Normalized','Position',[0.445,0.95,0.15,0.04],'Value',0,'FontUnits','Normalized','FontSize',0.6,'FontWeight','bold','Callback',{@savePlots_callback});

    % Extract the Autocorrelation plots.
    uicontrol(figPlot,'Style','togglebutton','String','Extract ACFs','Units','Normalized','Position',[0.605,0.95,0.15,0.04],'Value',0,'FontUnits','Normalized','FontSize',0.6,'FontWeight','bold','Callback',{@extractACF_callback});
    
    % Do the actual plotting of the data.
    if ~isempty(Data{1})
        plotData(axPlotFigure,Data{1}.data,Data{1}.segments);
        if numel(Data{1}.periodicity.autoCorrelationFunction) >= 1
            plotSegments(axPlotZoom,axPlotProfile,Data{1}.periodicity,1)
        else
            cla(axPlotZoom,'reset');
            cla(axPlotProfile,'reset');
            axPlotZoom.Visible = 'Off';
            axPlotProfile.Visible = 'Off';
        end
    end

    % Create a new custom toolbar, only for the large figure.
    axtoolbar(axPlotFigure,{'zoomin','zoomout', 'pan','restoreview'});

    % Wait to go back to the browser and update the data.
    uiwait(figPlot)

end

    % Function that controls what happens when the plot is closed.
    function close_callback(~,~)
        uiresume(figPlot)
        delete(figPlot)
    end

    % Function that controls which data is being plotted.
    function slider_callback(~,~,~)
        % Determine which data should be shown and update the visualization
        % accordingly.
        slider_value = round(slider.Value);
        sliderText.String = ['Dataset ' num2str(slider_value) ' / ' num2str(numel(Data))];
        nameText.String = Data{slider_value}.name;

        % Update the secondary plots.
        if numel(Data{slider_value}.periodicity.autoCorrelationFunction) > 1
            sliderSecondary.Value = 1;
            sliderSecondary.Max = numel(Data{slider_value}.periodicity.autoCorrelationFunction);
            sliderSecondary.SliderStep = [1,1] ./ (numel(Data{slider_value}.periodicity.autoCorrelationFunction)-1);
            sliderSecondary.Visible = 'On';
            sliderSecondaryText.String = ['Segment 1 / ' num2str(numel(Data{slider_value}.periodicity.autoCorrelationFunction))];
            sliderSecondaryText.Visible = 'On';
        elseif numel(Data{slider_value}.periodicity.autoCorrelationFunction) == 0
            sliderSecondary.Value = 0;
            sliderSecondary.Max = numel(Data{slider_value}.periodicity.autoCorrelationFunction);
            sliderSecondary.SliderStep = [0.9,0.9];
            sliderSecondary.Visible = 'Off';
            sliderSecondaryText.Visible = 'Off';
        else
            sliderSecondary.Value = 1;
            sliderSecondary.Max = numel(Data{slider_value}.periodicity.autoCorrelationFunction);
            sliderSecondary.SliderStep = [0.9,0.9];
            sliderSecondary.Visible = 'Off';
            sliderSecondaryText.Visible = 'Off';
        end
        
        % Do the actual plotting according to the value that is currently
        % being requested.
        if ~isempty(Data{slider_value})
            plotData(axPlotFigure,Data{slider_value}.data,Data{slider_value}.segments)
            if numel(Data{slider_value}.periodicity.autoCorrelationFunction) >= 1
                plotSegments(axPlotZoom,axPlotProfile,Data{slider_value}.periodicity,1)
            else
                cla(axPlotZoom,'reset');
                cla(axPlotProfile,'reset');
                axPlotZoom.Visible = 'Off';
                axPlotProfile.Visible = 'Off';
            end
            if showSegmentBox.Value == 1

                boxHandles = [];
                textHandles = [];

                % do the plotting
                if numel(Data{slider_value}.periodicity.autoCorrelationFunction) >= 1
                    plotSegmentBoxes(axPlotFigure,Data{slider_value}.segments);
                end
            end
        end

    end

    % Function that controls which data is being plotted.
    function sliderSecondary_callback(~,~,~)
        % Determine which data should be shown and update the visualization
        % accordingly.
        if exist('slider','var') == 1
            slider_value = round(slider.Value);
        else
            slider_value = 1;
        end
        sliderSecondary_value = round(sliderSecondary.Value);
        if numel(Data{slider_value}.periodicity.autoCorrelationFunction) >= 1
            sliderSecondaryText.String = ['Segment ' num2str(sliderSecondary_value) ' / ' num2str(numel(Data{slider_value}.periodicity.autoCorrelationFunction))];
        end

        % Do the actual plotting according to the value that is currently
        % being requested.
        if numel(Data{slider_value}.periodicity.autoCorrelationFunction) >= 1
            plotSegments(axPlotZoom,axPlotProfile,Data{slider_value}.periodicity,sliderSecondary_value)
        else
            cla(axPlotZoom,'reset');
            cla(axPlotProfile,'reset');
            axPlotZoom.Visible = 'Off';
            axPlotProfile.Visible = 'Off';
        end
        if showSegmentBox.Value == 1
            if numel(Data{slider_value}.periodicity.autoCorrelationFunction) >= 1
                plotSegmentBoxes(axPlotFigure,Data{slider_value}.segments)
            end

        else
            % Reset the box and text handles to avoid errors.
            for j = 1:numel(boxHandles)
                set(boxHandles{j},'Visible','off');
                set(textHandles{j},'Visible','off');
            end
            boxHandles = [];
            textHandles = [];
        end
    end

    % Function that controls what to do when the segments are asked to be
    % plotted.
    function showSegmentToggle_callback(~,~,~)
        if showSegmentBox.Value == 1
            if exist('slider','var') == 1
                slider_value = round(slider.Value);
            else
                slider_value = 1;
            end
            if numel(Data{slider_value}.periodicity.autoCorrelationFunction) >= 1
                plotSegmentBoxes(axPlotFigure,Data{slider_value}.segments);
            end
        else
            % Reset the box and text handles to avoid errors.
            for j = 1:numel(boxHandles)
                set(boxHandles{j},'Visible','off');
                set(textHandles{j},'Visible','off');
            end
            boxHandles = [];
            textHandles = [];
        end
    end

    % Function that controls what to do when a segment should be removed.
    function removesegment_callback(~,~,~)
        % Reset the value (not strictly needed though as we just want it to
        % do something when it is pressed.
        removeSegment.Value = 0;

        % Retrieve the current segment from the data.
        if exist('slider','var') == 1
            slider_value = round(slider.Value);
        else
            slider_value = 1;
        end
        secondary_value = round(sliderSecondary.Value);

        % Remove the actual segment.
        if numel(Data{slider_value}.periodicity.autoCorrelationFunction) >= 1
            Data{slider_value}.periodicity.autoCorrelationFunction(secondary_value) = [];
            Data{slider_value}.periodicity.lags(secondary_value) = [];
            Data{slider_value}.periodicity.periodicity(secondary_value) = [];
            Data{slider_value}.periodicity.images(secondary_value) = [];
            Data{slider_value}.segments.segmentPositions(secondary_value) = [];
            boxHandles{secondary_value} = [];
            textHandles{secondary_value} = [];
        end

        % Update all the text and so on.
        if secondary_value ~= numel(Data{slider_value}.periodicity.autoCorrelationFunction)+1
            newValue = secondary_value;
        else
            newValue = numel(Data{slider_value}.periodicity.autoCorrelationFunction);
        end
        if numel(Data{slider_value}.periodicity.autoCorrelationFunction) > 1
            sliderSecondary.Max = numel(Data{slider_value}.periodicity.autoCorrelationFunction);
            sliderSecondary.SliderStep = [1,1] ./ (numel(Data{slider_value}.periodicity.autoCorrelationFunction)-1);
            sliderSecondary.Visible = 'On';
            sliderSecondary.Value = newValue;
            sliderSecondaryText.String = ['Segment ' num2str(newValue) ' / ' num2str(numel(Data{slider_value}.periodicity.autoCorrelationFunction))];
            sliderSecondaryText.Visible = 'On';
        elseif numel(Data{slider_value}.periodicity.autoCorrelationFunction) == 0
            sliderSecondary.Max = 1;
            sliderSecondary.SliderStep = [0.9,0.9];
            sliderSecondary.Visible = 'Off';
            sliderSecondary.Value = 0;
            sliderSecondaryText.Visible = 'Off';
        else
            sliderSecondary.Max = 1;
            sliderSecondary.SliderStep = [0.9,0.9];
            sliderSecondary.Visible = 'Off';
            sliderSecondary.Value = 1;
            sliderSecondaryText.Visible = 'Off';
        end        

        % Update the plots.
        plotData(axPlotFigure,Data{slider_value}.data,Data{slider_value}.segments)
        if numel(Data{slider_value}.periodicity.autoCorrelationFunction) >= 1
            plotSegments(axPlotZoom,axPlotProfile,Data{slider_value}.periodicity,newValue)
        else
            cla(axPlotZoom,'reset');
            cla(axPlotProfile,'reset');
            axPlotZoom.Visible = 'Off';
            axPlotProfile.Visible = 'Off';
        end
        boxHandles = [];
        textHandles = [];
        if numel(Data{slider_value}.periodicity.autoCorrelationFunction) >= 1 && showSegmentBox.Value == 1
            plotSegmentBoxes(axPlotFigure,Data{slider_value}.segments);
        end
    end

    % Function to save the figures as .png files.
    function savePlots_callback(~,~,~)
        saveFigures(Data,showSegmentBox);
    end

    % Function to extract the ACFs in a .xlsx file.
    function extractACF_callback(~,~,~)
        saveACFs(Data);
    end

    % Function that does the actual plotting.
    function plotData(currentAxis,Data,Segments)
        
        % Reset the axis.
        cla(currentAxis,'reset');

        % Adjust the image contrast.
        displayImage = imadjust(mat2gray(Data.maskImage),stretchlim(mat2gray(Data.maskImage),0.01));

        % Do the actual plotting of the data.
        axes(currentAxis)
        imagesc(currentAxis,displayImage);axis equal;axis tight;axis off;
        colormap(gray);
        hold on;
        for boundaryNum = 1:numel(Segments.overlay)
            plot(currentAxis,Segments.overlay{boundaryNum}(:,2),Segments.overlay{boundaryNum}(:,1), 'y-', 'LineWidth', 2);
        end

        % Plot a scalebar.
        line(currentAxis,[size(displayImage,2)*0.85 size(displayImage,2)*0.85+5/Segments.settings.pixelSize],[size(displayImage,1)*0.975 size(displayImage,1)*0.975],'LineWidth',5,'Color','w')
        text(currentAxis,size(displayImage,2)*0.85+5/Segments.settings.pixelSize/2,size(displayImage,1)*0.94,'5 µm','Color','w','FontUnits','Normalized','FontSize',0.03,'FontWeight','bold','HorizontalAlignment','center')
    end

    % Function that does the actual plotting for the secondary plots.
    function plotSegments(currentAxis1,currentAxis2,Periodicity,SegmentNumber)

        % Reset the axis.
        cla(currentAxis1,'reset');
        cla(currentAxis2,'reset');

        % Extract the images.
        displayImage = Periodicity.images{SegmentNumber};

        % Do the actual plotting of the data.
        axes(currentAxis1)
        imagesc(currentAxis1,displayImage);axis equal;axis tight;axis off;
        colormap(gray);
        
        % Plot a scalebar.
        line(currentAxis1,[size(displayImage,2)*0.8 size(displayImage,2)*0.8+0.5/Periodicity.settings.pixelSize_Rendered],[size(displayImage,1)*0.965 size(displayImage,1)*0.965],'LineWidth',5,'Color','w')
        text(currentAxis1,size(displayImage,2)*0.8+0.5/Periodicity.settings.pixelSize_Rendered/2,size(displayImage,1)*0.875,'500 nm','Color','w','FontUnits','Normalized','FontSize',0.125,'FontWeight','bold','HorizontalAlignment','center')

        % Plot the periodicity plot as well.
        axes(currentAxis2)
        plot(currentAxis2,Periodicity.lags{SegmentNumber}*1000,Periodicity.autoCorrelationFunction{SegmentNumber},'k','LineWidth',2)
        set(currentAxis2,'Linewidth',2,'FontUnits','Normalized','FontSize',0.075,'FontWeight','bold')
        axis tight;
        xlabel('Distance (nm)','FontUnits','Normalized','FontSize',0.075,'FontWeight','bold')
        ylabel('Autocorrelation','FontUnits','Normalized','FontSize',0.075,'FontWeight','bold')
        title(['Periodicity: ' num2str(round(Periodicity.periodicity{SegmentNumber}*1000,2)) 'nm'],'FontUnits','Normalized','FontSize',0.075,'FontWeight','bold');
        xlim([0 1000])
    end

    % Function that plots the segment boxes on their actual positions.
    function plotSegmentBoxes(currentAxis,Segments)
        % Plot the different segment boxes.
        for j = 1:numel(boxHandles)
            set(boxHandles{j},'Visible','off');
            set(textHandles{j},'Visible','off');
        end
        boxHandles = [];
        textHandles = [];

        % Do the actual plotting.
        if numel(Segments.segmentPositions) >= 1

            % Plot the segments.
            boxHandles = cell(1,numel(Segments.segmentPositions));
            for j = 1:numel(Segments.segmentPositions)
                if j == round(sliderSecondary.Value)
                    boxHandles{j} = drawpolygon(currentAxis,'Position',Segments.segmentPositions{j},'FaceAlpha',0.5,'Color','y','EdgeColor','y','InteractionsAllowed','none');
                else
                    boxHandles{j} = drawpolygon(currentAxis,'Position',Segments.segmentPositions{j},'FaceAlpha',0,'Color','b','InteractionsAllowed','none');
                end
                meanPos = mean(Segments.segmentPositions{j}([1 3],:));
                textHandles{j} = text(currentAxis,meanPos(1)-40,meanPos(2),num2str(j),'FontUnits','Normalized','FontSize',0.03,'Color','w','FontWeight','bold');
            end
        else
            % Reset the box and text handles to avoid errors.
            for j = 1:numel(boxHandles)
                set(boxHandles{j},'Visible','off');
                set(textHandles{j},'Visible','off');
            end
            boxHandles = [];
            textHandles = [];
        end
    end

end