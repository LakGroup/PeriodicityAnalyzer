function newData = calcSegmentation(Data)

if ~isempty(Data)

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

    % Create a new figure for the visualization.
    figPlot = figure('Name','Segmentation Visualizer','NumberTitle','Off','Color','w','Units','Normalized','Position',[0.1 0.075 0.8 0.7],'Menubar','None','Toolbar','None','Resize','off','CloseRequestFcn',@close_callback);
    axData = axes(figPlot,'Units','Normalized','Position',[0.04,0.35,0.2,0.5],'Visible','Off');
    axMask = axes(figPlot,'Units','Normalized','Position',[0.28,0.35,0.2,0.5],'Visible','Off');
    axSegments = axes(figPlot,'Units','Normalized','Position',[0.52,0.35,0.2,0.5],'Visible','Off');
    axFinalSegments = axes(figPlot,'Units','Normalized','Position',[0.76,0.35,0.2,0.5],'Visible','Off');

    % Set the name of the current data.
    nameText = uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.2,0.96,0.6,0.03],'String',Data{1}.name,'FontUnits','Normalized','FontSize',0.8,'FontWeight','bold','HorizontalAlignment','center');
    scalebarLine = [];
    scalebarText = [];

    % Make the instructions buttons.
    uicontrol(figPlot,'Style','pushbutton','Units','Normalized','Position',[0.02,0.96,0.15,0.03],'FontUnits','Normalized','FontSize',0.5,'FontWeight','bold','String','General instructions','Enable','on','callback',{@instructions_callback});
    if isscalar(Data)
        uicontrol(figPlot,'Style','pushbutton','Units','Normalized','Position',[0.02,0.92,0.15,0.03],'FontUnits','Normalized','FontSize',0.5,'FontWeight','bold','String','Mask by endpoint instructions','Enable','on','callback',{@instructionsEndpoints_callback});
    end

    % Determine whether or not multiple files were selected. If yes, then
    % show a slider on the side so that the visualization can be changed
    % between them.
    if numel(Data) > 1
        sliderStep = [1,1] ./ (numel(Data)-1);
        sliderText = uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.25,0.89,0.5,0.03],'String',['Dataset 1 / ' num2str(numel(Data))],'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center');
        slider = uicontrol(figPlot,'Style','Slider','Units','Normalized','Position',[0.25,0.92,0.5,0.03],'Value',1,'Min',1,'Max',numel(Data),'Sliderstep',sliderStep,'HorizontalAlignment','center','Callback',{@slider_callback});
    else
        slider.Value = 1;
    end

    % Create a temporary settings and data variable.
    tmpData = Data;
    tmpMaskSettings = cell(1,numel(Data));
    tmpSegmentSettings = cell(1,numel(Data));
    tmpPeriodicitySettings = cell(1,numel(Data));
    for i = 1:numel(Data)
        tmpMaskSettings{i} = Data{i}.mask.settings;
        tmpSegmentSettings{i} = Data{i}.segments.settings;
        tmpPeriodicitySettings{i} = Data{i}.periodicity.settings;
    end

    % Plot the current data.
    plotData(axData,tmpData{1},1)
    plotData(axMask,tmpData{1},2)
    plotData(axSegments,tmpData{1},3)
    plotData(axFinalSegments,tmpData{1},4)

    % Create the Mask settings buttons.
    annotation(figPlot,'TextBox',[0.05,0.32,0.42,0.03],'String','1. Initial mask settings','HorizontalAlignment','center','FontUnits','Normalized','FontSize',0.025,'FontWeight','bold','FitBoxToText','on','EdgeColor','none')
    annotation(figPlot,'line',[0.05 0.47],[0.31 0.31],'LineWidth',2,'Color','k')
    uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.05,0.25,0.15,0.03],'String','Contrast (0-0.1):','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
    contrastPercSlider = uicontrol(figPlot,'Style','Slider','Units','Normalized','Position',[0.21,0.25,0.1,0.03],'Value',Data{1}.mask.settings.contrastPerc,'Min',0,'Max',0.1,'Sliderstep',[0.005 0.1],'HorizontalAlignment','center','Callback',{@contrastSlider_callback});
    contrastPercBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.32 0.25 0.1 0.03],'String',num2str(Data{1}.mask.settings.contrastPerc),'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@contrastBox_callback});
    uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.05,0.21,0.15,0.03],'String','Min. size (pixels²):','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
    minSizeObjectSlider = uicontrol(figPlot,'Style','Slider','Units','Normalized','Position',[0.21,0.21,0.1,0.03],'Value',Data{1}.mask.settings.minSizeObject,'Min',0,'Max',round(sqrt(numel(Data{1}.data.maskImage)))*10,'Sliderstep',[0.01 0.1],'HorizontalAlignment','center','Callback',{@sizeObjectsSlider_callback});
    minSizeObjectBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.32 0.21 0.1 0.03],'String',num2str(Data{1}.mask.settings.minSizeObject),'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@sizeObjectsBox_callback});
    uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.05,0.17,0.15,0.03],'String','Max. circularity (0-1):','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
    maxCircularitySlider = uicontrol(figPlot,'Style','Slider','Units','Normalized','Position',[0.21,0.17,0.1,0.03],'Value',Data{1}.mask.settings.maxCircularity,'Min',0,'Max',1,'Sliderstep',[0.01 0.1],'HorizontalAlignment','center','Callback',{@circularitySlider_callback});
    maxCircularityBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.32 0.17 0.1 0.03],'String',num2str(Data{1}.mask.settings.maxCircularity),'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@circularityBox_callback});
    uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.05,0.13,0.15,0.03],'String','Num. objects:','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
    numAxonsSlider = uicontrol(figPlot,'Style','Slider','Units','Normalized','Position',[0.21,0.13,0.1,0.03],'Value',Data{1}.mask.settings.numAxons,'Min',1,'Max',10,'Sliderstep',[0.11 0.11],'HorizontalAlignment','center','Callback',{@numAxonsSlider_callback});
    numAxonsBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.32 0.13 0.1 0.03],'String',num2str(Data{1}.mask.settings.numAxons),'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@numAxonsBox_callback});

    % Create the update Mask buttons.
    if numel(Data) > 1
        uicontrol(figPlot,'Style','pushbutton','Units','Normalized','Position',[0.11,0.02,0.15,0.04],'FontUnits','Normalized','FontSize',0.5,'FontWeight','bold','String','Apply to current data mask','Enable','on','callback',{@updateSegmentation_callback});
        uicontrol(figPlot,'Style','pushbutton','Units','Normalized','Position',[0.27,0.02,0.15,0.04],'FontUnits','Normalized','FontSize',0.5,'FontWeight','bold','String','Apply to all data masks','Enable','on','callback',{@updateSegmentationAll_callback});
        uicontrol(figPlot,'Style','pushbutton','Units','Normalized','Position',[0.185,0.07,0.15,0.04],'FontUnits','Normalized','FontSize',0.5,'FontWeight','bold','String','Reset mask segmentation','Enable','on','callback',{@resetToDefault_callback});
    else
        uicontrol(figPlot,'Style','pushbutton','Units','Normalized','Position',[0.185,0.02,0.15,0.04],'FontUnits','Normalized','FontSize',0.5,'FontWeight','bold','String','Apply to current data mask','Enable','on','callback',{@updateSegmentation_callback});
        uicontrol(figPlot,'Style','pushbutton','Units','Normalized','Position',[0.111,0.07,0.15,0.04],'FontUnits','Normalized','FontSize',0.5,'FontWeight','bold','String','Reset mask segmentation','Enable','on','callback',{@resetToDefault_callback});
        uicontrol(figPlot,'Style','pushbutton','Units','Normalized','Position',[0.27,0.07,0.15,0.04],'FontUnits','Normalized','FontSize',0.5,'FontWeight','bold','String','Mask by endpoint selection','Enable','on','callback',{@maskByEndpoint_callback});
    end

    % Create the Segments settings buttons.
    annotation(figPlot,'TextBox',[0.53,0.32,0.42,0.03],'String','2. Segments settings','HorizontalAlignment','center','FontUnits','Normalized','FontSize',0.025,'FontWeight','bold','FitBoxToText','on','EdgeColor','none')
    annotation(figPlot,'line',[0.53 0.95],[0.31 0.31],'LineWidth',2,'Color','k')
    uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.52,0.25,0.16,0.03],'String','Pixelsize mask (µm):','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
    pixelSizeBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.69 0.25 0.1 0.03],'String',num2str(Data{1}.segments.settings.pixelSize),'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@pixelSizeBox_callback});
    uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.52,0.21,0.16,0.03],'String','Pixelsize rendered (µm):','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
    pixelSizeRenderedBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.69 0.21 0.1 0.03],'String',num2str(Data{1}.periodicity.settings.pixelSize_Rendered),'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@pixelSizeRenderedBox_callback});
    uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.52,0.16,0.16,0.03],'String','Mask dilation (pixels):','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
    dilationSizeSlider = uicontrol(figPlot,'Style','Slider','Units','Normalized','Position',[0.69,0.16,0.1,0.03],'Value',Data{1}.segments.settings.dilationDiskSize,'Min',1,'Max',10,'Sliderstep',[0.11 0.11],'HorizontalAlignment','center','Callback',{@dilationSlider_callback});
    dilationSizeBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.8 0.16 0.1 0.03],'String',num2str(Data{1}.segments.settings.dilationDiskSize),'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@dilationBox_callback});
    uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.52,0.12,0.16,0.03],'String','Segment length/width (µm):','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
    segmentLengthSlider = uicontrol(figPlot,'Style','Slider','Units','Normalized','Position',[0.69,0.12,0.06,0.03],'Value',Data{1}.segments.settings.segmentLength,'Min',1,'Max',10,'Sliderstep',[0.01 0.1],'HorizontalAlignment','center','Callback',{@segmentLengthSlider_callback});
    segmentLengthBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.76 0.12 0.03 0.03],'String',num2str(Data{1}.segments.settings.segmentLength),'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@segmentLengthBox_callback});
    segmentWidthSlider = uicontrol(figPlot,'Style','Slider','Units','Normalized','Position',[0.8,0.12,0.06,0.03],'Value',Data{1}.segments.settings.segmentWidth,'Min',1,'Max',10,'Sliderstep',[0.01 0.1],'HorizontalAlignment','center','Callback',{@segmentWidthSlider_callback});
    segmentWidthBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.87 0.12 0.03 0.03],'String',num2str(Data{1}.segments.settings.segmentWidth),'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@segmentWidthBox_callback});
    uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.52,0.08,0.16,0.03],'String','Segment distance (µm):','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
    segmentDistanceSlider = uicontrol(figPlot,'Style','Slider','Units','Normalized','Position',[0.69,0.08,0.1,0.03],'Value',Data{1}.segments.settings.distanceBetweenSegments,'Min',0,'Max',10,'Sliderstep',[0.11 0.11],'HorizontalAlignment','center','Callback',{@segmentDistanceSlider_callback});
    segmentDistanceBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.8 0.08 0.1 0.03],'String',num2str(Data{1}.segments.settings.distanceBetweenSegments),'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@segmentDistanceBox_callback});

    % Create the update Segments buttons.
    if numel(Data) > 1
        uicontrol(figPlot,'Style','pushbutton','Units','Normalized','Position',[0.665,0.02,0.15,0.04],'FontUnits','Normalized','FontSize',0.5,'FontWeight','bold','String','Apply to all data segments','Enable','on','callback',{@updateSegments_callback});
    else
        uicontrol(figPlot,'Style','pushbutton','Units','Normalized','Position',[0.665,0.02,0.15,0.04],'FontUnits','Normalized','FontSize',0.5,'FontWeight','bold','String','Apply to data segment','Enable','on','callback',{@updateSegments_callback});
    end

    % Wait to go back to the browser and update the data.
    uiwait(figPlot)

