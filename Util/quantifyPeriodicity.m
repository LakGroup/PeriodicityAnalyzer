function Periodicity = quantifyPeriodicity(Periodicity,Settings)

% Extract the settings. This is easier to work with.
% Parameters related to the periodicity quantification.
pixelSize_Rendered = Settings.pixelSize_Rendered; % Pixel size of rendered image, in µm.

% Extract the images that are being worked with
FinalImages = Periodicity.images; % The images of the segments.

% Calculate the autocorrelation curve and periodicity.
ACF = cell(1,numel(FinalImages));
Lags = cell(1,numel(FinalImages));
Position = cell(1,numel(FinalImages));
for i = 1:numel(FinalImages)

    % Find the autocorrelation curve and calculate the periodicity.
    meanProfile = mean(FinalImages{i},1);
    [ACF{i}, Lag] = autocorr(meanProfile-mean(meanProfile),ceil(numel(meanProfile)/2));
    Lags{i} = Lag * pixelSize_Rendered;
    [~,Pos] = findpeaks(ACF{i});
    if ~isempty(Pos)
        Position{i} = Pos(1) * pixelSize_Rendered;
    end

end
IdxEmpty = cellfun(@isempty,Position);
ACF(IdxEmpty) = [];
Lags(IdxEmpty) = [];
Position(IdxEmpty) = [];
FinalImages(IdxEmpty) = [];

% Save all the outputs.
Periodicity.autoCorrelationFunction = ACF;
Periodicity.lags = Lags;
Periodicity.periodicity = Position;
Periodicity.images = FinalImages;
Periodicity.settings = Periodicity.settings;