function Data = delete_Data(listbox,Data)

% Check which files were selected in the box.
idxSelected = listbox.Value;

% We have to find out the ones we want to keep by removing the IDs of the
% selected ones from the full list.
allIdx = 1:numel(listbox.String);
keepIdx = setdiff(allIdx,idxSelected);

% Delete the files in the list.
listbox.String = listbox.String(keepIdx);

% Delete the data from the full data. We do this by checking which list we
% were looking at.
Data = Data(keepIdx);

% Update the selected data value.
listbox.Value = [];

end