end

    % Function that controls what happens when the plot is closed.
    function close_callback(~,~)
        newData = Data;
        uiresume(figPlot)
        delete(figPlot)
    end

    % Update the mask segmentation for the current data set.
    function updateSegmentation_callback(~,~,~)

        % Check if the settings correspond to everything, because if it
        % does, the data should not be recalculated.
        slider_value = round(slider.Value);
        updateData = checkSettings(tmpMaskSettings{slider_value},Data{slider_value}.mask.settings);

        % Recalculate if needed.
        if updateData

            % Show a waitbar and then perform the calculations.
            wb = waitbar(0,'Performing calculations: 1/1');
            tmpData{slider_value}.mask = createMask(tmpData{slider_value}.data.maskImage,tmpMaskSettings{slider_value});

            waitbar(0.25,wb,'Performing calculations: 1/1');
            drawnow;
            tmpData{slider_value}.segments = createSegments(tmpData{slider_value}.mask,tmpData{slider_value}.segments.settings);

            waitbar(0.5,wb,'Performing calculations: 1/1');
            drawnow;
            tmpData{slider_value}.periodicity = createPeriodicityImages(tmpData{slider_value}.data.renderedImage,tmpData{slider_value}.segments,tmpData{slider_value}.periodicity.settings);

            waitbar(0.75,wb,'Performing calculations: 1/1');
            drawnow;
            tmpData{slider_value}.periodicity = quantifyPeriodicity(tmpData{slider_value}.periodicity,tmpData{slider_value}.periodicity.settings);

            waitbar(1,wb,'Performing calculations: 1/1');
            drawnow;
            pause(0.1)
            close(wb)

            % Update the variables.
            Data{slider_value} = tmpData{slider_value};
            tmpMaskSettings{slider_value} = Data{slider_value}.mask.settings;
            tmpSegmentSettings{slider_value} = Data{slider_value}.segments.settings;
            tmpPeriodicitySettings{slider_value} = Data{slider_value}.periodicity.settings;
        else
            % Show a waitbar and then perform the calculations.
            wb = waitbar(0,'Performing calculations: 1/1');
            pause(0.1)
            close(wb)
        end

        % Update the plots to show the right data.
        plotData(axData,tmpData{slider_value},1)
        plotData(axMask,tmpData{slider_value},2)
        plotData(axSegments,tmpData{slider_value},3)
        plotData(axFinalSegments,tmpData{slider_value},4)

        % Update the settings boxes.
        updateSettings();

    end

    % Update the mask segmentation for all the data sets.
    function updateSegmentationAll_callback(~,~,~)

        % Check if the settings correspond to everything, because if it
        % does, the data should not be recalculated.
        settingsCheckAll = zeros(1,numel(Data));
        for j = 1:numel(Data)
            settingsCheckAll(j) = checkSettings(tmpMaskSettings{j},Data{j}.mask.settings);
        end
        settingsCheckAll = find(settingsCheckAll);

        % Show a waitbar and then perform the calculations.
        wb = waitbar(0,['Performing calculations: 0/' num2str(numel(settingsCheckAll)) ' - Skipping ' num2str(numel(Data)-numel(settingsCheckAll))]);
        % Recalculate if needed.
        for j = 1:numel(settingsCheckAll)

            % Update the mask.
            tmpData{settingsCheckAll(j)}.mask = createMask(tmpData{settingsCheckAll(j)}.data.maskImage,tmpMaskSettings{settingsCheckAll(j)});
            waitbar(((j-1)+0.25)/numel(settingsCheckAll),wb,['Performing calculations: ' num2str(j) '/' num2str(numel(settingsCheckAll)) ' - Skipping ' num2str(numel(Data)-numel(settingsCheckAll))]);
            drawnow;

            % Update the segments.
            tmpData{settingsCheckAll(j)}.segments = createSegments(tmpData{settingsCheckAll(j)}.mask,tmpData{settingsCheckAll(j)}.segments.settings);
            waitbar(((j-1)+0.5)/numel(settingsCheckAll),wb,['Performing calculations: ' num2str(j) '/' num2str(numel(settingsCheckAll)) ' - Skipping ' num2str(numel(Data)-numel(settingsCheckAll))]);
            drawnow;

            % Update the periodicity.
            tmpData{settingsCheckAll(j)}.periodicity = createPeriodicityImages(tmpData{settingsCheckAll(j)}.data.renderedImage,tmpData{settingsCheckAll(j)}.segments,tmpData{settingsCheckAll(j)}.periodicity.settings);
            waitbar(((j-1)+0.75)/numel(settingsCheckAll),wb,['Performing calculations: ' num2str(j) '/' num2str(numel(settingsCheckAll)) ' - Skipping ' num2str(numel(Data)-numel(settingsCheckAll))]);
            drawnow;

            % Update the periodicity quantification.
            tmpData{settingsCheckAll(j)}.periodicity = quantifyPeriodicity(tmpData{settingsCheckAll(j)}.periodicity,tmpData{settingsCheckAll(j)}.periodicity.settings);

            % Update the variables.
            Data{settingsCheckAll(j)} = tmpData{settingsCheckAll(j)};
            tmpMaskSettings{settingsCheckAll(j)} = Data{settingsCheckAll(j)}.mask.settings;
            tmpSegmentSettings{settingsCheckAll(j)} = Data{settingsCheckAll(j)}.segments.settings;
            tmpPeriodicitySettings{settingsCheckAll(j)} = Data{settingsCheckAll(j)}.periodicity.settings;
        end

        % Close the waitbar.
        pause(0.1)
        close(wb)

        % Update the plots to show the right data.
        slider_value = round(slider.Value);
        plotData(axData,tmpData{slider_value},1)
        plotData(axMask,tmpData{slider_value},2)
        plotData(axSegments,tmpData{slider_value},3)
        plotData(axFinalSegments,tmpData{slider_value},4)

        % Update the settings boxes.
        updateSettings();

    end

    % Reset the mask settings to the default ones.
    function resetToDefault_callback(~,~,~)

        % Set the temporary mask settings to the default values.
        slider_value = round(slider.Value);
        tmpMaskSettings{slider_value} = Data{slider_value}.mask.settings;
        tmpData{slider_value}.mask = createMask(tmpData{slider_value}.data.maskImage,tmpMaskSettings{slider_value});
        plotData(axMask,tmpData{slider_value},2)

        % Update the contrast percentage to the actual value.
        tmpMaskSettings{slider_value}.contrastPerc = tmpData{slider_value}.mask.settings.contrastPerc;

        % Update the settings boxes.
        updateSettings();

    end

    % Reset the mask settings to the default ones.
    function maskByEndpoint_callback(~,~,~)

        % Extract the data set number (should be one, but just to be
        % consistent with the rest of the code).
        slider_value = round(slider.Value);

        % Perform the calculations. This will automatically save
        % everything.
        Data{slider_value} = maskEndpointSelection(Data{slider_value});
        tmpData{slider_value} = Data{slider_value};

        % Update the settings boxes.
        tmpMaskSettings{slider_value} = Data{slider_value}.mask.settings;
        tmpSegmentSettings{slider_value} = Data{slider_value}.segments.settings;
        tmpPeriodicitySettings{slider_value} = Data{slider_value}.periodicity.settings;
        updateSettings();

        % Update the plots to show the right data.
        plotData(axData,tmpData{slider_value},1)
        plotData(axMask,tmpData{slider_value},2)
        plotData(axSegments,tmpData{slider_value},3)
        plotData(axFinalSegments,tmpData{slider_value},4)

    end

    % Update the segments with the new settings. Everything is applied to
    % all the data sets as they should all be treated equally.
    function updateSegments_callback(~,~,~)

        % Show a waitbar and then perform the calculations.
        wb = waitbar(0,['Performing calculations: 0/' num2str(numel(tmpData))]);
        
        for j = 1:numel(tmpData)

            % Update the segments.
            tmpData{j}.segments = recalcSegments(tmpData{j}.segments,tmpSegmentSettings{j});
            waitbar(((j-1)+0.5)/numel(tmpData),wb,['Performing calculations: ' num2str(j) '/' num2str(numel(tmpData))]);
            drawnow;

            % Update the periodicity.
            tmpData{j}.periodicity = createPeriodicityImages(tmpData{j}.data.renderedImage,tmpData{j}.segments,tmpPeriodicitySettings{j});
            waitbar(j/numel(tmpData),wb,['Performing calculations: ' num2str(j) '/' num2str(numel(tmpData))]);
            drawnow;

            % Update the periodicity quantification.
            tmpData{j}.periodicity = quantifyPeriodicity(tmpData{j}.periodicity,tmpData{j}.periodicity.settings);

            % Update the variables.
            Data{j} = tmpData{j};
            tmpMaskSettings{j} = Data{j}.mask.settings;
            tmpSegmentSettings{j} = Data{j}.segments.settings;
            tmpPeriodicitySettings{j} = Data{j}.periodicity.settings;
        end

        % Close the waitbar.
        pause(0.1)
        close(wb)

        % Update the plots to show the right data.
        slider_value = round(slider.Value);
        plotData(axData,tmpData{slider_value},1)
        plotData(axMask,tmpData{slider_value},2)
        plotData(axSegments,tmpData{slider_value},3)
        plotData(axFinalSegments,tmpData{slider_value},4)

        % Update the settings boxes.
        updateSettings();

    end

    % Function that controls which data is being plotted.
    function slider_callback(~,~,~)
        
        % Determine which data should be shown and update the visualization
        % accordingly.
        slider_value = round(slider.Value);
        sliderText.String = ['Dataset ' num2str(slider_value) ' / ' num2str(numel(Data))];
        nameText.String = Data{slider_value}.name;

        % Do the actual plotting according to the value that is currently
        % being requested.
        if ~isempty(Data{slider_value})
            plotData(axData,tmpData{slider_value},1)
            plotData(axMask,tmpData{slider_value},2)
            plotData(axSegments,tmpData{slider_value},3)
            plotData(axFinalSegments,tmpData{slider_value},4)
        end

        % Update the settings boxes.
        updateSettings();

    end

    % Make the changes to the settings for the contrast (Slider). 
    function contrastSlider_callback(~,~,~)

        % Extract the value of the changed settings.
        if contrastPercSlider.Value <= 0.0001
            contrastPercBox.String = num2str(0.0001);
            contrastPercSlider.Value = 0.0001;
        elseif contrastPercSlider.Value >= 0.1
            contrastPercBox.String = num2str(0.1);
            contrastPercSlider.Value = 0.1;
        else
            contrastPercBox.String = num2str(round(contrastPercSlider.Value,4));
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        tmpMaskSettings{slider_value}.contrastPerc = round(contrastPercSlider.Value,4);
        tmpData{slider_value}.mask = createMask(tmpData{slider_value}.data.maskImage,tmpMaskSettings{slider_value});
        plotData(axMask,tmpData{slider_value},2)

        % Update the contrast percentage to the actual value.
        tmpMaskSettings{slider_value}.contrastPerc = tmpData{slider_value}.mask.settings.contrastPerc;
        contrastPercBox.String = num2str(tmpMaskSettings{slider_value}.contrastPerc);
        contrastPercSlider.Value = tmpMaskSettings{slider_value}.contrastPerc;

    end

    % Make the changes to the settings for the contrast (Textbox). 
    function contrastBox_callback(~,~,~)

        % Extract the value of the changed settings.
        if str2double(contrastPercBox.String) <= 0.0001
            contrastPercSlider.Value = 0.0001;
            contrastPercBox.String = num2str(0.0001);
        elseif str2double(contrastPercBox.String) >= 0.1
            contrastPercSlider.Value = 0.1;
            contrastPercBox.String = num2str(0.1);
        else
            contrastPercSlider.Value = round(str2double(contrastPercBox.String),4);
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        tmpMaskSettings{slider_value}.contrastPerc = round(contrastPercSlider.Value,4);
        tmpData{slider_value}.mask = createMask(tmpData{slider_value}.data.maskImage,tmpMaskSettings{slider_value});
        plotData(axMask,tmpData{slider_value},2)

        % Update the contrast percentage to the actual value.
        tmpMaskSettings{slider_value}.contrastPerc = tmpData{slider_value}.mask.settings.contrastPerc;
        contrastPercBox.String = num2str(tmpMaskSettings{slider_value}.contrastPerc);
        contrastPercSlider.Value = tmpMaskSettings{slider_value}.contrastPerc;
    end

    % Make the changes to the settings for the size of the objects (Slider).
    function sizeObjectsSlider_callback(~,~,~)

        % Extract the value of the changed settings.
        if minSizeObjectSlider.Value <= 0
            minSizeObjectBox.String = num2str(0);
            minSizeObjectSlider.Value = 0;
        elseif minSizeObjectSlider.Value >= round(sqrt(numel(Data{1}.data.maskImage)))*10
            minSizeObjectBox.String = num2str(round(sqrt(numel(Data{1}.data.maskImage)))*10);
            minSizeObjectSlider.Value = round(sqrt(numel(Data{1}.data.maskImage)))*10;
        else
            minSizeObjectBox.String = num2str(round(minSizeObjectSlider.Value));
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        tmpMaskSettings{slider_value}.minSizeObject = round(minSizeObjectSlider.Value);
        tmpData{slider_value}.mask = createMask(tmpData{slider_value}.data.maskImage,tmpMaskSettings{slider_value});
        plotData(axMask,tmpData{slider_value},2)
    end

    % Make the changes to the settings for the size of the objects (Textbox). 
    function sizeObjectsBox_callback(~,~,~)

        % Extract the value of the changed settings.
        if str2double(minSizeObjectBox.String) <= 0
            minSizeObjectSlider.Value = 0;
            minSizeObjectBox.String = num2str(0);
        elseif str2double(minSizeObjectBox.String) >= round(sqrt(numel(Data{1}.data.maskImage)))*10
            minSizeObjectSlider.Value = round(sqrt(numel(Data{1}.data.maskImage)))*10;
            minSizeObjectBox.String = num2str(round(sqrt(numel(Data{1}.data.maskImage)))*10);
        else
            minSizeObjectSlider.Value = round(str2double(minSizeObjectBox.String));
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        tmpMaskSettings{slider_value}.minSizeObject = round(minSizeObjectSlider.Value);
        tmpData{slider_value}.mask = createMask(tmpData{slider_value}.data.maskImage,tmpMaskSettings{slider_value});
        plotData(axMask,tmpData{slider_value},2)
    end

    % Make the changes to the settings for the circularity (Slider). 
    function circularitySlider_callback(~,~,~)

        % Extract the value of the changed settings.
        if maxCircularitySlider.Value <= 0
            maxCircularityBox.String = num2str(0);
            maxCircularitySlider.Value = 0;
        elseif maxCircularitySlider.Value >= 1
            maxCircularityBox.String = num2str(1);
            maxCircularitySlider.Value = 1;
        else
            maxCircularityBox.String = num2str(round(maxCircularitySlider.Value,2));
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        tmpMaskSettings{slider_value}.maxCircularity = round(maxCircularitySlider.Value,2);
        tmpData{slider_value}.mask = createMask(tmpData{slider_value}.data.maskImage,tmpMaskSettings{slider_value});
        plotData(axMask,tmpData{slider_value},2)
    end

    % Make the changes to the settings for the circularity (Textbox). 
    function circularityBox_callback(~,~,~)

        % Extract the value of the changed settings.
        if str2double(maxCircularityBox.String) <= 0
            maxCircularitySlider.Value = 0;
            maxCircularityBox.String = num2str(0);
        elseif str2double(maxCircularityBox.String) >= 1
            maxCircularitySlider.Value = 1;
            maxCircularityBox.String = num2str(1);
        else
            maxCircularitySlider.Value = round(str2double(maxCircularityBox.String),2);
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        tmpMaskSettings{slider_value}.maxCircularity = round(maxCircularitySlider.Value,2);
        tmpData{slider_value}.mask = createMask(tmpData{slider_value}.data.maskImage,tmpMaskSettings{slider_value});
        plotData(axMask,tmpData{slider_value},2)
    end

    % Make the changes to the settings for the number of objects (Slider). 
    function numAxonsSlider_callback(~,~,~)

        % Extract the value of the changed settings.
        if numAxonsSlider.Value <= 1
            numAxonsBox.String = num2str(1);
            numAxonsSlider.Value = 1;
        elseif numAxonsSlider.Value >= 10
            numAxonsBox.String = num2str(10);
            numAxonsSlider.Value = 10;
        else
            numAxonsBox.String = num2str(round(numAxonsSlider.Value));
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        tmpMaskSettings{slider_value}.numAxons = round(numAxonsSlider.Value);
        tmpData{slider_value}.mask = createMask(tmpData{slider_value}.data.maskImage,tmpMaskSettings{slider_value});
        plotData(axMask,tmpData{slider_value},2)
    end

    % Make the changes to the settings for the number of objects (Textbox). 
    function numAxonsBox_callback(~,~,~)

        % Extract the value of the changed settings.
        if str2double(numAxonsBox.String) <= 1
            numAxonsSlider.Value = 1;
            numAxonsBox.String = num2str(1);
        elseif str2double(numAxonsBox.String) >= 10
            numAxonsSlider.Value = 10;
            numAxonsBox.String = num2str(10);
        else
            numAxonsSlider.Value = round(str2double(numAxonsBox.String));
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        tmpMaskSettings{slider_value}.numAxons = round(numAxonsSlider.Value);
        tmpData{slider_value}.mask = createMask(tmpData{slider_value}.data.maskImage,tmpMaskSettings{slider_value});
        plotData(axMask,tmpData{slider_value},2)
    end

    % Make the changes to the settings for the pixelsize of the mask image. 
    function pixelSizeBox_callback(~,~,~)

        % Extract the value of the changed settings.
        if str2double(pixelSizeBox.String) <= 0.05
            pixelSizeBox.String = num2str(0.05);
        elseif str2double(pixelSizeBox.String) >= 0.5
            pixelSizeBox.String = num2str(0.5);
        else
            pixelSizeBox.String = round(str2double(pixelSizeBox.String),3);
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        for j = 1:numel(tmpData)
            tmpSegmentSettings{j}.pixelSize = round(str2double(pixelSizeBox.String),3);
            tmpPeriodicitySettings{j}.pixelSize = round(str2double(pixelSizeBox.String),3);
            tmpData{j}.segments = recalcSegments(tmpData{j}.segments,tmpSegmentSettings{j});
        end
        updateScalebar(tmpData{slider_value})
        plotData(axFinalSegments,tmpData{slider_value},4)
    end

    % Make the changes to the settings for the pixelsize of the rendered image. 
    function pixelSizeRenderedBox_callback(~,~,~)

        % Extract the value of the changed settings.
        if str2double(pixelSizeRenderedBox.String) <= 0.001
            pixelSizeRenderedBox.String = num2str(0.001);
        elseif str2double(pixelSizeRenderedBox.String) >= 0.5
            pixelSizeRenderedBox.String = num2str(0.5);
        else
            pixelSizeRenderedBox.String = round(str2double(pixelSizeRenderedBox.String),3);
        end

        % Do the actual update (temporary).
        for j = 1:numel(tmpData)
            tmpPeriodicitySettings{j}.pixelSize_Rendered = round(str2double(pixelSizeRenderedBox.String),3);
        end
    end

    % Make the changes to the settings for the dilation parameters of the mask of the path (Slider). 
    function dilationSlider_callback(~,~,~)

        % Extract the value of the changed settings.
        if dilationSizeSlider.Value <= 1
            dilationSizeBox.String = num2str(1);
            dilationSizeSlider.Value = 1;
        elseif dilationSizeSlider.Value >= 10
            dilationSizeBox.String = num2str(10);
            dilationSizeSlider.Value = 10;
        else
            dilationSizeBox.String = num2str(round(dilationSizeSlider.Value));
        end

        % Do the actual update (temporary).
        for j = 1:numel(tmpData)
            tmpSegmentSettings{j}.dilationDiskSize = round(dilationSizeSlider.Value);
            tmpData{j}.segments.finalMask = imdilate(tmpData{j}.segments.segmentPath,strel('disk',tmpSegmentSettings{j}.dilationDiskSize));
            tmpData{j}.segments.overlay = bwboundaries(tmpData{j}.segments.finalMask,'noholes');
        end
        slider_value = round(slider.Value);
        plotData(axFinalSegments,tmpData{slider_value},4)
    end

    % Make the changes to the settings for the dilation parameters of the mask of the path (Textbox). 
    function dilationBox_callback(~,~,~)

        % Extract the value of the changed settings.
        if str2double(dilationSizeBox.String) <= 1
            dilationSizeSlider.Value = 1;
            dilationSizeBox.String = num2str(1);
        elseif str2double(dilationSizeBox.String) >= 10
            dilationSizeSlider.Value = 10;
            dilationSizeBox.String = num2str(10);
        else
            dilationSizeSlider.Value = round(str2double(dilationSizeBox.String));
        end

        % Do the actual update (temporary).
        for j = 1:numel(tmpData)
            tmpSegmentSettings{j}.dilationDiskSize = round(dilationSizeSlider.Value);
            tmpData{j}.segments.finalMask = imdilate(tmpData{j}.segments.segmentPath,strel('disk',tmpSegmentSettings{j}.dilationDiskSize));
            tmpData{j}.segments.overlay = bwboundaries(tmpData{j}.segments.finalMask,'noholes');
        end
        slider_value = round(slider.Value);
        plotData(axFinalSegments,tmpData{slider_value},4)
    end

    % Make the changes to the settings for the length of the segments (Slider). 
    function segmentLengthSlider_callback(~,~,~)

        % Extract the value of the changed settings.
        if segmentLengthSlider.Value <= 1
            segmentLengthBox.String = num2str(1);
            segmentLengthSlider.Value = 1;
        elseif segmentLengthSlider.Value >= 10
            segmentLengthBox.String = num2str(10);
            segmentLengthSlider.Value = 10;
        else
            segmentLengthBox.String = num2str(round(segmentLengthSlider.Value,1));
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        for j = 1:numel(tmpData)
            tmpSegmentSettings{j}.segmentLength = round(str2double(segmentLengthBox.String),1);
            tmpData{j}.segments = recalcSegments(tmpData{j}.segments,tmpSegmentSettings{j});
        end
        plotData(axFinalSegments,tmpData{slider_value},4)
    end

    % Make the changes to the settings for the length of the segments (Textbox). 
    function segmentLengthBox_callback(~,~,~)

        % Extract the value of the changed settings.
        if str2double(segmentLengthBox.String) <= 1
            segmentLengthSlider.Value = 1;
            segmentLengthBox.String = num2str(1);
        elseif str2double(segmentLengthBox.String) >= 10
            segmentLengthSlider.Value = 10;
            segmentLengthBox.String = num2str(10);
        else
            segmentLengthSlider.Value = round(str2double(segmentLengthBox.String),1);
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        for j = 1:numel(tmpData)
            tmpSegmentSettings{j}.segmentLength = round(str2double(segmentLengthBox.String),1);
            tmpData{j}.segments = recalcSegments(tmpData{j}.segments,tmpSegmentSettings{j});
        end
        plotData(axFinalSegments,tmpData{slider_value},4)
    end

    % Make the changes to the settings for the width of the segments (Slider). 
    function segmentWidthSlider_callback(~,~,~)

        % Extract the value of the changed settings.
        if segmentWidthSlider.Value <= 1
            segmentWidthBox.String = num2str(1);
            segmentWidthSlider.Value = 1;
        elseif segmentWidthSlider.Value >= 10
            segmentWidthBox.String = num2str(10);
            segmentWidthSlider.Value = 10;
        else
            segmentWidthBox.String = num2str(round(segmentWidthSlider.Value,1));
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        for j = 1:numel(tmpData)
            tmpSegmentSettings{j}.segmentWidth = round(str2double(segmentWidthBox.String),1);
            tmpData{j}.segments = recalcSegments(tmpData{j}.segments,tmpSegmentSettings{j});
        end
        plotData(axFinalSegments,tmpData{slider_value},4)
    end

    % Make the changes to the settings for the width of the segments (Textbox). 
    function segmentWidthBox_callback(~,~,~)

        % Extract the value of the changed settings.
        if str2double(segmentWidthBox.String) <= 1
            segmentWidthSlider.Value = 1;
            segmentWidthBox.String = num2str(1);
        elseif str2double(segmentWidthBox.String) >= 10
            segmentWidthSlider.Value = 10;
            segmentWidthBox.String = num2str(10);
        else
            segmentWidthSlider.Value = round(str2double(segmentWidthBox.String),1);
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        for j = 1:numel(tmpData)
            tmpSegmentSettings{j}.segmentWidth = round(str2double(segmentWidthBox.String),1);
            tmpData{j}.segments = recalcSegments(tmpData{j}.segments,tmpSegmentSettings{j});
        end
        plotData(axFinalSegments,tmpData{slider_value},4)
    end

    % Make the changes to the settings for the distance between the segments (Slider). 
    function segmentDistanceSlider_callback(~,~,~)

        % Extract the value of the changed settings.
        if segmentDistanceSlider.Value <= 0
            segmentDistanceBox.String = num2str(0);
            segmentDistanceSlider.Value = 0;
        elseif segmentDistanceSlider.Value >= 10
            segmentDistanceBox.String = num2str(10);
            segmentDistanceSlider.Value = 10;
        else
            segmentDistanceBox.String = num2str(round(segmentDistanceSlider.Value,1));
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        for j = 1:numel(tmpData)
            tmpSegmentSettings{j}.distanceBetweenSegments = round(str2double(segmentDistanceBox.String),1);
            tmpData{j}.segments = recalcSegments(tmpData{j}.segments,tmpSegmentSettings{j});
        end
        plotData(axFinalSegments,tmpData{slider_value},4)
    end

    % Make the changes to the settings for the distance between the segments (Textbox). 
    function segmentDistanceBox_callback(~,~,~)

        % Extract the value of the changed settings.
        if str2double(segmentDistanceBox.String) <= 0
            segmentDistanceSlider.Value = 0;
            segmentDistanceBox.String = num2str(0);
        elseif str2double(segmentDistanceBox.String) >= 10
            segmentDistanceSlider.Value = 10;
            segmentDistanceBox.String = num2str(10);
        else
            segmentDistanceSlider.Value = round(str2double(segmentDistanceBox.String),1);
        end

        % Do the actual update (temporary).
        slider_value = round(slider.Value);
        for j = 1:numel(tmpData)
            tmpSegmentSettings{j}.distanceBetweenSegments = round(str2double(segmentDistanceBox.String),1);
            tmpData{j}.segments = recalcSegments(tmpData{j}.segments,tmpSegmentSettings{j});
        end
        plotData(axFinalSegments,tmpData{slider_value},4)
    end

    % Plot the current data.
    function plotData(currentAxis,currentData,plotNumber)

        % Extract all the images so that it is easier to plot.
        switch plotNumber
            case 1
                imagePlot = mat2gray(currentData.data.maskImage);
            case 2
                imagePlot = mat2gray(currentData.mask.maskToDisplay) + mat2gray(currentData.mask.maskAll);
            case 3
                imagePlot = mat2gray(currentData.segments.segmentPath);
            case 4
                imagePlot = imadjust(mat2gray(currentData.data.maskImage),stretchlim(mat2gray(currentData.data.maskImage),0.025));
                overlay = currentData.segments.overlay;
        end
        pixelSize = currentData.segments.settings.pixelSize;

        % Do the plotting of the raw data.
        axes(currentAxis)
        imagesc(currentAxis,imagePlot);axis equal;axis tight;axis off;
        colormap(gray);

        if plotNumber == 4
            hold on;
            for boundaryNum = 1:numel(overlay)
                plot(currentAxis,overlay{boundaryNum}(:,2),overlay{boundaryNum}(:,1), 'y-', 'LineWidth', 2);
            end
            for segmentNum = 1:numel(currentData.segments.segmentPositions)
                drawpolygon(currentAxis,'Position',currentData.segments.segmentPositions{segmentNum},'FaceAlpha',0.5,'Color','b','LineWidth',1,'InteractionsAllowed','none');
            end
        end

        % Plot a scalebar.
        scalebarLine{plotNumber} = line(currentAxis,[size(imagePlot,2)*0.07 size(imagePlot,2)*0.07+5/pixelSize],[size(imagePlot,1)*0.975 size(imagePlot,1)*0.975],'LineWidth',5,'Color','w');
        scalebarText{plotNumber} = text(currentAxis,size(imagePlot,2)*0.07+5/pixelSize/2,size(imagePlot,1)*0.94,'5 µm','Color','w','FontUnits','Normalized','FontSize',0.04,'FontWeight','bold','HorizontalAlignment','center');

        % Plot the titles.
        switch plotNumber
            case 1
                title(currentAxis,'Data','FontUnits','Normalized','FontSize',0.05);
            case 2
                title(currentAxis,'Mask','FontUnits','Normalized','FontSize',0.05);
            case 3
                title(currentAxis,'Selected axon(s)','FontUnits','Normalized','FontSize',0.05);
            case 4
                title(currentAxis,'Final segments','FontUnits','Normalized','FontSize',0.05);
        end

        % Create a new custom toolbar, and link all the plots together so they
        % all zoom in the same way.
        axtoolbar(axData,{'zoomin','zoomout', 'pan','restoreview'});
        axtoolbar(axMask,{'zoomin','zoomout', 'pan','restoreview'});
        axtoolbar(axSegments,{'zoomin','zoomout', 'pan','restoreview'});
        axtoolbar(axFinalSegments,{'zoomin','zoomout', 'pan','restoreview'});
        linkaxes([axData axMask axSegments axFinalSegments]);

    end

    % Update the scalebars of images 1-3.
    function updateScalebar(currentData)

        % Delete the current scale bars.
        for j = 1:3
            delete(scalebarLine{j})
            delete(scalebarText{j})
        end

        % Redraw the scalebars.
        pixelSize = currentData.segments.settings.pixelSize;
        imagePlot = currentData.data.maskImage;
        scalebarLine{1} = line(axData,[size(imagePlot,2)*0.07 size(imagePlot,2)*0.07+5/pixelSize],[size(imagePlot,1)*0.975 size(imagePlot,1)*0.975],'LineWidth',5,'Color','w');
        scalebarText{1} = text(axData,size(imagePlot,2)*0.07+5/pixelSize/2,size(imagePlot,1)*0.94,'5 µm','Color','w','FontUnits','Normalized','FontSize',0.04,'FontWeight','bold','HorizontalAlignment','center');
        scalebarLine{2} = line(axMask,[size(imagePlot,2)*0.07 size(imagePlot,2)*0.07+5/pixelSize],[size(imagePlot,1)*0.975 size(imagePlot,1)*0.975],'LineWidth',5,'Color','w');
        scalebarText{2} = text(axMask,size(imagePlot,2)*0.07+5/pixelSize/2,size(imagePlot,1)*0.94,'5 µm','Color','w','FontUnits','Normalized','FontSize',0.04,'FontWeight','bold','HorizontalAlignment','center');
        scalebarLine{3} = line(axSegments,[size(imagePlot,2)*0.07 size(imagePlot,2)*0.07+5/pixelSize],[size(imagePlot,1)*0.975 size(imagePlot,1)*0.975],'LineWidth',5,'Color','w');
        scalebarText{3} = text(axSegments,size(imagePlot,2)*0.07+5/pixelSize/2,size(imagePlot,1)*0.94,'5 µm','Color','w','FontUnits','Normalized','FontSize',0.04,'FontWeight','bold','HorizontalAlignment','center');

    end

    % Update the settings boxes.
    function updateSettings()

        % Extract the current data set being shown.
        slider_value = round(slider.Value);

        % Update the mask segmentation settings.
        contrastPercSlider.Value = tmpMaskSettings{slider_value}.contrastPerc;
        contrastPercBox.String = num2str(tmpMaskSettings{slider_value}.contrastPerc);
        minSizeObjectSlider.Value = tmpMaskSettings{slider_value}.minSizeObject;
        minSizeObjectBox.String = num2str(tmpMaskSettings{slider_value}.minSizeObject);
        minSizeObjectSlider.Max = round(sqrt(numel(tmpData{slider_value}.data.maskImage)))*10;
        maxCircularitySlider.Value = tmpMaskSettings{slider_value}.maxCircularity;
        maxCircularityBox.String = num2str(tmpMaskSettings{slider_value}.maxCircularity);
        numAxonsSlider.Value = tmpMaskSettings{slider_value}.numAxons;
        numAxonsBox.String = num2str(tmpMaskSettings{slider_value}.numAxons);

        % Update the segments settings.
        pixelSizeBox.String = num2str(tmpSegmentSettings{slider_value}.pixelSize);
        pixelSizeRenderedBox.String = num2str(tmpPeriodicitySettings{slider_value}.pixelSize_Rendered);
        dilationSizeSlider.Value = tmpSegmentSettings{slider_value}.dilationDiskSize;
        dilationSizeBox.String = num2str(tmpSegmentSettings{slider_value}.dilationDiskSize);
        segmentLengthSlider.Value = tmpSegmentSettings{slider_value}.segmentLength;
        segmentLengthBox.String = num2str(tmpSegmentSettings{slider_value}.segmentLength);
        segmentWidthSlider.Value = tmpSegmentSettings{slider_value}.segmentWidth;
        segmentWidthBox.String = num2str(tmpSegmentSettings{slider_value}.segmentWidth);
        segmentDistanceSlider.Value = tmpSegmentSettings{slider_value}.distanceBetweenSegments;
        segmentDistanceBox.String = num2str(tmpSegmentSettings{slider_value}.distanceBetweenSegments);

    end

    % Show an instruction page on how to use the Segmentation Visualizer.
    function instructions_callback(~,~,~)
        instructionsSegmentationVisualizer()
    end

    % Show an instruction page on how to use the mask by endpoint selection.
    function instructionsEndpoints_callback(~,~,~)
        instructionsEndpointSegmentation()
    end

end