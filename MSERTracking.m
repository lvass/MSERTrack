function [finalMask] = MSERTracking(image, minCellArea, maxCellArea, TD, MAV, ER)
%Uses the MSER method to find cells in the frame    

    %image = imread('MCF7hoechstIL1b_L5_Frame225.bmp'); %for testing
    %disp('MSER method start');
    dimension = length(size(image)); %check if RGB
    err = 0.1;
    av = (minCellArea+maxCellArea)/2; %average cell area
    DR = (minCellArea-(av*err)); %debris
    MC = (maxCellArea+(av*err)); %max cell area
    RAR = round([DR, MC]);
    
    if dimension == 3
        image = rgb2gray(image); %convert to grayscale
    end
    image = im2double(image); %change from unit8 to double

    %--------detecting MSER features---------------------------------------
    [~,mserCC] = detectMSERFeatures(image,...
                        'ThresholdDelta', TD,...
                        'RegionAreaRange', RAR,...
                        'MaxAreaVariation', MAV);
    %--------parameters----------------------------------------------------
    %{
    %ThresholdData, can be 0 - 100, typically range from 0.8-4, default 2
    %RegionAreaRange, size of region in pixels. [minArea maxArea] inclusive
    %MaxAreaVariation - variation between extremal regions
    %Increasing this value returns a greater number of regions,
    %but they may be less stable. Typical values range from 0.1 to 1.0
    %default is 0.25.
    %}
    %--------display MSER regions------------------------------------------
    %{
    figure
    imshow(image)
    hold on
    plot(regions,'showPixelList',true,'showEllipses',false);
    hold off
    %}

    %--------finding region properties-------------------------------------
    cellStats = regionprops(mserCC,'Eccentricity', 'PixelIdxList', 'Area');

    %--------getting rid of non-ellipscal regions--------------------------
    belowCircThres = zeros(length(cellStats),1); %preallocation
    counter = 1;
    for i = 1:length(cellStats)
        n = cellStats(i).Eccentricity;
        if n < ER %eccentrictiy threshold between 0 - 1, 0 = cirlce
            belowCircThres(counter) = i;
            counter = counter + 1;
        end
    end

    %trimming the list below threshold to prevent 0 indexing error
    visited = 0;
    for id = 1:length(belowCircThres)
        if belowCircThres(id) == 0
            belowCircThresTrim = belowCircThres(1:(id-1));
            visited = visited + 1;
            break
        end
    end
    if visited == 0
        belowCircThresTrim = belowCircThres;
    end
    
    circularRegions = cellStats(belowCircThresTrim,:);

    %user message
    diff = length(cellStats) - (length(circularRegions));
    removedNonElipscal = diff;

    %--------creating mask image----------------------------------------------
    maskBlank = zeros(size(image)); % initialize mask
    for i = 1:length(circularRegions)
        thesePixels = circularRegions(i).PixelIdxList;
        maskBlank(thesePixels) = 1;
    end
    maskImage = cat(1, maskBlank);
    maskImageFilled = imfill(maskImage, 'holes'); %fill holes
    %imshow(maskImageFilled); %display mask

    %--------implement watershed splitting method--------------------------
    [splitMask] = watershedSplit(maskImageFilled);
    %imshow(splitMask);

    %--------getting rid of debris ----------------------------------------

    splitMaskLogical = logical(splitMask); %changing to labelled regions 
    splitCellStats = regionprops(splitMaskLogical, 'Centroid','Area',...
        'PixelIdxList','Eccentricity');

    belowThresDebris = zeros(length(splitCellStats),1); %preallocation
    counter = 1;
    for i = 1:length(splitCellStats)
        n = splitCellStats(i).Area;
        if n > DR && n < MC %within cell size range
            belowThresDebris(counter) = i;
            counter = counter + 1;
        end
    end

    %trimming the list below threshold to prevent 0 indexing error
    visited = 0;
    for id = 1:length(belowThresDebris)
        if belowThresDebris(id) == 0
            belowThresDebrisTrim = belowThresDebris(1:(id-1));
            visited = visited + 1;
            break
        end
    end
    if visited == 0
        belowThresDebrisTrim = belowThresDebris;
    end     
    foundCells = splitCellStats(belowThresDebrisTrim,:);

    %user message
    diff = length(splitCellStats) - (length(foundCells));
    removedDebris = diff;
    
    %--------creating mask image-------------------------------------------
    maskBlank = zeros(size(image)); % initialize mask
    for i = 1:length(foundCells)
        thesePixels = foundCells(i).PixelIdxList;
        maskBlank(thesePixels) = 1;
    end
    originalMask = cat(1, maskBlank);
    %imshow(noncroppedMask); %display mask

    %--------creating image mask before-after overlay----------------------

    redChannel = image; % Initialize.
    blueChannel = image; % Initialize.
    greenChannel = image; % Initialize.
    for i = 1 : length(splitCellStats)
        finalPixels = splitCellStats(i).PixelIdxList;
        blueChannel(finalPixels) = 255; % original regions
        redChannel(finalPixels) = 0; %after filtering
        greenChannel(finalPixels) = 0; %original image
    end

    for i = 1 : length(cellStats)
        originalPixels = cellStats(i).PixelIdxList;
        redChannel(originalPixels) = 255; %after filtering 
        greenChannel(originalPixels) = 0; %original image
    end
    displayRegionsFound = cat(3, redChannel, greenChannel, blueChannel);
    
    %-------display the found regions ------------------------------------
    %{
    figure
    imshow(displayRegionsFound);
    title('Pink = cells found, Red= regions removed, Blue = holes filled');
    %}
    
    
    %-------clearing border cells-----------------------------------------
    %{
    margin = 4;
    croppedImage = imcrop(originalMask,...
                  [margin, margin, 512 - 2 * margin, 512 - 2 * margin]);
    clearedImage = imclearborder(croppedImage);
    newImage = logical(padarray(clearedImage, [margin, margin]));
    cropped = imcrop(newImage,[1, 1, 513 - 2 * 1, 513 - 2 * 1]);
    %figure
    %imshow(finalMask);
    %}
     %-------smoothing edges --------------------------------------------
    se = strel('disk',4); %creating structuring element outside loop
    erodedBW = imerode(originalMask,se);
    finalMask = logical(imdilate(erodedBW, se));
    %disp('MSER method finished');
end
