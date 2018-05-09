function [splitMask] = watershedSplit(maskImage)

    %maskImage = imread('mserMask.bmp'); %testing only

    % computes the Euclidean distance transform of the binary image BW
    distTrans = -bwdist(~maskImage);
    %imshow(D, []); %display just the local minima

    %extending minima to prevent oversegmentation in watershed transform
    extMinima = imextendedmin(distTrans,1.0); %smaller h-maxima transform = more minima identified
    %imshowpair(bw,extMinima,'blend') %display new minima on original mask

    % distance transform so it only has minima at the desired locations using imimposemin
    D2 = imimposemin(distTrans,extMinima); %morphological reconstructs the image so it only has regional minima where the mask is nonzero
    watershedImage = watershed(D2); % repeat watershed transform
    %imshow(label2rgb(watershedImage)) %display watershed
    
    %The watershed ridge lines correspond to watershedImage == 0
    %use these ridge lines to segment the binary image by changing the corresponding pixels into background
    splitMask = maskImage;
    splitMask(watershedImage == 0) = 0;
    %imshow(splitMask) %display split mask
end