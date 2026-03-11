function saveFigures(Data,showSegmentBox)

% Select in which folder the data should be saved.
saveFolder = uigetdir('','Please select the folder where the data should be saved.');

% Save the plots.
if isequal(saveFolder, 0)
    return
else

    % Make a new invisible figure so it does not show to the
    % person.
    savePlot = figure('NumberTitle','Off','Color','w','Units','Normalized','Position',[0.25 0.15 0.5 0.7],'Menubar','None','Toolbar','None','Resize','off','Visible','off');
    figAxes = axes('Parent',savePlot);

    % calculate the total number of plots to save.
    totalPlots = numel(Data);
    for i = 1:numel(Data)
        totalPlots = totalPlots + 2*numel(Data{i}.periodicity.autoCorrelationFunction); % 1 for autocorrelation functions, 1 for zoomed segments.
    end

    % Show a waitbar.
    wb = waitbar(0,['Saving plots... ' num2str(0) '/' num2str(totalPlots)]);
    currentPlot = 1;
    for i = 1:numel(Data)

        % Update the waitbar.
        waitbar(currentPlot/totalPlots,wb,['Saving plots... ' num2str(currentPlot) '/' num2str(totalPlots)]);
        drawnow;

        % Do the actual plotting.

        % First of the large entire image.
        displayImage = imadjust(mat2gray(Data{i}.data.maskImage),stretchlim(mat2gray(Data{i}.data.maskImage),0.01));
        imagesc(figAxes,displayImage);axis(figAxes,'equal');axis(figAxes,'tight');axis(figAxes,'off');
        colormap(figAxes,gray);
        hold(figAxes,'on');
        for boundaryNum = 1:numel(Data{i}.segments.overlay)
            plot(figAxes,Data{i}.segments.overlay{boundaryNum}(:,2),Data{i}.segments.overlay{boundaryNum}(:,1), 'y-', 'LineWidth', 2);
        end
        if showSegmentBox.Value == 1
            for j = 1:numel(Data{i}.segments.segmentPositions)
                drawpolygon(figAxes,'Position',Data{i}.segments.segmentPositions{j},'FaceAlpha',0,'Color','b','InteractionsAllowed','none');
                meanPos = mean(Data{i}.segments.segmentPositions{j}([1 3],:));
                text(figAxes,meanPos(1)-40,meanPos(2),num2str(j),'FontUnits','Normalized','FontSize',0.03,'Color','w','FontWeight','bold');
            end
        end
        line(figAxes,[size(displayImage,2)*0.85 size(displayImage,2)*0.85+5/Data{i}.periodicity.settings.pixelSize],[size(displayImage,1)*0.975 size(displayImage,1)*0.975],'LineWidth',5,'Color','w')
        text(figAxes,size(displayImage,2)*0.85+5/Data{i}.periodicity.settings.pixelSize/2,size(displayImage,1)*0.94,'5 µm','Color','w','FontUnits','Normalized','FontSize',0.03,'FontWeight','bold','HorizontalAlignment','center')
        print(savePlot,fullfile(saveFolder,[Data{i}.name '_FullImage.png']),'-dpng')
        hold(figAxes,'off');
        
        % Update the currentplot so the right waitbar is displayed and
        % clear the axes;
        currentPlot = currentPlot + 1;
        cla(savePlot);

        % Now save the segment images (zoomed versions).
        for j = 1:numel(Data{i}.periodicity.autoCorrelationFunction)
            % Update the waitbar.
            waitbar(currentPlot/totalPlots,wb,['Saving plots... ' num2str(currentPlot) '/' num2str(totalPlots)]);
            drawnow;

            % Save the zoomed images.
            displayImage = Data{i}.periodicity.images{j};
            imagesc(figAxes,displayImage);axis(figAxes,'equal');axis(figAxes,'tight');axis(figAxes,'off');
            colormap(figAxes,gray);
            line(figAxes,[size(displayImage,2)*0.8 size(displayImage,2)*0.8+0.5/Data{i}.periodicity.settings.pixelSize_Rendered],[size(displayImage,1)*0.965 size(displayImage,1)*0.965],'LineWidth',5,'Color','w')
            text(figAxes,size(displayImage,2)*0.8+0.5/Data{i}.periodicity.settings.pixelSize_Rendered/2,size(displayImage,1)*0.875,'500 nm','Color','w','FontUnits','Normalized','FontSize',0.075,'FontWeight','bold','HorizontalAlignment','center')
            print(savePlot,fullfile(saveFolder,[Data{i}.name '_Segment' num2str(j) '.png']),'-dpng')

            % Update the currentplot so the right waitbar is displayed and
            % clear the axes;
            currentPlot = currentPlot + 1;
            cla(savePlot);

            % Update the waitbar.
            waitbar(currentPlot/totalPlots,wb,['Saving plots... ' num2str(currentPlot) '/' num2str(totalPlots)]);
            drawnow;

            % Save the autocorrelation functions.
            plot(figAxes,Data{i}.periodicity.lags{j}*1000,Data{i}.periodicity.autoCorrelationFunction{j},'k','LineWidth',2)
            set(figAxes,'Linewidth',2,'FontUnits','Normalized','FontSize',0.03,'FontWeight','bold')
            axis tight;
            xlabel(figAxes,'Distance (nm)','FontUnits','Normalized','FontSize',0.03,'FontWeight','bold')
            ylabel(figAxes,'Autocorrelation','FontUnits','Normalized','FontSize',0.03,'FontWeight','bold')
            title(figAxes,['Periodicity: ' num2str(round(Data{i}.periodicity.periodicity{j}*1000,2)) 'nm'],'FontUnits','Normalized','FontSize',0.03,'FontWeight','bold');
            xlim(figAxes,[0 1000])
            print(savePlot,fullfile(saveFolder,[Data{i}.name '_AutocorrelationPlot' num2str(j) '.png']),'-dpng')
            title(''); % Remove the title or it will plot in the subsequent figures.

            % Update the currentplot so the right waitbar is displayed and
            % clear the axes;
            currentPlot = currentPlot + 1;
            cla(savePlot);

        end

    end
    % Close the waitbar and the figure.
    close(wb)
    close(savePlot)
end