function AnalyzePeriodicity()

% Make sure all the functions can be found by the MATLAB path.
addpath(genpath(pwd));

% Initialize the data
Data = {}; % Initially, no data.

% Create Figure
BrowserFig = figure('Name','Periodicity Analyzer','NumberTitle','Off','Units','Normalized','Position',[0.05 0.25 0.4 0.65],'Menubar','None','Resize','off','CloseRequestFcn',{@closeCallback});

% Create the controls for the data browser.
listbox = uicontrol(BrowserFig,'Style','listbox','Units','Normalized','Position',[0.05,0.05,0.85,0.8],'BackgroundColor','w','FontUnits','Normalized','FontSize',0.03,'Max',100);
upButton = uicontrol(BrowserFig,'Style','pushbutton','Units','Normalized','Position',[0.92,0.5,0.06,0.075],'String','ʌ','FontUnits','Normalized','FontSize',0.4,'Enable','off','callback',{@move_item,listbox,-1});
downButton = uicontrol(BrowserFig,'Style','pushbutton','Units','Normalized','Position',[0.92,0.4125,0.06,0.075],'String','v','FontUnits','Normalized','FontSize',0.4,'Enable','off','callback',{@move_item,listbox,1});
deleteButton = uicontrol(BrowserFig,'Style','pushbutton','Units','Normalized','Position',[0.92,0.325,0.06,0.075],'String','Del','FontUnits','Normalized','FontSize',0.4,'Enable','off','callback',{@del_item,listbox});

