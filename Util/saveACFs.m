function saveACFs(Data)

% Select the filename you want to save the data as.
[filename,path] = uiputfile({'ACFs.xlsx'},'Filename of the Autocorrelation functions.');

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
wb = waitbar(0,['Saving the auto-correlation functions to a .xlsx file: ' num2str(0) '/' num2str(numel(Data))]);

% Construct the data.
Periodicity = cell(1,numel(Data));
sheetName = cell(1,numel(Data));
for i = 1:numel(Data)
    % Update the waitbar.
    waitbar(i/numel(Data),wb,['Saving the auto-correlation functions to a .xlsx file: ' num2str(i) '/' num2str(numel(Data))]);
    drawnow;

    % Extract the lag.
    [~,idxMaxLag] = max(cellfun(@(x) max(x),Data{i}.periodicity.lags));
    Lag = (Data{i}.periodicity.lags{idxMaxLag}*1000)';

    % Extract the periodicity for each segment.
    Periodicity{i} = vertcat(Data{i}.periodicity.periodicity{:})*1000;

    % Extract the ACFs for each segment.
    ACF = nan(numel(Lag),numel(Data{i}.periodicity.lags));
    for j = 1:numel(Data{i}.periodicity.lags)
        ACF(1:numel(Data{i}.periodicity.lags{j}),j) = Data{i}.periodicity.autoCorrelationFunction{j};
    end

    % Write the table of the ACF to the excel file.
    tableToWrite = array2table(horzcat(Lag,ACF,mean(ACF,2)));
    tableToWrite.Properties.VariableNames = horzcat({"Lags"},"Segment "+arrayfun(@string, 1:numel(Data{i}.periodicity.lags)),{"Mean ACF"});
    sheetName{i} = regexprep(Data{i}.name,'[\\/:*"<>|]*','');
    tmp = sheetName{i}(1:31);
    sheetName{i} = horzcat(sheetName{i},'_(nm)');
    writetable(tableToWrite,filename,'sheet',tmp); % Write the table to the Excel file.
end

% Close the waitbar.
close(wb)

% Transform the periodicity results to a table.
maxSegments = max(cellfun(@(x) numel(x),Periodicity));
PeriodicityTable = nan(maxSegments+1,numel(Periodicity));
for i = 1:numel(Periodicity)
    PeriodicityTable(1:numel(Periodicity{i}),i) = round(Periodicity{i});
    PeriodicityTable(end,i) = mean(Periodicity{i},'omitnan');
end
globalMean = round(mean(PeriodicityTable(:),'omitnan'),2);
PeriodicityTable = vertcat(round(PeriodicityTable,2),nan(1,size(PeriodicityTable,2)));
PeriodicityTable(end,1) = globalMean;
PeriodicityTable = array2table(PeriodicityTable);
PeriodicityTable = horzcat(vertcat(table(("Segment "+arrayfun(@string, 1:maxSegments))'),table("Average (nm)"),table("Global average (nm)")),PeriodicityTable);
PeriodicityTable.Properties.VariableNames = horzcat({' '},sheetName);
writetable(PeriodicityTable,filename,'sheet','Periodicity'); % Write the table to the Excel file.

end