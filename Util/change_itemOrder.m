function Data = change_itemOrder(listbox, direction, Data)

% Extract the files that were selected in the full list.
idxSelected = listbox.Value;
currentList = listbox.String(idxSelected);

% Loop over all the selected ones, and then change their positions.
% We use the same function for moving up or down, so we have to
% check which direction is pressed.
% We have to do the same for the names in the list, but then also
% have to do it for the data.
for i = 1:numel(idxSelected)

    % When we want to move the files up.
    if direction == -1 && idxSelected(i) > 1

        % Move the list names up.
        listbox.String([idxSelected(i), idxSelected(i)-1]) = listbox.String([idxSelected(i)-1, idxSelected(i)]);

        % Change the data order.
        Data([idxSelected(i), idxSelected(i)-1]) = Data([idxSelected(i)-1, idxSelected(i)]);

    % When we want to move the files down
    elseif direction == 1 && idxSelected(i) < numel(listbox.String)

        % Move the list names down
        listbox.String([idxSelected(i), idxSelected(i)+1]) = listbox.String([idxSelected(i)+1, idxSelected(i)]);

        % Check whether the STORMData or the FISHquantData was
        % selected and move these up as well.
        Data([idxSelected(i), idxSelected(i)+1]) = Data([idxSelected(i)+1, idxSelected(i)]);

    end

end

% Update the selected values.
% If there are data with the same name, that will select all of them.
newIdxSelected = cellfun(@(x) find(matches(listbox.String,x)),currentList,'UniformOutput',false);
listbox.Value = newIdxSelected{1};

end