% Create the buttons that are found in this analysis GUI.
uicontrol(BrowserFig,'Style','pushbutton','Units','Normalized','Position',[0.05,0.92,0.13,0.05],'FontUnits','Normalized','FontSize',0.5,'String','Load data','callback',{@load_data,listbox});
uicontrol(BrowserFig,'Style','pushbutton','Units','Normalized','Position',[0.19,0.92,0.17,0.05],'FontUnits','Normalized','FontSize',0.5,'String','Load .mat file','callback',{@load_mat,listbox});
saveButton = uicontrol(BrowserFig,'Style','pushbutton','Units','Normalized','Position',[0.37,0.92,0.17,0.05],'FontUnits','Normalized','FontSize',0.5,'String','Save .mat file','Enable','off','callback',{@save_mat});
renameButton = uicontrol(BrowserFig,'Style','pushbutton','Units','Normalized','Position',[0.79,0.92,0.19,0.05],'FontUnits','Normalized','FontSize',0.5,'String','Rename file(s)','Enable','off','callback',{@rename_file,listbox});
plotButton = uicontrol(BrowserFig,'Style','pushbutton','Units','Normalized','Position',[0.05,0.86,0.18,0.05],'FontUnits','Normalized','FontSize',0.5,'String','Plot periodicity','Enable','off','callback',{@plot_periodicity,listbox});
recalcButton = uicontrol(BrowserFig,'Style','pushbutton','Units','Normalized','Position',[0.24,0.86,0.27,0.05],'FontUnits','Normalized','FontSize',0.5,'String','Recalculate periodicity','Enable','off','callback',{@recalculate_periodicity,listbox});
segmentButton = uicontrol(BrowserFig,'Style','pushbutton','Units','Normalized','Position',[0.52,0.86,0.26,0.05],'FontUnits','Normalized','FontSize',0.5,'String','Update segmentation','Enable','off','callback',{@update_segmentation,listbox});
histogramButton = uicontrol(BrowserFig,'Style','pushbutton','Units','Normalized','Position',[0.79,0.86,0.19,0.05],'FontUnits','Normalized','FontSize',0.5,'String','Histogram','Enable','off','callback',{@show_Histogram,listbox});

    % Function to load the data.
    function load_data(~,~,listbox)
        newData = loadOrderData(listbox);
        Data = horzcat(Data,newData);
        ToggleButtons(listbox);
    end

    % Function to move data up or down.
    function move_item(~,~,listbox,Value)
        Data = change_itemOrder(listbox,Value,Data);
    end

    % Function to delete selected data.
    function del_item(~,~,listbox)
        Data = delete_Data(listbox,Data);
        ToggleButtons(listbox);
    end

    % Function to calculate the periodicity.
    function plot_periodicity(~,~,listbox)
        selectedData = listbox.Value;
        Data(selectedData) = plotPeriodicity(Data(selectedData));
        ToggleButtons(listbox);
    end

    % Function to calculate the periodicity.
    function recalculate_periodicity(~,~,listbox)
        selectedData = listbox.Value;
        Data(selectedData) = calcPeriodicity(Data(selectedData));
        ToggleButtons(listbox);
    end

    % Function to update the segmentation parameters.
    function update_segmentation(~,~,listbox)
        selectedData = listbox.Value;
        Data(selectedData) = calcSegmentation(Data(selectedData));
        ToggleButtons(listbox);
    end

    % Function to update the segmentation parameters.
    function show_Histogram(~,~,listbox)
        selectedData = listbox.Value;
        
        % Extract the values to decrease memory usage by just working with
        % the values.
        Periodicity = cell(1,numel(selectedData));
        for i = 1:numel(selectedData)
            if ~isempty(Data{selectedData(i)}.periodicity.periodicity)
                Periodicity{selectedData(i)} = Data{selectedData(i)}.periodicity.periodicity;
            end
        end
        Periodicity = cell2mat(horzcat(Periodicity{:}));

        % Show the histogram plot.
        showHistograms(Periodicity);
    end

    % Function to load a .mat file to continue working on it.
    function load_mat(~,~,listbox)
        newData = loadSession(listbox);
        Data = horzcat(Data,newData);
        ToggleButtons(listbox);
    end

    % Function to save a .mat file.
    function save_mat(~,~,~)
        saveSession(Data);
    end

    % Function to rename a file.
    function rename_file(~,~,listbox)
        selectedData = listbox.Value;
        [Data(selectedData),names] = renameFiles(Data(selectedData));
        listbox.String(selectedData) = names;
    end

    function ToggleButtons(listbox)

        % Toggle all the buttons that should be enabled if there is 1 file
        % or more.
        if numel(listbox.String) > 0
            deleteButton.Enable = 'on';
            saveButton.Enable = 'on';
            renameButton.Enable = 'on';
            plotButton.Enable = 'on';
            recalcButton.Enable = 'on';
            segmentButton.Enable = 'on';
        end

        % Toggle all the buttons that should be enabled if there are 2
        % files or more.
        if numel(listbox.String) > 1
            upButton.Enable = 'on';
            downButton.Enable = 'on';
        end

        % Toggle all the buttons that should be enabled if there is 1 file
        % or more.
        if numel(listbox.String) < 1
            deleteButton.Enable = 'off';
            saveButton.Enable = 'off';
            renameButton.Enable = 'off';
            plotButton.Enable = 'off';
            recalcButton.Enable = 'off';
            segmentButton.Enable = 'off';
        end

        % Toggle all the buttons that should be enabled if there are 2
        % files or more.
        if numel(listbox.String) < 2
            upButton.Enable = 'off';
            downButton.Enable = 'off';
        end

        % Toggle the button for the histogram.
        Periodicity = cell(1,numel(Data));
        for i = 1:numel(Data)
            if ~isempty(Data{i}.periodicity.periodicity)
                Periodicity{i} = Data{i}.periodicity.periodicity;
            end
        end
        Periodicity = cell2mat(horzcat(Periodicity{:}));

        if ~isempty(Periodicity)
            histogramButton.Enable = 'on';
        else
            histogramButton.Enable = 'off';
        end

        % Do the update.
        drawnow;

    end

    % Close confirmation dialog.
    function closeCallback(~,~,~)
        
        % Show a confirmation dialog.
        Selection = questdlg('Are you sure you want to exit the Periodicity Analyzer?','Periodicity Analyzer', 'Save before closing', 'Close without saving', 'Cancel', 'Cancel');

        % Perform the actions.
        switch Selection
            case 'Save before closing'
                saveSession(Data);
                delete(BrowserFig)
            case 'Close without saving'
                delete(BrowserFig)
            case 'Cancel'
                return
        end

    end

end