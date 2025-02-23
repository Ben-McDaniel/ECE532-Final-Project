clc; clear; close all;

% Define the main directory as the current working directory
mainDir = pwd;

% Get all folders in the main directory
folders = dir(mainDir);
folders = folders([folders.isdir]); % Keep only directories
folders = folders(~ismember({folders.name}, {'.', '..'})); % Remove . and ..

dataAvailable = false(1, numel(folders));

% Check which folders have data
for i = 1:numel(folders)
    folderPath = fullfile(mainDir, folders(i).name);
    csvFiles = dir(fullfile(folderPath, '*.csv'));
    
    for j = 1:numel(csvFiles)
        filePath = fullfile(folderPath, csvFiles(j).name);
        data = readmatrix(filePath);
        
        if size(data, 2) >= 7 && ~isempty(data)
            dataAvailable(i) = true;
            break;
        end
    end
end

validFolders = folders(dataAvailable);
numValidFolders = numel(validFolders);

% Ask user whether to display figures or save as PNGs
saveFigures = input('Save figures as PNGs? (1 for Yes, 0 for No): ');

if saveFigures
    outputDir = fullfile(mainDir, 'output-images');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
end

% Plot data only for folders that contain valid data
lineStyles = {'-', '--', ':', '-.'}; % Distinguishable in black and white
markers = {'o', 's', 'd', '^'};

for i = 1:numValidFolders
    folderPath = fullfile(mainDir, validFolders(i).name);
    csvFiles = dir(fullfile(folderPath, '*.csv'));
    
    fig = figure; % Create a new figure for each folder
    title(['Topology: ', validFolders(i).name]);
    xlabel('Epochs Trained');
    ylabel('Error');
    grid on; hold on;
    
    for j = 1:numel(csvFiles)
        filePath = fullfile(folderPath, csvFiles(j).name);
        data = readmatrix(filePath);
        
        if size(data, 2) >= 7 && ~isempty(data)
            styleIdx = mod(j-1, length(lineStyles)) + 1;
            markerIdx = mod(j-1, length(markers)) + 1;
            plot(data(:, 2), data(:, 7), lineStyles{styleIdx}, 'Marker', markers{markerIdx}, 'DisplayName', csvFiles(j).name);
        end
    end
    
    % Set the y-axis to always range from 0 to 1
    ylim([0, 1]);
    legend;
    hold off;
    
    if saveFigures
        saveas(fig, fullfile(outputDir, [validFolders(i).name, '.png']));
        close(fig);
    end
end
