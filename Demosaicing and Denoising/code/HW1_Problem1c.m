%  EE569 Homework Assignment #1
% Date  : January 28, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 1c : Histogram Equilization ( Haze Removal)
% Implementation : Trasfer-function, bucket-filling, CLAHE
% M-file: HW1_Problem1c
% Input Image File : City.raw
% Output Image File : DimLight_tf_equilized.raw, DimLight_bf_equilized
% Open Source Code used : readraw.m and writeraw.m, adapthisteq
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the raw file
filename = 'City.raw';

width = 750 ;
height = 422 ;

rgb_img = readraw(filename, height, width, false);

figure
imshow(rgb_img/255)
title('RGB Image')

R = rgb_img(:, :, 1);
G = rgb_img(:, :, 2);
B = rgb_img(:, :, 3);

% converting rgb to yuv
Y = 0.257 * R + 0.504 * G + 0.098 * B + 16;
U = -0.148 * R - 0.291 * G + 0.439 * B + 128;
V = 0.439 * R - 0.368 * G - 0.071 * B + 128;

yuv_img = zeros(height, width, 3);
yuv_img(:,:,1) = Y;
yuv_img(:,:,2) = U;
yuv_img(:,:,3) = V;

figure
imshow(yuv_img/255)
title('YUV Image')

tf_equilized_yuv=GetTfEquilizedImage(yuv_img,height,width);

R = 1.164 * (tf_equilized_yuv(:,:,1) - 16) + 1.596 * (tf_equilized_yuv(:,:,3) - 128);
G = 1.164 * (tf_equilized_yuv(:,:,1) - 16) - 0.813 * (tf_equilized_yuv(:,:,3) - 128) - 0.391 * (tf_equilized_yuv(:,:,2) - 128);
B = 1.164 * (tf_equilized_yuv(:,:,1) - 16) + 2.018 * (tf_equilized_yuv(:,:,2) - 128);

% Clip values to the valid range [0, 255]
R = min(max(R, 0), 255);
G = min(max(G, 0), 255);
B = min(max(B, 0), 255);

% Concatenate R, G, and B channels to form the RGB image
rgb_tf_img = cat(3, R, G, B);

% Display the RGB image
figure
imshow(rgb_tf_img/255)
title('Transfer Function Haze Removal')


% bf_equilized_yuv=GetBfEquilizedImage(yuv_img,height,width);
% 
% R = 1.164 * (bf_equilized_yuv(:,:,1) - 16) + 1.596 * (bf_equilized_yuv(:,:,3) - 128);
% G = 1.164 * (bf_equilized_yuv(:,:,1) - 16) - 0.813 * (bf_equilized_yuv(:,:,3) - 128) - 0.391 * (bf_equilized_yuv(:,:,2) - 128);
% B = 1.164 * (bf_equilized_yuv(:,:,1) - 16) + 2.018 * (bf_equilized_yuv(:,:,2) - 128);
% 
% % Clip values to the valid range [0, 255]
% R = min(max(R, 0), 255);
% G = min(max(G, 0), 255);
% B = min(max(B, 0), 255);
% 
% % Concatenate R, G, and B channels to form the RGB image
% rgb_bf_img = cat(3, R, G, B);
% 
% % Display the RGB image
% figure
% imshow(rgb_bf_img/255)
% title('RGB Image from YUV using Bucket Filling ')
% 
% 
% 
% 



clahe_equilized_image= GetCLAHEquilizedImage(yuv_img, height, width);

R = 1.164 * (clahe_equilized_image(:,:,1) - 16) + 1.596 * (clahe_equilized_image(:,:,3) - 128);
G = 1.164 * (clahe_equilized_image(:,:,1) - 16) - 0.813 * (clahe_equilized_image(:,:,3) - 128) - 0.391 * (clahe_equilized_image(:,:,2) - 128);
B = 1.164 * (clahe_equilized_image(:,:,1) - 16) + 2.018 * (clahe_equilized_image(:,:,2) - 128);

% Clip values to the valid range [0, 255]
R = min(max(R, 0), 255);
G = min(max(G, 0), 255);
B = min(max(B, 0), 255);

% Concatenate R, G, and B channels to form the RGB image
rgb_clahe_img = cat(3, R, G, B);

% Display the RGB image
figure
imshow(rgb_clahe_img/255)
title('CLAHE Haze Removal')


% Writing the image into a raw file
filename = 'Haze_Removed_Tf.raw';
writeraw(rgb_tf_img, filename, false);
% Writing the image into a raw file
filename = 'Haze_Removed_Clahe.raw';
writeraw(rgb_clahe_img, filename, false);



function clahe_equilized_image = GetCLAHEquilizedImage(yuv_img, height, width)
    clahe_equilized_image = zeros(height, width, 3);
    c1 = yuv_img(:,:,1);
    c1_clahe = adapthisteq(c1/255, 'ClipLimit', 0.02,'Distribution','rayleigh');
    clahe_equilized_image(:,:,1) = uint8(c1_clahe * 255);
    clahe_equilized_image(:,:,2) = yuv_img(:,:,2);
    clahe_equilized_image(:,:,3) = yuv_img(:,:,3);
end

function tf_equalized_img = GetTfEquilizedImage(yuv_img,height,width)

    pixel_freq = zeros(1, 256);

    for i = 1:height
        for j = 1:width
            intensity = floor(yuv_img(i, j, 1) + 1);
            pixel_freq(intensity) = pixel_freq(intensity) + 1;
        end
    end

    total_pixel_count = sum(pixel_freq);

    probability = pixel_freq / total_pixel_count;

    cumulative_freq = cumsum(probability);

    cumulative_dist = cumulative_freq * 255;

    tf_equalized_img = zeros(height, width, 3);

    for i = 1:height
        for j = 1:width
            intensity = floor(yuv_img(i, j, 1) + 1);
            tf_equalized_img(i, j, 1) = floor(cumulative_dist(intensity));
            tf_equalized_img(i, j, 2) = yuv_img(i, j, 2);
            tf_equalized_img(i, j, 3) = yuv_img(i, j, 3);
        end
    end
end

function bf_equilized_image = GetBfEquilizedImage(yuv_img, height, width)
    bf_equilized_image = zeros(height, width, 3);
    total_pixel_count = height * width;

    % Extract the first channel for processing
    channel1 = yuv_img(:,:,1);

     pixel_freq = zeros(1, 256);

    for i = 1:height
        for j = 1:width
            intensity = floor(yuv_img(i, j, 1) + 1);
            pixel_freq(intensity) = pixel_freq(intensity) + 1;
        end
    end

    cdf = cumsum(pixel_freq)/ total_pixel_count;

    for i = 1:height
        for j = 1:width
            intensity = floor(channel1(i, j)) + 1;
            bf_equilized_image(i, j, 1) = floor(cdf(intensity) * 255);
            bf_equilized_image(i, j, 2) = image(i, j, 2);
            bf_equilized_image(i, j, 3) = image(i, j, 3);
        end
    end

end

