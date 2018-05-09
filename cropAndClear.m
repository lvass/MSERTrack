%cropping and clearing masks
parentFolder = '/media/lvass/My Passport/MSER_output_temp/';
folders = dir(parentFolder);
margin = 3;
for i = 1:length(folders)
    if length(folders(i).name) > 2
        subFolder = strcat(parentFolder, char(folders(i).name));
        locationFolders = dir(subFolder);
            for x = 1:length(locationFolders)
                if locationFolders(x).name(1) == 'L'
                    location = strcat(subFolder, '/', char(locationFolders(x).name));
                    files = dir(location);
                        for y = 1:length(files)
                            filename = files(y).name;
                            isMask = strfind(filename, 'Mask');
                            if isMask > 0
                                disp(strcat('Cropping' , ' ', filename));
                                image = imread(filename);
                                croppedImage = imcrop(image,...
                                    [margin, margin, 512 - 2 * margin, 512 - 2 * margin]);
                                clearedImage = imclearborder(croppedImage);
                                newImage = logical(padarray(clearedImage, [margin, margin]));
                                finalImage = imcrop(newImage,[1, 1, 513 - 2 * 1, 513 - 2 * 1]);
                                imwrite(finalImage, strcat(location, '/cropped_', filename));
                                disp('written to');
                                disp(strcat(location, '/cropped_', filename));
                            end
                        end
                end
            end
    end
end

