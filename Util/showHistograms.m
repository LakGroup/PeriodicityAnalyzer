function showHistograms(Data)

% Update the data and set the Settings variable.
Data_nm = Data * 1000; % Convert to nm.
Settings = [];
Changed = 0;

% Make a figure and the right axes.
figPlot = figure('Name','Histogram Visualizer','NumberTitle','Off','Color','w','Units','Normalized','Position',[0.15 0.2 0.7 0.5],'Menubar','None','Toolbar','None','Resize','off','CloseRequestFcn',@close_callback);
axData = axes(figPlot,'Units','Normalized','Position',[0.075,0.15,0.575,0.8],'Visible','Off');

updateSettings();
plotData();

% Make the buttons and set the default values.
annotation(figPlot,'TextBox',[0.675,0.955,0.3,0.03],'String','Histogram settings','HorizontalAlignment','center','FontUnits','Normalized','FontSize',0.04,'FontWeight','bold','FitBoxToText','on','EdgeColor','none')
annotation(figPlot,'line',[0.675 0.975],[0.92 0.92],'LineWidth',2,'Color','k')

uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.68,0.87,0.12,0.04],'String','Number of bins:','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
numBinsBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.81 0.87 0.13 0.04],'String',num2str(Settings.numBins),'FontUnits','Normalized','FontSize',0.9,'HorizontalAlignment','center','Callback',{@updateSettings});
uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.68,0.82,0.12,0.04],'String','Displaystyle:','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
displayStyleBox = uicontrol(figPlot,'Style','popupmenu','Units','Normalized','Position',[0.81 0.825 0.13 0.04],'String',{'Bar','Stairs'},'Value',1,'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@updateSettings});
uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.68,0.76,0.12,0.04],'String','Normalization:','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
NormalizationBox = uicontrol(figPlot,'Style','popupmenu','Units','Normalized','Position',[0.81 0.765 0.13 0.04],'String',{'Count','Probability','Percentage','Countdensity','Cumulative count','pdf','cdf'},'Value',1,'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@updateSettings});

uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.68,0.685,0.12,0.04],'String','Edge color:','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
edgeColorBox = uicontrol(figPlot,'Style','popupmenu','Units','Normalized','Position',[0.81 0.69 0.13 0.04],'String',{'Black','Red','Green','Blue','Cyan','Magenta','Yellow'},'Value',1,'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@updateSettings});
uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.68,0.63,0.12,0.04],'String','Edge alpha (0-1):','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
edgeAlphaBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.81 0.63 0.13 0.04],'String',num2str(Settings.edgeAlpha),'FontUnits','Normalized','FontSize',0.9,'HorizontalAlignment','center','Callback',{@updateSettings});
uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.68,0.585,0.12,0.04],'String','Linewidth:','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
lineWidthBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.81 0.585 0.13 0.04],'String',num2str(Settings.lineWidth),'FontUnits','Normalized','FontSize',0.9,'HorizontalAlignment','center','Callback',{@updateSettings});
uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.68,0.535,0.12,0.04],'String','Linestyle:','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
lineStyleBox = uicontrol(figPlot,'Style','popupmenu','Units','Normalized','Position',[0.81 0.54 0.13 0.04],'String',{'-','--',':','-.','none'},'Value',1,'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@updateSettings});

uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.68,0.46,0.12,0.04],'String','Face color:','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
faceColorBox = uicontrol(figPlot,'Style','popupmenu','Units','Normalized','Position',[0.81 0.465 0.13 0.04],'String',{'Default','Black','Red','Green','Blue','Cyan','Magenta','Yellow','None'},'Value',1,'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@updateSettings});
uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.68,0.405,0.12,0.04],'String','Face alpha (0-1):','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
faceAlphaBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.81 0.405 0.13 0.04],'String',num2str(Settings.faceAlpha),'FontUnits','Normalized','FontSize',0.9,'HorizontalAlignment','center','Callback',{@updateSettings});

annotation(figPlot,'TextBox',[0.675,0.355,0.3,0.03],'String','Plot settings','HorizontalAlignment','center','FontUnits','Normalized','FontSize',0.04,'FontWeight','bold','FitBoxToText','on','EdgeColor','none')
annotation(figPlot,'line',[0.675 0.975],[0.32 0.32],'LineWidth',2,'Color','k')

uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.68,0.27,0.12,0.04],'String','Plot box:','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
plotBoxBox = uicontrol(figPlot,'Style','checkbox','Units','Normalized','Position',[0.81 0.27 0.13 0.04],'String','On/Off','Value',1,'FontUnits','Normalized','FontSize',0.8,'BackgroundColor','w','Callback',{@updateSettings});
uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.68,0.22,0.12,0.04],'String','Data unit:','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
dataUnitBox = uicontrol(figPlot,'Style','popupmenu','Units','Normalized','Position',[0.81 0.225 0.13 0.04],'String',{'µm','nm'},'Value',1,'FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','center','Callback',{@updateSettings});
uicontrol(figPlot,'Style','Text','BackgroundColor','w','Units','Normalized','Position',[0.68,0.165,0.12,0.04],'String','Linewidth axes:','FontUnits','Normalized','FontSize',0.8,'HorizontalAlignment','right');
lineWidthAxisBox = uicontrol(figPlot,'Style','Edit','Units','Normalized','Position',[0.81 0.165 0.13 0.04],'String',num2str(Settings.lineWidthAxis),'FontUnits','Normalized','FontSize',0.9,'HorizontalAlignment','center','Callback',{@updateSettings});

uicontrol(figPlot,'Style','pushbutton','Units','Normalized','Position',[0.685,0.05,0.14,0.05],'FontUnits','Normalized','FontSize',0.7,'FontWeight','bold','String','Reset to default','Enable','on','callback',{@defaultSettings});
uicontrol(figPlot,'Style','pushbutton','Units','Normalized','Position',[0.825,0.05,0.14,0.05],'FontUnits','Normalized','FontSize',0.7,'FontWeight','bold','String','Save histogram','Enable','on','callback',{@savePlot,axData});

    % Function that controls what happens when the plot is closed.
    function close_callback(~,~)
        uiresume(figPlot)
        delete(figPlot)
    end

    % Reset back to the default settings.
    function defaultSettings(~,~,~)
        Settings = [];
        Changed = 0;
        updateSettings();
        plotData();
    end

    % Sve the histogram.
    function savePlot(~,~,~)
        saveHistogram(Settings)
    end

    % Function that plots the data.
    function plotData(~,~,~)
        if strcmp(Settings.displayStyle,'stairs')
            histogram(axData,'Data',Settings.data,'NumBins',Settings.numBins,'Normalization',Settings.normalization,'DisplayStyle',Settings.displayStyle,'EdgeAlpha',Settings.edgeAlpha,'EdgeColor',Settings.edgeColor,'FaceAlpha',Settings.faceAlpha,'FaceColor',Settings.faceColor,'LineStyle',Settings.lineStyle,'LineWidth',Settings.lineWidth);
        else
            histogram(axData,'Data',Settings.data,'NumBins',Settings.numBins,'Normalization',Settings.normalization,'DisplayStyle',Settings.displayStyle,'EdgeAlpha',Settings.edgeAlpha,'EdgeColor',Settings.edgeColor,'FaceAlpha',Settings.faceAlpha,'FaceColor',Settings.faceColor,'LineStyle',Settings.lineStyle,'LineWidth',Settings.lineWidth);
        end
        xlabel(axData,Settings.xLabel,'Color','k','FontUnits','Normalized','FontSize',0.075,'FontWeight','bold');
        ylabel(axData,Settings.yLabel,'Color','k','FontUnits','Normalized','FontSize',0.075,'FontWeight','bold');
        set(axData,'FontUnits','Normalized','FontSize',0.05,'FontWeight','bold','LineWidth',Settings.lineWidthAxis);
        box(axData,Settings.box);
    end

    % Function to update the settings.
    function updateSettings(~,~,~)

        % Set the default settings or take the settings from the user.
        if isempty(Settings)

            % Set the default values.
            Settings.numBins = ceil(sqrt(numel(Data)));
            Settings.displayStyle = 'bar';
            Settings.edgeColor = 'Black';
            Settings.edgeAlpha = 1;
            Settings.faceAlpha = 0.6;
            Settings.faceColor = 'auto';
            Settings.lineStyle = '-';
            Settings.lineWidth = 0.5;
            Settings.normalization = 'count';

            Settings.box = 1;
            Settings.xLabel = 'Periodicity (µm)';
            Settings.yLabel = 'Frequency';
            Settings.dataUnit = 'µm';
            Settings.lineWidthAxis = 2;

        else

            % Take the settings from the user.
            Settings.numBins = round(str2double(numBinsBox.String));
            Settings.displayStyle = displayStyleBox.String{displayStyleBox.Value};
            Settings.normalization = NormalizationBox.String{NormalizationBox.Value};

            Settings.edgeColor = edgeColorBox.String{edgeColorBox.Value};
            Settings.edgeAlpha = round(str2double(edgeAlphaBox.String),2);
            Settings.lineWidth = round(str2double(lineWidthBox.String),2);
            Settings.lineStyle = lineStyleBox.String{lineStyleBox.Value};

            Settings.faceAlpha = round(str2double(faceAlphaBox.String),2);
            Settings.faceColor = faceColorBox.String{faceColorBox.Value};

            Settings.box = plotBoxBox.Value;
            Settings.dataUnit = dataUnitBox.String{dataUnitBox.Value};
            Settings.lineWidthAxis = round(str2double(lineWidthAxisBox.String),2);

        end

        % Do some general updates and checks.
        if strcmp(Settings.displayStyle,'Stairs')
            Settings.faceColor = 'none';
            faceColorBox.Value = 9;
            faceColorBox.Enable = 'off';
            Settings.faceAlpha = 0.6;
            faceAlphaBox.String = num2str(0.6);
            faceAlphaBox.Enable = 'off';

            Changed = 1;
        elseif strcmp(Settings.displayStyle,'Bar') & Changed == 1
            Settings.faceColor = 'Default';
            faceColorBox.Value = 1;
            faceColorBox.Enable = 'on';
            Settings.faceAlpha = 0.6;
            faceAlphaBox.String = num2str(0.6);
            faceAlphaBox.Enable = 'on';

            Changed = 0;
        end

        switch Settings.normalization
            case 'Count'
                Settings.yLabel = 'Frequency';
            case 'Probability' 
                Settings.yLabel = 'Relative probability';
            case 'Percentage' 
                Settings.yLabel = 'Relative percentage (%)';
            case 'Countdensity'
                Settings.yLabel = 'Count density';
            case 'Cumulative count'
                Settings.normalization = 'cumcount';
                Settings.yLabel = 'Cumulative count';
            case 'pdf'
                Settings.yLabel = 'Probability density function';
            case 'cdf'
                Settings.yLabel = 'Cumulative distribution function';
        end

        if Settings.edgeAlpha < 0
            Settings.edgeAlpha = 0;
            edgeAlphaBox.String = num2str(0);
        elseif Settings.edgeAlpha > 1
            Settings.edgeAlpha = 1;
            edgeAlphaBox.String = num2str(1);
        end

        if Settings.lineWidth < 0.5
            Settings.lineWidth = 0.5;
            lineWidthBox.String = num2str(0.5);
        end

        if Settings.faceAlpha < 0
            Settings.faceAlpha = 0;
            faceAlphaBox.String = num2str(0);
        elseif Settings.faceAlpha > 1
            Settings.faceAlpha = 1;
            faceAlphaBox.String = num2str(1);
        end

        if strcmp(Settings.faceColor,'Default')
            Settings.faceColor = 'auto';
        end

        if Settings.box == 1
            Settings.box = 'on';
        else
            Settings.box = 'off';
        end

        if strcmp(Settings.dataUnit,'µm')
            Settings.data = Data;
            Settings.xLabel = 'Periodicity (µm)';
        else
            Settings.data = Data_nm;
            Settings.xLabel = 'Periodicity (nm)';
        end

        if Settings.lineWidthAxis < 0.5
            Settings.lineWidthAxis = 0.5;
            lineWidthAxisBox.String = num2str(0.5);
        end

        % Update the plots.
        plotData()
    end

end