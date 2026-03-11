function saveSession(Data)

% Select the name of the .mat file that has to be loaded.
[filename,path] = uiputfile('Session_PeriodicityResults.mat','Select *.mat file to save the data.');

% Check if a filename was selected.
if isequal(filename, 0)
    return
else
    % Construct the full file name and delete if the file already exists.
    filename = fullfile(path,filename);
    if exist(filename,'file') == 2
        delete(filename);
    end

    % Show a waitbar so it is known when it is done.
    wb = waitbar(0.5,'Saving the data as a .mat file');

    % Save the MATLAB session
    save('-v7.3',filename,'Data');

    % Show a waitbar so it is known when it is done.
    waitbar(1,wb,'Saving the data as a .mat file');
    pause(0.5)
    close(wb)
end

end