function saveHistogram(Settings)

% Select the filename you want to save the data as.
[filename,path] = uiputfile({'HistogramPeriodicity.png'},'Filename of the histogram plot with the current settings.');

% Check if cancel was pressed or not. To avoid error messages.
if isequal(filename, 0)
    return
else
    filename = fullfile(path,filename);
    if exist(filename,'file') == 2
        delete(filename);
    end
end

% Show a waitbar.
wb = waitbar(0.5,'Saving the histogram plot to a .png file...');

% Make the plot, but make it not visible.
savePlot = figure('Name','','NumberTitle','Off','Color','w','Units','Normalized','Position',[0.15 0.2 0.5 0.5],'Menubar','None','Toolbar','None','Visible','off');
axData = axes(savePlot,'Units','Normalized','Position',[0.1,0.15,0.8,0.8],'Visible','Off');

% Do the exact same plotting as before.
if strcmp(Settings.displayStyle,'stairs')
    histogram(axData,'Data',Settings.data,'NumBins',Settings.numBins,'Normalization',Settings.normalization,'DisplayStyle',Settings.displayStyle,'EdgeAlpha',Settings.edgeAlpha,'EdgeColor',Settings.edgeColor,'FaceAlpha',Settings.faceAlpha,'FaceColor',Settings.faceColor,'LineStyle',Settings.lineStyle,'LineWidth',Settings.lineWidth);
else
    histogram(axData,'Data',Settings.data,'NumBins',Settings.numBins,'Normalization',Settings.normalization,'DisplayStyle',Settings.displayStyle,'EdgeAlpha',Settings.edgeAlpha,'EdgeColor',Settings.edgeColor,'FaceAlpha',Settings.faceAlpha,'FaceColor',Settings.faceColor,'LineStyle',Settings.lineStyle,'LineWidth',Settings.lineWidth);
end
xlabel(axData,Settings.xLabel,'Color','k','FontUnits','Normalized','FontSize',0.075,'FontWeight','bold');
ylabel(axData,Settings.yLabel,'Color','k','FontUnits','Normalized','FontSize',0.075,'FontWeight','bold');
set(axData,'FontUnits','Normalized','FontSize',0.05,'FontWeight','bold','LineWidth',Settings.lineWidthAxis);
box(axData,Settings.box);

% Save the data.
print(savePlot,filename,'-dpng')

% Update the waitbar.
waitbar(1,wb,'Saving the histogram plot to a .png file...');
drawnow;
pause(0.1)

% Close the waitbar and the figure.
close(wb)
close(savePlot)