function newData = loadSession(listbox)

% Select the name of the .mat file that has to be loaded.
[filename,path] = uigetfile('*.mat','Select *.mat file that contains data.','MultiSelect','on');

% Check if a filename was selected.
if isequal(filename, 0)
    newData = [];
    return
else
    % Change the filename to a cell if this is not the case.
    if ~iscell(filename)
        filename = {filename};
    end

    % Show a waitbar so it is known when it is done.
    wb = waitbar(0,['Loading the .mat file(s): 0/' num2str(numel(filename))]);

    % Load the file(s).
    newData = cell(1,numel(filename));
    for i = 1:numel(filename)

        % Update the waitbar.
        waitbar(i/numel(filename),wb,['Loading the .mat file(s): ' num2str(i) '/' num2str(numel(filename))]);
        drawnow;

        % Load the data.
        file = fullfile(path,filename{i});
        tmp = load(file);
        newData{i} = tmp.Data;

    end

    % Make sure all the data is nicely ordered as it should be.
    newData = horzcat(newData{:});

    % Extract the names of the files.
    listboxName = cell(1,numel(newData));
    for i = 1:numel(newData)
        listboxName{i} = newData{i}.name;
    end

    % Change the display of the names in the browser.
    oldListBox = listbox.String;
    if size(oldListBox,1) > size(oldListBox,2)
        oldListBox = oldListBox';
    end
    listbox.String = horzcat(oldListBox,listboxName);

    % Close the waitbar
    close(wb);
end