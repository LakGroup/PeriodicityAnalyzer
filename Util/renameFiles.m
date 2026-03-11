function [Data,names] = renameFiles(Data)

% Show the prompt that will rename the file.
if ~isempty(Data)

    % Loop over all the data files.
    names = cell(1,numel(Data));
    for i = 1:numel(Data)

        % Open in input dialog for the files.
        names{i} = char(inputdlg('Change the name to:',['Rename file ' num2str(i) '/' num2str(numel(Data))],[1 75],{Data{i}.name}));
        if isempty(names{i})
            names{i} = Data{i}.name;
        end
        Data{i}.name = names{i};

    end

end