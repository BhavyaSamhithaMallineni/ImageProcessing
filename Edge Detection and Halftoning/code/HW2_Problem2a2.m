%  EE569 Homework Assignment #2
% Date  : February 19, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 2a : Digital Halftoning Dithering 
% Implementation : Random Thresholding 
% M-file: HW2_Problem2a2
% Input Image File : LightHouse.raw
% Output Image File : Rand_LightHouse.raw
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


filename = 'LightHouse.raw';

width = 750 ;
height = 500 ;

light_img = readraw(filename, height, width, true);
 
  for i = 1: height
      for j = 1: width
          threshold = rand();
            if light_img(i,j) > threshold*255
                light_img(i,j) = 255;
            else
                light_img(i,j) = 0;
            end
      end
  end
 
 figure
imshow(light_img/255)
title('Random threshold Light House Image')

filename = 'Rand_LightHouse.raw';
writeraw(light_img, filename, true);