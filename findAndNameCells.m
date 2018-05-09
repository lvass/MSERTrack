function [allCellData, numCellsOnFrame] = findAndNameCells(mask, frame, originalIm, numCellsOnFrame)
%Finds regions in 1st mask, creates unqiue ID and outputs an array of info
%for each cell
    %disp('Finding and naming cells in mask image');
    image1Regions = regionprops(logical(mask), 'Centroid', 'Area',...
        'Eccentricity', 'PixelIdxList', 'BoundingBox');
    numCellsOnFrame = [numCellsOnFrame, size(image1Regions,1)];
    if size(image1Regions,1) == 0
        allCellData = [];
        %disp('No cells found in image)');
        
    else %cells found in the mask image
        
        if size(image1Regions,1) > 1 %turn into table if more than 1 cell
            image1Regions = struct2table(image1Regions);
        end

        X = image1Regions.Centroid(:,1);
        Y = image1Regions.Centroid(:,2);
        Area = image1Regions.Area;
        Ecc = image1Regions.Eccentricity;
        BoundingBox = image1Regions.BoundingBox;
        PixelsIdxList = image1Regions.PixelIdxList;
        numCells = length(X);

        %making display image
        [showFoundIm] = displayFound(originalIm, PixelsIdxList, numCells);

        if numCells == 0
            %disp('No cells found on test image');
            cellData = 0;
        else
            cellID = zeros(numCells, 1); %start with frame number
            for i = 1:numCells
                thiscellID = str2num(strcat(num2str(frame), num2str(i)));
                cellID(i) = thiscellID;
            end
            %intializing array
            cropped = imcrop(originalIm, BoundingBox(1, :));
            cellData = repmat([cellID(1), frame, X(1), Y(1), Area(1), Ecc(1),...
                {BoundingBox(1, :)}, {showFoundIm},{cropped}, PixelsIdxList(1,1)], numCells,1);
            for i = 2:numCells
                cropped = imcrop(originalIm, BoundingBox(i, :));
                cellData(i, :) = [cellID(i), frame, X(i), Y(i), Area(i), Ecc(i),...
                    {BoundingBox(i, :)}, {showFoundIm}, {cropped}, PixelsIdxList(i,1)];
            end
            allCellData = sortrows(cellData, 1);
        end
   end
end