tic
se = strel('disk',4); %creating structuring element outside loop
folders = dir('/media/lvass/My Passport/MSER_output_temp'); %MSER masks
pathToParentFolder = ((folders(1).folder)); %getting path to folders

for i = 3:length(folders) %first 2 folders are always fullstops
    subFolder = folders(i).name;
    folderFullName = strcat(pathToParentFolder, '/', subFolder);
    locationsInFolder = dir(folderFullName); %getting iamge location folders
        for y = 1:length(locationsInFolder)
            locFolderName = locationsInFolder(y).name;
            locFolderFullName = strcat(folderFullName, '/', locFolderName);
            if contains(locFolderName,'L') == 1 %checking it is a location folder
                disp('true')
                filesInFolder = dir(locFolderFullName);
                for x = 1:length(filesInFolder)-1 %first 2 files are fullstops?
                    file = filesInFolder(x).name;
                    if length(file) > 4
                        %checking its a border cleared image
                        ext = file(end-3:end);
                        start = file(1:7);
                        if strcmp(ext, '.bmp') && strcmp(start, 'cropped') ==1
                            disp('yes');
                            originalBW = imread(file);
                            erodedBW = imerode(originalBW,se);
                            dilatedBW = logical(imdilate(erodedBW, se));
                            newFileName = strcat(locFolderFullName, '/smooth_', file);
                            imwrite(dilatedBW, newFileName);
                            disp(newFileName);
                        end
                    end
                end
            end
        end
end
toc

