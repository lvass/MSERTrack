function [matchedCellsRef, frameSkippers] = compareMasksTrack(PrevCellsRef,...
            CurrentCellsRef, frameSkippers, frameSkipLimit, distChangeLimit, frame);
%Compares previous frame to current frame and renames cells which are matches
    %disp('start comparision of masks');
    %initializing table for previous frame
    ACellsRef = [PrevCellsRef; frameSkippers];
    %variables: 'cellID', 'X', 'Y', 'Area', 'Ecc', 'BoundingBox', 
    %'showFoundIm', 'CroppedIm'

    %initializing table for current frame
    BCellsRef = CurrentCellsRef;
    %variables: 'cellID', 'X', 'Y', 'Area', 'Ecc', 'BoundingBox', 
    %'showFoundIm', 'CroppedIm'
    
    if isempty(BCellsRef) == 1
        %disp('No cells cells to compare to, add all A cells to notMatchedB');
        matchedCellsRef = [];
        notMatchedB = ACellsRef;
    else
        ACellsRef = sortrows(ACellsRef, 1); 
        BCellsRef = sortrows(BCellsRef, 1); 

        %comparing distances
        numACells = size(ACellsRef,1);
        allDists = [];
        noMatches = zeros(numACells);
        totalNum = 0;
        count = 0;

        for x = 1:numACells

            %first point from set A
            thisACellID = ACellsRef{x,1};
            x1 = ACellsRef{x,3};
            y1 = ACellsRef{x,4};

            %convert B to polar with A1 as 0,0
            BX = [BCellsRef{:,3}].';
            BY = [BCellsRef{:,4}].';
            BCenX = BX - x1;
            BCenY = BY - y1;
            [theta, rho] = cart2pol(BCenX, BCenY);

            BCen = [[BCellsRef{:,1}].', BX, BY, BCenX, BCenY, rho];
            %variables: 'cellID', 'BX', 'BY', 'BCenX', 'BCenY', 'rho';

            %looking for cells under distance threshold
            BCen = sortrows(BCen, 6);
            cutoff = 0;
            matchesFound = 1; %true
            for i = 1:size(BCen,1)
                if BCen(i,6) > distChangeLimit %too far away, can't be matched
                    cutoff = i-1;
                    break
                else
                    matchesFound = 0; %false
                end
            end

            if matchesFound == 1
                %disp('No matches for this cell');
                %disp(thisACellID);
                count = count + 1;
                noMatches(count) = thisACellID;
            end

            if cutoff == 0
                cutoff = 1;
            end
            if matchesFound == 0
                %disp(cutoff);
                %disp(' matches for this cell');
                %disp(thisACellID);
                closeBy = BCen(1:cutoff, :);
                cellA = repmat(thisACellID,[cutoff,1]);
                cellB = closeBy(:, 1);
                distance = closeBy(:, 6);

                closeByList = [cellA, cellB, distance];
                num = size(closeByList,1);
                allDists = [allDists; closeByList];
                totalNum = totalNum + num;
            end
        end

        % if there are no matches found, nothing added to matchedCellsRef, all
        % B cells added to 'notMatchedB'
        if isempty(allDists)
            %disp('No matches found between test and mask');
            matchedCellsRef = [];
            numNotMatched = size(BCellsRef,1);
            notMatchedB = repmat([0, 0, 0, 0, 0, 0, 0, BCellsRef(1,8), BCellsRef(1,9),...
                BCellsRef(1,10)], numNotMatched, 1);

            count = 1;
            for i = 1:size(BCellsRef,1)
                data = {BCellsRef{i,:}};
                notMatchedB(count, 1) = data(1);
                notMatchedB(count, 2) = data(2);
                notMatchedB(count, 3) = data(3);
                notMatchedB(count, 4) = data(4);
                notMatchedB(count, 5) = data(5);
                notMatchedB(count, 6) = data(6);
                notMatchedB(count, 7) = data(7);
                notMatchedB(count, 8) = data(8);
                notMatchedB(count, 9) = data(9);
                notMatchedB(count, 10) = data(10);
                count = count + 1;
            end

        %if there are some matches, look for optimum solution
        else
            %disp('Matches found between test and mask');
            allDistsSorted = sortrows(allDists, 3); %sort by distance
            %removing duplicates, remove longest distance pairs
            %looking for cellA duplicates
            toRemove = [];
            numMatched = size(allDists,1);
            for i = 1:numMatched
                topCellA = allDistsSorted(i, 1);
                for x = i+1:numMatched
                    if allDistsSorted(x, 1) == topCellA
                        toRemove = [toRemove, x];
                    end
                end
            end

            bestPairs = allDistsSorted;
            bestPairs(toRemove,:) = [];
            discardedPairs = (allDistsSorted(toRemove,:));
            discardedPairs = sortrows(discardedPairs, 3);

            %look for duplicate cellB's in best pair list
            dups = [];
            for i = 1:size(bestPairs,1)
                thisCell = bestPairs(i,2);
                z = i + 1;
                while z <= size(bestPairs,1)
                    if bestPairs(z, 2) == thisCell
                        dups = [dups; z];
                    end
                    z = z + 1;
                end
            end

            bestPairs(dups,:) = []; %remove duplicates from best pairs

            h = size(discardedPairs,1);
            %looking for alternative pairs to complete as many pairs as possible 
            for i = 1:h
                if (ismember(discardedPairs(i, 1), bestPairs(:, 1))) + ...
                        (ismember(discardedPairs(i, 2), bestPairs(:, 2))) > 0
                    %disp('already in best pairs');

                else
                    %disp('not already in best pairs');
                    transfer = discardedPairs(i, :);
                    bestPairs = [bestPairs; transfer];
                end

            end
            bestPairs = sortrows(bestPairs, 3);

            %plot cell positions on scatter graph
            %{
            figure(2)
            hold on
            scatter(A(:,1), A(:,2), 'g', '*');
            scatter(B(:,1), B(:,2), 'b', '*');
            %}

            %convert cell references to Cartesian coordinates for plotting
            %{
            for i = 1:height(bestPairs)
                %find cell A cooridnates
                cellA = bestPairs{i,1};
                row = ACellsRef.cellID==cellA;
                cellInfo = ACellsRef(row,:);
                ax = cellInfo.X;
                ay = cellInfo.Y;
                %find cell B cooridnates
                cellB = bestPairs{i,2};
                row = BCellsRef.cellID==cellB;
                cellInfo = BCellsRef(row,:);
                bx = cellInfo.X;
                by = cellInfo.Y;
                %plot on graph
                %plot([ax, bx], [ay, by]);
            end
            %}
            %looking for unmatched B cells, these are potential 'growers'
            [loc] = ~ismember([BCellsRef{:,1}], bestPairs(:,2));
            notMatchedB = zeros((size(BCellsRef,1) - size(bestPairs,1)), 1);
            count = 1;
            for i = 1:size(BCellsRef,1)
                if loc(i) == 1 
                    notMatchedB(count) = BCellsRef{i,1};
                    count = count + 1;
                end
            end

            %creating a list of not matched A cells - these are potential
            %frameskippers
            [loc] = ~ismember([ACellsRef{:,1}], bestPairs(:,1));   
            numNotMatched = size(ACellsRef,1) - size(bestPairs,1);
            notMatchedA = repmat([0, 0, 0, 0, 0, 0, 0, ACellsRef(1,8), ACellsRef(1,9),...
                ACellsRef(1,10)], numNotMatched, 1);

            count = 1;
            for i = 1:size(ACellsRef,1)
                if loc(i) == 1 
                    data = {ACellsRef{i,:}};
                    notMatchedA(count, 1) = data(1);
                    notMatchedA(count, 2) = data(2);
                    notMatchedA(count, 3) = data(3);
                    notMatchedA(count, 4) = data(4);
                    notMatchedA(count, 5) = data(5);
                    notMatchedA(count, 6) = data(6);
                    notMatchedA(count, 7) = data(7);
                    notMatchedA(count, 8) = data(8);
                    notMatchedA(count, 9) = data(9);
                    notMatchedA(count, 10) = data(10);
                    count = count + 1;
                end
            end
            
            %which of the notMatchedA list are eligible frameskippers?
            keep = [];
            frameSkipLimit = frameSkipLimit; %+1 because cells will be 2 names behind current frame number
            if isempty(notMatchedA) == 0 %0 is false, not empty, non-matched cells
                for x = 1: size(notMatchedA, 1)
                    if notMatchedA{x, 2} == (frame - frameSkipLimit)
                        keep = [keep, x];
                    end
                end
                %'old' frame skippers are removed and frameSkippers list
                %produced 
                frameSkippers = notMatchedA(keep, :);
                notMatchedA = [];
                %disp('frame skippers added');
            else
              %disp('No frame skips');
            end

            %discard not matched cells from reference table
            %cellA is the previous frame cell, cellB is the current frame
            [loc] = ismember([BCellsRef{:,1}], bestPairs(:,2));
            keep = [];
            for i = 1:length(loc)
                if loc(i) == 1
                    keep = [keep; i];
                end
            end
            matchedCellsRef = BCellsRef(keep,:);
            %renaming matched cells to original names, will allow construction
            %of cell history
            for i = 1:size(matchedCellsRef,1)
                for x = 1:size(bestPairs,1)
                    if matchedCellsRef{i,1} == bestPairs(x,2)
                        %disp('match');
                        matchedCellsRef{i,1} = bestPairs(x,1);
                    else 
                        %disp('no match');
                    end
                end
            end
        end
    end
    %disp('Finished comparision of masks');
end
