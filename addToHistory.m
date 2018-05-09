function [cellHistory, trackedCellsOnFrame] = addToHistory(cellHistory, matchedCellsRef, f, numFrames, trackedCellsOnFrame)
%Adds cell information to the cell history based on the 'best matches'
    %disp('Adding matches to cell history');
    %disp(f);
    matchedCellsRef = sortrows(matchedCellsRef, 1);
    counter = 0;
    for i = 1:size(matchedCellsRef,1)
        place = [1:3:numFrames*3];
        %IDloc = place(f-1); %find the last cells ID here
        pasteLoc = (place(f-1))+3; %where to start inputing cell data
        matchedCellID = matchedCellsRef{i,1};
        %disp(matchedCellID);
        visited = 0;
        for x = 1:size(cellHistory, 1)
            if matchedCellID == cellHistory{x,1}
                %disp('matched');
                cellHistory{x, pasteLoc} = matchedCellID;
                cellHistory{x, pasteLoc+1} = f;
                cellHistory{x, pasteLoc+2} = [matchedCellsRef(i,2:10)];
                counter = counter +1;
                visited = 1;
                %disp('not matched');
            end
        end
        %disp(visited);
    end
    numTracked = size(matchedCellsRef,1);
    disp(numTracked);
    trackedCellsOnFrame = [trackedCellsOnFrame, numTracked];
    %disp(counter);
end
        
        
                   