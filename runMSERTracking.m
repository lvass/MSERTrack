function [cellHistory, trackedCellsOnFrame, numCellsOnFrame] = runMSERTracking(nucOut,...
    minCellArea, maxCellArea, TD, MAV, ER, distChangeLimit, frameSkipLimit, startPoint, endPoint)
%Coordinates the two-step tracking process

trackedCellsOnFrame = [];
numCellsOnFrame = [];

folder = nucOut;
experiment = dir(folder);
frames = [];
for i = 1:length(experiment)
    filename = experiment(i).name;
    if length(filename) > 2
        fullFilename = strcat(folder, '/', experiment(i).name);
        frames = [frames; {fullFilename}];
    end
end
frames = sortrows(frames);
numFrames = length(frames);
outputFolder = strcat(folder, '/masks');
mkdir(outputFolder);

for f = startPoint:endPoint
    %disp(f);
    %first frame - just take mask and names cells
    if f == startPoint
        image1 = imread(char(frames(f)));
        image1 = imadjust(image1);
        name = frames{f};
        image1Name = strcat(outputFolder, '/mask_', name(end-6:end-4), '.bmp');
        [mask] = MSERTracking(image1, minCellArea, maxCellArea, TD, MAV, ER);
        imwrite(mask, image1Name);
        [allCellData, numCellsOnFrame] = findAndNameCells(mask, f, image1, numCellsOnFrame);
        s = size(allCellData);
        numCells = s(1);
        %intializing CellHistory
        cellHistory = repmat([0, 0, {allCellData(1, 3:10)}], numCells, 1);
        for i = 1:numCells
            cellHistory(i, :) = [allCellData(i, 1), allCellData(i, 2),...
                {allCellData(i, 3:10)}];
        end
        disp(size(cellHistory,1));
        PrevCellsRef = allCellData;
        frameSkippers = [];
    end
    %if not first frame, compare current cells to previous cells
    if f > startPoint
        %opening and naming frame
        image1 = imread(char(frames(f)));
        image1 = imadjust(image1);
        name = frames{f};
        image1Name = strcat(outputFolder, '/mask_', name(end-6:end-4), '.bmp');
        %making mask image
        [mask] = MSERTracking(image1, minCellArea, maxCellArea, TD, MAV, ER);
        imwrite(mask, image1Name); %saving mask
        %finding regions in mask image
        [CurrentCellsRef, numCellsOnFrame] = findAndNameCells(mask, f, image1, numCellsOnFrame);
    
        %then, compare current to previous and rename matches
        [matchedCellsRef, frameSkippers] = compareMasksTrack(PrevCellsRef,...
            CurrentCellsRef, frameSkippers, frameSkipLimit, distChangeLimit, f);
        
        if isempty(matchedCellsRef) == 1 && isempty(frameSkippers) == 1
            disp('No matches found in frame and no frameskippers');
            break
        end
        if isempty(matchedCellsRef) == 1
           disp('No cells added to history for this frame');
           PrevCellsRef = [];
        else
            [cellHistory, trackedCellsOnFrame] = addToHistory(cellHistory, matchedCellsRef, f, numFrames, trackedCellsOnFrame);
            PrevCellsRef = matchedCellsRef;
        end
    end
end
disp('Program ending');
toc