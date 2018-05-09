function [intensityResults] = intensity(startPoint, endPoint, cellHistory, cytoOut, resultsOut)
    numFrames = endPoint - startPoint + 1;
    folder = dir(cytoOut);

    intensityResults = zeros(size(cellHistory, 1), numFrames);

    finalCells = cellHistory(:,numFrames*3);
    sus = [];
    counter = 1;
    for cell = 1:length(finalCells)
        if isempty(finalCells{cell}) == 0
            sus = [sus, counter];
        end
        counter = counter + 1;
    end

    frameCount = 1;
    for i = 3:3:size(cellHistory, 2)
        cytoIm = imread(char(folder(frameCount+2).name));
        if i == 3
            for cell = sus
                if ~isempty(cellHistory{cell, i})
                    pixelIDx = cellHistory{cell, i}{1, 8};
                    pixelsInIm = cytoIm(pixelIDx);
                    avIn = sum(pixelsInIm) / length(pixelIDx);
                    avIn = avIn/2.55; %convert to percentage, with 255 being max
                    intensityResults(cell, frameCount) = avIn;
                    prevAvIn = avIn;
                else
                    intensityResults(cell, frameCount) = prevAvIn;
                end
            end
        else
            for cell = sus
                if ~isempty(cellHistory{cell, i})
                    pixelIDx = cellHistory{cell, i}{1, 9};
                    pixelsInIm = cytoIm(pixelIDx);
                    avIn = sum(pixelsInIm) / length(pixelIDx);
                    avIn = avIn/2.55; %convert to percentage, with 255 being max
                    intensityResults(cell, frameCount) = avIn;
                    prevAvIn = avIn;
                else
                    intensityResults(cell, frameCount) = prevAvIn;
                end
            end
        end
        frameCount = frameCount + 1;
    end

    data = intensityResults(sus, 1:numFrames);
    numcells = length(sus);
    avList = [];
    for i = 1:numFrames
        average = sum(data(:, i))/numcells;
        avList = [avList, average];
    end

    figure(2)
    for cell = 1:numcells
        plot(data(cell, :))
        hold on
    end

    plot(avList, 'k--o');
    title('Average stain intensity of tracked nuclei'); 
    xlabel('Frame');
    ylabel('Average pixel value');
    hold off
    
    savefig(strcat(resultsOut, '/nuclearIntensity.fig'));
end

