%  EE569 Homework Assignment #1
% Date  : January 28, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 1a : Image Demosaicing 
% Implementation : Bilinear Demosaicing
% M-file: HW1_Problem1a
% Input Image File : House.raw
% Output Image File : House_rgb.raw
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Read raw image file
filename = 'House.raw';
%declare the dimensions of the image 
width = 420 ;
height = 288 ;
bayer_img = readraw(filename, height, width, true);

 figure
 imshow(bayer_img/255)
 title('Original Bayer Image')
 
 % zero padding the image so that no data is lost during interpolation.
padded_bayer_img= zeros(height + 2 , width + 2 );
padded_bayer_img(2 : end - 1, 2 : end - 1) = bayer_img;


rgb_img = zeros(height, width, 3);

%we are using bayer layer pattern coping the pixel levels to the RBG layers respectively 
%later the missing value intensities are fillied using bi-linear interpolation

% Red Channel 
for row = 2:height-1
    for col = 3:width-1
        if mod(row, 2) == 0 && mod(col, 2) == 1
            rgb_img(row, col, 1) = padded_bayer_img(row, col);
        elseif mod(row, 2) == 1 && mod(col, 2) == 0
            rgb_img(row, col, 1) = 0.25 * (padded_bayer_img(row - 1, col - 1) + padded_bayer_img(row + 1, col - 1) + ...
                padded_bayer_img(row + 1, col + 1) + padded_bayer_img(row - 1, col + 1));
         elseif mod(row, 2) == 1 && mod(col, 2) == 1
             rgb_img(row, col, 1) = 0.5 * (padded_bayer_img(row - 1, col) + padded_bayer_img(row + 1, col)); 
        elseif mod(row, 2) == 0 && mod(col, 2) == 0
            rgb_img(row, col, 1) = 0.5 * (padded_bayer_img(row , col-1) + padded_bayer_img(row , col+1));
        end
    end
end

% Green Channel
for row = 2:height-1
    for col = 2:width-1
        if mod(row, 2) == 0 && mod(col, 2) == 0
            rgb_img(row, col, 2) = padded_bayer_img(row, col);
        elseif mod(row, 2) == 1 && mod(col, 2) == 1
            rgb_img(row, col, 2) = padded_bayer_img(row, col);
         elseif mod(row, 2) == 1 && mod(col, 2) == 0
             rgb_img(row, col, 2) = 0.25 * (padded_bayer_img(row - 1, col) + padded_bayer_img(row, col - 1) + ...
               padded_bayer_img(row + 1, col) + padded_bayer_img(row, col + 1));
         
        end
    end
end

% Blue Channel
for row = 3:height-1
    for col = 2:width-1
        if mod(row, 2) == 1 && mod(col, 2) == 0
            rgb_img(row, col, 3) = padded_bayer_img(row, col);
        elseif mod(row, 2) == 0 && mod(col, 2) == 1
            rgb_img(row, col, 3) = 0.25 * (padded_bayer_img(row - 1, col - 1) + padded_bayer_img(row + 1, col - 1) + ...
                padded_bayer_img(row + 1, col + 1) + padded_bayer_img(row - 1, col + 1));
        elseif mod(row, 2) == 1 && mod(col, 2) == 1
            rgb_img(row, col, 3) = 0.5 * (padded_bayer_img(row, col - 1) + padded_bayer_img(row, col + 1));
         elseif mod(row, 2) == 0 && mod(col, 2) == 0
             rgb_img(row, col, 1) = 0.5 * (padded_bayer_img(row -1 , col) + padded_bayer_img(row +1 , col));
        end
        
    end
end

figure
imshow(rgb_img / 255);
title('RGB Image After Bilinear Democaising');

% Writing the image into a raw file
filename = 'House_rgb.raw';
writeraw(rgb_img, filename, false);






