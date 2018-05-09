function [displayRegionsFound] = displayFound(originalIm, PixelsIdxList, numCells)
%Creates an overlay image of the original frame and the identified cells
    
    if numCells > 1
        redChannel = originalIm; % Initialize.
        blueChannel = originalIm; % Initialize.
        greenChannel = originalIm; % Initialize.
        for i = 1 : numCells
            finalPixels = [PixelsIdxList(i)];
            %blueChannel(finalPixels{1,1}) = 0; % original regions
            %redChannel(finalPixels{1,1}) = 0; %after filtering
            greenChannel(finalPixels{1,1}) = 0; %original image
        end
        displayRegionsFound = (cat(3, redChannel, greenChannel, blueChannel));
        %imshow(displayRegionsFound);
    else %only 1 cell
        redChannel = originalIm; % Initialize.
        blueChannel = originalIm; % Initialize.
        greenChannel = originalIm; % Initialize.
        finalPixels = [PixelsIdxList];
        %blueChannel(finalPixels{1,1}) = 0; % original regions
        %redChannel(finalPixels{1,1}) = 0; %after filtering
        greenChannel(finalPixels) = 0; %original image

        displayRegionsFound = (cat(3, redChannel, greenChannel, blueChannel));
        %imshow(displayRegionsFound);
    end
end