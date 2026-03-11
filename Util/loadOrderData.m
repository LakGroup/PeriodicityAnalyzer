function newData = loadOrderData(listbox)

% Initialize the data.
MaskData = {}; % Initially, no Masks.
RenderedData = {}; % Initially, no rendered data.
newData = {}; % No new data initially.

% Create UIFigure
fig = figure();
set(fig,'Name','Periodicity analysis - Load Data','NumberTitle','Off','Units','Normalized','Position',[0.2 0.2 0.65 0.65],'Menubar','None','Resize','off')

% Create panel for the original data and add the list panel.
panel1 = uipanel(fig, 'Title', 'Masks','FontUnits','Normalized','FontSize',0.035,'FontWeight','bold', 'Units', 'Normalized', 'Position', [0.05 0.1 0.4 0.8]);
listbox1 = uicontrol(panel1,'Style','listbox','Units','Normalized','Position',[0.02 0.02 0.85 0.975],'BackgroundColor','w','FontUnits','Normalized','FontSize',0.03,'Max',100);
% listbox1 = uilistbox(panel1, 'Items', {}, 'Multiselect', 'On', 'Position', [10 10 340 440]);

% Add all the needed buttons for the Mask Data.
uicontrol(fig,'Style','pushbutton','Units','Normalized','Position',[0.05,0.925,0.4,0.05],'String','Load Masks','FontUnits','Normalized','FontSize',0.6,'FontWeight','bold','callback',{@loadData,listbox1,1});
uicontrol(panel1,'Style','pushbutton','Units','Normalized','Position',[0.89,0.5575,0.09,0.1],'String','ʌ','FontUnits','Normalized','FontSize',0.4,'callback',{@moveItem,listbox1,-1,1});
uicontrol(panel1,'Style','pushbutton','Units','Normalized','Position',[0.89,0.4475,0.09,0.1],'String','v','FontUnits','Normalized','FontSize',0.4,'callback',{@moveItem,listbox1,1,1});
uicontrol(panel1,'Style','pushbutton','Units','Normalized','Position',[0.89,0.3375,0.09,0.1],'String','Del','FontUnits','Normalized','FontSize',0.4,'callback',{@delItem,listbox1,1});

% Create panel for the rendered Data and add the list panel.
panel2 = uipanel(fig, 'Title', 'Rendered Data','FontUnits','Normalized','FontSize',0.035,'FontWeight','bold', 'Units', 'Normalized', 'Position', [0.55 0.1 0.4 0.8]);
listbox2 = uicontrol(panel2,'Style','listbox','Units','Normalized','Position',[0.02 0.02 0.85 0.975],'BackgroundColor','w','FontUnits','Normalized','FontSize',0.03,'Max',100);
% listbox2 = uilistbox(panel2, 'Items', {}, 'Multiselect', 'On', 'Position', [10 10 340 440]);

% Add all the needed buttons for the rendered Data
uicontrol(fig,'Style','pushbutton','Units','Normalized','Position',[0.55,0.925,0.4,0.05],'String','Load rendered data','FontUnits','Normalized','FontSize',0.6,'FontWeight','bold','callback',{@loadData,listbox2,2});
uicontrol(panel2,'Style','pushbutton','Units','Normalized','Position',[0.89,0.5575,0.09,0.1],'String','ʌ','FontUnits','Normalized','FontSize',0.4,'callback',{@moveItem,listbox2,-1,2});
uicontrol(panel2,'Style','pushbutton','Units','Normalized','Position',[0.89,0.4475,0.09,0.1],'String','v','FontUnits','Normalized','FontSize',0.4,'callback',{@moveItem,listbox2,1,2});
uicontrol(panel2,'Style','pushbutton','Units','Normalized','Position',[0.89,0.3375,0.09,0.1],'String','Del','FontUnits','Normalized','FontSize',0.4,'callback',{@delItem,listbox2,2});

