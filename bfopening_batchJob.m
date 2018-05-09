experimentName = MCF7hoechstmIFNG;
location = 'L2';
name = 'MCF7 p65EGFP TNFa IL1b costim nostim_2017_11_03__13_46_11_L5.lsm';

listiter = 1;
for i = 1:1
    filename = char(strcat(name, ext));
    image = bfopen(filename);
    channel1 = im2double(image{1, 1}{1,1});
    channel2 = im2double(image{1, 1}{2,1});
    channel3 = im2double(image{1, 1}{3,1});
    
    nucChannel = 3;
    cytoChannel = 2;
    numChannels = 3;
    numOfImages = (length(image{1,1}));
    
    filenameList = strings((numOfImages/numChannels), 1);
 
    for x = nucChannel:numChannels:numOfImages
        if listiter < 10
            outfileName = char(strcat('nuc_', experimentName, location, string(imagelist(i)), '_Frame00', string(listiter), '.bmp'));
        end
        if listiter < 100
            outfileName = char(strcat('nuc_', experimentName, location, string(imagelist(i)), '_Frame0', string(listiter), '.bmp'));
        end
        if listiter >= 100 
                        outfileName = char(strcat('nuc_', experimentName, location, string(imagelist(i)), '_Frame', string(listiter), '.bmp'));
        end
        iterImage = im2double(image{1, 1}{x,1});
        imwrite(iterImage, outfileName);
        filenameList(listiter) = string(outfileName);
        listiter = listiter +1;
    end
    
    for x = cytoChannel:numChannels:numOfImages
        if listiter < 10
            outfileName = char(strcat('cyto_', experimentName, location, string(imagelist(i)), '_Frame00', string(listiter), '.bmp'));
        end
        if listiter < 100
            outfileName = char(strcat('cyto_', experimentName, location, string(imagelist(i)), '_Frame0', string(listiter), '.bmp'));
        end
        if listiter >= 100 
                        outfileName = char(strcat('cyto_', experimentName, location, string(imagelist(i)), '_Frame', string(listiter), '.bmp'));
        end
        iterImage = im2double(image{1, 1}{x,1});
        imwrite(iterImage, outfileName);
        filenameList(listiter) = string(outfileName);
        listiter = listiter +1;
    end
end

disp('finished');