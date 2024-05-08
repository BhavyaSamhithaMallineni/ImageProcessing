%  EE569 Homework Assignment #4
% Date  : March 29, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 2 : Texture Segmentation 
% Implementation : Basic Texture Segmentation
% M-file: HW4_Problem2a
% Input Image File : composite.png
% Open Source Code used :kmeans.m and pca.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc


%%% read the mosaic image  %%%


height = 512;
width = 512;
filename= "composite.png";
mosaic_image= double(imread(filename));

figure;
imshow(mosaic_image/255);
title('Mosaic Image')


%%%%%%%%%%%%%% 5x5 law filters %%%%%%%%%%%%%%

L5 = [1 4 6 4 1];
E5 = [-1 -2 0 2 1];
S5 = [-1 0 2 0 -1];
W5 = [-1 2 0 -2 1];
R5 = [1 -4 6 -4 1];

kernel_1D = {L5, E5, S5, W5, R5};
kernel_5x5 = zeros(5, 5, 25);

filter_num = 1;
for i = 1:length(kernel_1D)
    for j = 1:length(kernel_1D)
        kernel_2D = kernel_1D{i}' * kernel_1D{j};
        kernel_5x5(:,:,filter_num) = kernel_2D;
        filter_num = filter_num + 1;
    end
end


% compute enegry for this image 

image_energy = get_WindowEnergy( mosaic_image,kernel_5x5,85,height,width);

% Normalize using the mean and standard deviation
for i = 1:height
    for j = 1:width
        mean_val = mean(image_energy(i,j,:));
        std_val = std(image_energy(i,j,:));
        for k = 1:24
            image_energy(i,j,k) = (image_energy(i,j,k)-mean_val)/std_val;
        end
    end
end


image_feature_map = reshape(image_energy,[height*width 24]);


%Kmeans

texture_pred = kmeans(image_feature_map,5,'Distance', 'sqeuclidean', 'MaxIter', 1000000,'OnlinePhase','on');
shades= [0,63,127,191,255];

texture_pred_reshape = reshape(texture_pred,[512 512]);

texture_predicted_img = zeros(height,width);
for i = 1:height
    for j = 1:width
        texture_predicted_img(i,j) = shades(texture_pred_reshape(i,j));
    end
end

figure;
imshow(texture_predicted_img/255)






%%
function final_pixel_energy = get_WindowEnergy(image, kernel5x5, window_size, height, width)
    
    feature = {};
    pixel_energy = zeros(height, width, 25);
    final_pixel_energy = zeros(height, width, 24);

    norm_mean = 0;
    for i = 1:height
        for j = 1:width
            norm_mean = norm_mean + image(i,j);
        end
    end
    norm_mean = (norm_mean / (height*width));

     for i = 1:height
         for j = 1:width
             image(i,j) = (image(i,j)-norm_mean)/255.0;
         end
     end
    padded_image = zeros(516, 516);
    %padded_image(3:514, 3:514) = image;
    padded_image = padarray(image, [2, 2], 'symmetric');

    % Loop through all of the law filters and convolve them with the image
    for filter_index = 1:size(kernel5x5,3)
        out_filter = zeros(height, width);
        for row = 1:height
            for col = 1:width
                out_filter(row,col) = get_ConvolutedImage(padded_image, kernel5x5(:,:,filter_index), row, col);
            end
        end
        feature = [feature, out_filter];
    end

    for i = 1:25
        feature_matrix = cell2mat(feature(i));
        padding_size = (window_size-1)/2;
        padded_mat = padarray(feature_matrix,[padding_size padding_size],'symmetric');

        for row = 1:height
            for col = 1:width
                energy = get_ConvolutedEnergy(padded_mat, row, col, window_size);
                pixel_energy(row,col, i) = energy;
            end
        end
    end

     for i = 1:size(pixel_energy,1)
         for j = 1:size(pixel_energy,2)
             for k = 2:size(pixel_energy,3)
                 final_pixel_energy(i,j,k-1) = (pixel_energy(i,j,k)-pixel_energy(i,j,1));
             end
         end
     end
end
function convolved_image = get_ConvolutedImage(image, kernel, height, width)
    convolved_image = 0;
    for i = 0:4
        for j = 0:4
            convolved_image = convolved_image + (image(height+i, width+j) * kernel(i+1, j+1));
        end
    end
end
function convolved_image = get_ConvolutedEnergy(image, height, width, window)
    
    convolved_image = 0;
    for i = 0:window-1
        for j = 0:window-1
            convolved_image = convolved_image + (image(height+i, width+j)*image(height+i, width+j));
        end
    end
end
 