% Create OK and Cancel buttons
uicontrol(fig,'Style','pushbutton','Units','Normalized','Position',[0.34,0.02,0.15,0.05],'String','OK','FontUnits','Normalized','FontSize',0.6,'FontWeight','bold','callback',{@acceptLists});
uicontrol(fig,'Style','pushbutton','Units','Normalized','Position',[0.51,0.02,0.15,0.05],'String','Cancel','FontUnits','Normalized','FontSize',0.6,'FontWeight','bold','callback',{@cancelLists});

% Tell the program to stop until OK or Cancel is pressed.
uiwait(fig)

    % Function to load the data
    function loadData(~,~,listbox, panelNmb)

        % If we want to load STORM data, only show .mat files.
        % Else, only show .txt files
        if panelNmb == 1
            [filename,path] = uigetfile({'*.tif;*.tiff'},'Load the Mask data (Tau channel).','MultiSelect','on');
        else
            [filename,path] = uigetfile({'*.tif;*.tiff'},'Load the rendered data.','MultiSelect','on');
        end

        if ~isequal(filename, 0)
        
            % Make the filenames. Do this by checking if multiple files were
            % checked or not.
            if iscell(filename) && size(filename,2) > 1
                fullName = cell(1,size(filename,2));
                for FileNumber = 1:size(filename,2)
                    fullName{FileNumber} = fullfile(path,filename{FileNumber}); % Make it a full name to save it as later.
                end
            elseif ~iscell(filename) || (iscell(filename) && size(filename,2) == 1)
                fullName{1} = fullfile(path,filename); % Make it a full name to save it as later.
                filename = {filename}; % Convert to a cell to avoid problems later
            end
    
            % Load the Masks of all the files selected, and make sure that
            % they're properly added to the data. Also add their names to the 
            % list panel.
            % Else, load the rendered data. Make sure they're properly added to
            % the data. Then add their names to the list panel.
            Data = cell(1,size(fullName,2));
            if panelNmb == 1
                wb = waitbar(0,['Loading mask data... 0/' num2str(numel(filename))]);
                for i = 1:size(fullName,2)
                    % Update the waitbar.
                    waitbar(i/numel(fullName),wb,['Loading mask data... ',num2str(i),'/',num2str(numel(filename))]);
                    drawnow
                    
                    Data{i}.data = single(mean(loadtiff(fullName{i}),3));
                    [~,newName] = fileparts(fullName{i});
                    Data{i}.name = newName;
    
                    if isempty(listbox.String)
                        listbox.String = cellstr(newName);
                    else
                        listbox.String = vertcat(cellstr(listbox.String),cellstr(newName));
                    end
                end
                MaskData = horzcat(MaskData,Data);
                close(wb)
            elseif panelNmb == 2
                wb = waitbar(0,['Loading rendered data... 0/' num2str(numel(filename))]);
                for i = 1:size(fullName,2)
                    % Update the waitbar.
                    waitbar(i/numel(fullName),wb,['Loading rendered data... ',num2str(i),'/',num2str(numel(filename))]);
                    drawnow
    
                    tmp = loadtiff(fullName{i});
                    tmpSum = nan(1,size(tmp,3));
                    for j = 1:size(tmp,3)
                        tmpSum(j) = sum(sum(tmp(:,:,j)));
                    end
                    [~,maxChannel] = max(tmpSum);
                    Data{i}.data = single(tmp(:,:,maxChannel));
                    [~,newName] = fileparts(fullName{i});
                    Data{i}.name = newName;
                    
                    if isempty(listbox.String)
                        listbox.String = cellstr(newName);
                    else
                        listbox.String = vertcat(cellstr(listbox.String),cellstr(newName));
                    end
                end
                RenderedData = horzcat(RenderedData,Data);
                close(wb)
            end
        end
        figure(fig)

    end

    % Function to move items in the listbox.
    function moveItem(~,~,listbox, direction, data)

        % Extract the files that were selected in the full list.
        selected = listbox.Value;
        selectedString = listbox.String(selected,:);

        % Loop over all the selected ones, and then change their positions.
        % We use the same function for moving up or down, so we have to
        % check which direction is pressed.
        % We have to do the same for the names in the list, but then also
        % have to do it for the data.
        for i = 1:numel(selected)

            % When we want to move the files up.
            if direction == -1 && selected(i) > 1

                % Find the one that should be moved up.
                currentString = selectedString(i,:);
                currentIdx = find(cellfun(@(x) strcmp(currentString,x),cellstr(listbox.String)));

                % Move the list names up.
                listbox.String([currentIdx, currentIdx-1],:) = listbox.String([currentIdx-1, currentIdx],:);

                % Check whether the Mask data or the Rendered Data was
                % selected and move these up as well.
                if data == 1
                    MaskData([currentIdx, currentIdx-1]) = MaskData([currentIdx-1, currentIdx]);
                else
                    RenderedData([currentIdx, currentIdx-1]) = RenderedData([currentIdx-1, currentIdx]);
                end

            % When we want to move the files down.
            elseif direction == 1 && selected(i) < size(listbox.String,1)

                % Move the list names down.
                listbox.String([selected(i), selected(i)+1],:) = listbox.String([selected(i)+1, selected(i)],:);

                % Check whether the Mask data or the Rendered Data was
                % selected and move these down as well.
                if data == 1
                    MaskData([selected(i), selected(i)+1]) = MaskData([selected(i)+1, selected(i)]);
                else
                    RenderedData([selected(i), selected(i)+1]) = RenderedData([selected(i)+1, selected(i)]);
                end

            end

        end

        % Update the selected ones.
        newSelectedIdx = nan(1,numel(selected));
        for i = 1:numel(selected)
            newSelectedIdx(i) = find(cellfun(@(x) strcmp(selectedString(i,:),x),cellstr(listbox.String)));
        end
        listbox.Value = newSelectedIdx;

    end

    % Function to delete items in the listbox.
    function delItem(~,~,listbox, data)

        % Check which files were selected in the box.
        selected = listbox.Value;

        % We have to find out the ones we want to keep by removing the IDs
        % of the selected ones from the full list.
        allIdx = 1:size(listbox.String,1);
        keepIdx = setdiff(allIdx,selected);

        % Delete the files in the list.
        listbox.Value = [];
        listbox.String = listbox.String(keepIdx,:);

        % Delete the data from the full data. We do this by checking which
        % list we were looking at.
        if data == 1
            MaskData = MaskData(keepIdx);
        else
            RenderedData = RenderedData(keepIdx);
        end

    end

    % Function to accept lists.
    function acceptLists(~,~,~)

        % Tell the program to continue .
        uiresume(fig)

        % Check the numbers of files to make sure you selected an equal number of
        % them to do the 1 - 1 comparison.
        if size(MaskData,2) ~= size(RenderedData,2)
            errordlg(['You selected the wrong number of files: Masks - ' num2str(size(MaskData,2)) ' files; Rendered data - ' num2str(size(RenderedData,2)) ' files.']);
            % Tell the program to stop until OK or Cancel is pressed.
            uiwait(fig)
        else
            % Combine the data into one data set.
            newData = cell(1,numel(RenderedData));
            listboxName = cell(1,numel(RenderedData));
            for i = 1:numel(RenderedData)
                newData{i}.data.renderedImage = RenderedData{i}.data;
                newData{i}.name = RenderedData{i}.name;
                newData{i}.data.maskImage = MaskData{i}.data;
                listboxName{i} = RenderedData{i}.name;
            end

            % Update the listbox values shown in the software.
            if isempty(listbox.String)
                listbox.String = cellstr(listboxName);
            else
                listbox.String = vertcat(cellstr(listbox.String),cellstr(listboxName));
            end

            % The figure can be closed.
            close(fig)
        end

    end

    % Function to cancel lists.
    function cancelLists(~,~,~)

        % Tell the program to continue .
        uiresume(fig)

        % Set the files that were selected to empty.
        newData = {};

        % The figure can be closed.
        close(fig)
    end
end