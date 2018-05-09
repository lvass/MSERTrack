%% MSERTrack master file
%{
    MSERTrack automatically tracks cells through time lapse microscopy
    images/
    Copyright (C) 2018, Lucy Vass.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/ 
%}


%% User Input
%Enter parameters:
distChangeLimit = 50; %maximum movement of cells between frames
frameSkipLimit = 1; %0=off, 1=on, allows nuclei to 'disappear' from the image for up to 1 frame
minCellArea = 15*15; %minimum expected 2D area of nuclei in pixels
maxCellArea = 35*35; %maximum expected 2D area of nuclei in pixels
startPoint = 1; %number frame to start the analysis at
endPoint = 50; %frame up to which you're interested in analyzing

%MSER parameters
TD = 2; %threshold delta, 2 recomended
MAV = 0.1; %maximum area variation, 0.1 recomended
ER = 0.8; %upper eccentricity range limit, 0.8 recomended

experimentFolder = uigetdir(); %choose folder with contains .lsm images from the experiment
nucChannel = 2; %number of nuclear channel
POIchannel = 1; %protien of interest channel
numChannels = 3; %total number of microscope channels

%% Running MSERTrack
disp('Running MSERTrack')
disp('Opening image files')

files = dir(experimentFolder);
numberOfLocs = length(files) -2;
split = strsplit(experimentFolder,'/');
experimentName = split(end);
files = struct2table(files);

for loc = 3:width(files)
    tic
    filename = files.name{loc,1};
    locNum = loc -2;
    image = bfopen(strcat(experimentFolder, '/', filename));
    numOfImages = (length(image{1,1}));
    nucOut = strcat(experimentFolder, '/nucImages_', num2str(locNum));
    cytoOut = strcat(experimentFolder, '/poiImages_', num2str(locNum));
    resultsOut = strcat(experimentFolder, '/results_', num2str(locNum));
    mkdir(nucOut);
    mkdir(cytoOut);
    mkdir(resultsOut);

    listiter = 1;
    for x = nucChannel:numChannels:numOfImages
        if listiter < 10
            outfileName = char(strcat(nucOut, '/', 'nuc_', experimentName, '_L', num2str(locNum), '_Frame00', string(listiter), '.bmp'));
        end
        if listiter < 100
            outfileName = char(strcat(nucOut, '/', 'nuc_', experimentName, '_L', num2str(locNum), '_Frame0', string(listiter), '.bmp'));
        end
        if listiter >= 100 
            outfileName = char(strcat(nucOut, '/', 'nuc_', experimentName, '_L', num2str(locNum), '_Frame', string(listiter), '.bmp'));
        end
        iterImage = im2double(image{1, 1}{x,1});
        imwrite(iterImage, outfileName);
        filenameList(listiter) = string(outfileName);
        listiter = listiter +1;
    end
    
    listiter = 1;
    for x = POIchannel:numChannels:numOfImages
        if listiter < 10
            outfileName = char(strcat(cytoOut, '/', 'cyto_', experimentName, '_L', num2str(locNum), '_Frame00', string(listiter), '.bmp'));
        end
        if listiter < 100
            outfileName = char(strcat(cytoOut, '/','cyto_', experimentName, '_L', num2str(locNum),  '_Frame0', string(listiter), '.bmp'));
        end
        if listiter >= 100 
            outfileName = char(strcat(cytoOut, '/','cyto_', experimentName, '_L', num2str(locNum), '_Frame', string(listiter), '.bmp'));
        end
        iterImage = im2double(image{1, 1}{x,1});
        imwrite(iterImage, outfileName);
        filenameList(listiter) = string(outfileName);
        listiter = listiter +1;
    end
    disp('Time lapse images extracted');
    disp('Starting tracking');
    [cellHistory, trackedCellsOnFrame, numCellsOnFrame] = runMSERTracking(nucOut,...
        minCellArea, maxCellArea, TD, MAV, ER, distChangeLimit, frameSkipLimit, startPoint, endPoint);
    rawData.cellHistory = cellHistory;
    rawData.trackedCells = trackedCellsOnFrame;
    rawData.numCellsOnFrame = numCellsOnFrame;
    
    close all
    figure(1)
    plot(1:length(numCellsOnFrame)-1, trackedCellsOnFrame, 'b')
    hold on
    plot(1:length(numCellsOnFrame)-1, numCellsOnFrame(2:end), 'r')
    legend('Number of tracked cells', 'Number of identified cells')
    title('Tracking performance')
    xlabel('Frame')
    xlim([1 endPoint])
    ylabel('Number of cells')
    savefig(strcat(resultsOut, '/trackingPerformance.fig'));
    
    [intensityResults] = intensity(startPoint, endPoint, cellHistory, cytoOut, resultsOut);
    rawData.intensityResults = intensityResults;
    save(strcat(resultsOut, '/rawData.mat'), 'rawData');
    toc
end



