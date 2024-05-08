
% EE569 Homework Assignment #1
% Date  : January 28, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 3 : Painting Effect 
% Implementation : Combinations of filters
% M-file: HW1_Problem3
% Input Image File : Flower_gray.raw
% Output Image File : Flower_painting.raw
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
og_filename = 'Flower.raw';
noisy_filename ='Flower_noisy.raw';

img_width = 768 ;
img_height = 512 ;


 % this grey scale image is a double %
og_img = readraw(og_filename, img_height, img_width, false);
noisy_img = readraw(noisy_filename,img_height,img_width, false);

figure
imshow(og_img/255)
title('Original Image')

% first we implement for a window of 5x5
padded_img_fcf = GetPaddedImage(og_img,img_height,img_width,5);

% Step 1: Median Filter 

median_filtered_img_fcf = GetMedianFilteredImage(padded_img_fcf,img_height,img_width,5);

figure
imshow(median_filtered_img_fcf/255)
title('Median_filtered image 5x5')
% 
% padded_img_scs = GetPaddedImage(og_img,img_height,img_width,7);
% 
% median_filtered_img_scs = GetMedianFilteredImage(padded_img_scs,img_height,img_width,7);
% 
% figure
% imshow(median_filtered_img_scs/255)
% title('Median_filtered image 7x7')

% bilateal filter
padded_median_image = GetPaddedImage(median_filtered_img_fcf,img_height,img_width,5);
bilateral_filtered_image = GetBilateralFilteredImage(padded_median_image, img_height, img_width, 10, 20, 5);

figure
imshow(bilateral_filtered_image/255)
title('step2 Bilateral filter')

padded_og_image_scs = GetPaddedImage(og_img,img_height,img_width,7);
gaussian_filtered_img= GetGaussianFilteredImage(padded_og_image_scs, img_height, img_width, 2, 7);

figure
imshow(gaussian_filtered_img/255)
title('step3 gaussian filter')

linear_comb_filtered_img = 1.4*bilateral_filtered_image - 0.4*gaussian_filtered_img;
figure
imshow(linear_comb_filtered_img /255)
title('Final')


filename = 'Flower_painting.raw';
writeraw(linear_comb_filtered_img, filename, false);



function padded_image = GetPaddedImage(image,img_height,img_width , window_size)
 
        padding = floor(window_size/2);
        padded_img_height = img_height + 2*padding;
        padded_img_width = img_width + 2*padding;

        padded_image = zeros(padded_img_height,padded_img_width,3);
        padded_image(padding + 1:end -padding,padding + 1:end -padding,:) = image;

end


function median_filtered_image = GetMedianFilteredImage(padded_img, height, width, window_size)
    median_filtered_image = zeros(height, width, 3);
    num_padding = floor(window_size/2);

    for c = 1:3
        for i = num_padding+1 : height+num_padding
            for j = num_padding+1 : width+num_padding
                conv_pixels = padded_img(i-num_padding:i+num_padding, j-num_padding:j+num_padding, c);
                pixel_values = conv_pixels(:);

                num_pixels = length(pixel_values);

                for g = 1:num_pixels-1
                    [~, min_index] = min(pixel_values(g:end));
                    min_index = min_index + g - 1;

                    temp = pixel_values(g);
                    pixel_values(g) = pixel_values(min_index);
                    pixel_values(min_index) = temp;
                end

                if rem(num_pixels, 2) == 1

                    median_pixel = pixel_values((num_pixels + 1) / 2);
                else

                    median_pixel = (pixel_values(num_pixels/2) + pixel_values(num_pixels/2 + 1)) / 2;
                end

                median_filtered_image(i - num_padding, j - num_padding, c) = median_pixel;
            end
        end
    end
end

function bilateral_filtered_image = GetBilateralFilteredImage(padded_image, height, width, sigma_s, sigma_c, window_size)
    bilateral_filtered_image = zeros(height, width, 3);
    num_padding = floor(window_size / 2);

    for c = 1:3
        for i = num_padding+1 : height+num_padding
            for j = num_padding+1 : width+num_padding
                pixel_value = 0;
                weight_sum = 0;

                for m = max(1, i - 1) : min(height, i + 1)
                    for n = max(1, j - 1) : min(width, j + 1)
                        spatial_diff = sqrt((i - m)^2 + (j - n)^2);
                        intensity_diff = abs(padded_image(i, j, c) - padded_image(m, n, c));
                        weight = exp(-spatial_diff^2 / (2 * sigma_s^2) - intensity_diff^2 / (2 * sigma_c^2));
                        pixel_value = pixel_value + weight * padded_image(m, n, c);
                        weight_sum = weight_sum + weight;
                    end
                end

                bilateral_filtered_image(i - num_padding, j - num_padding, c) = pixel_value / weight_sum;
            end
        end
    end
end
function gaussian_filter = GetGaussianFilter(window_size, sigma)
    num_padding = floor(window_size / 2);
    gaussian_filter = zeros(window_size, window_size);

    for i = 1 : window_size
        for j = 1 : window_size
            m = i - num_padding - 1;
            n = j - num_padding - 1;
            gaussian_filter(i, j) = exp(-(m^2 + n^2) / (2 * sigma^2));
        end
    end

   
    gaussian_filter = gaussian_filter / sum(gaussian_filter(:));
end

function gaussian_filtered_img = GetGaussianFilteredImage(padded_img, img_height, img_width, sigma, window_size)
    gaussian_filter = GetGaussianFilter(window_size, sigma);
    gaussian_filtered_img = zeros(img_height, img_width, 3);
    num_padding = floor(window_size / 2);

    for c = 1:3
        for i = 1 : img_height
            for j = 1 : img_width
                pixel_conv_value = 0;

                for m = 1 : window_size
                    for n = 1 : window_size
                        pixel_conv_value = pixel_conv_value + padded_img(i + m - 1, j + n - 1, c) * gaussian_filter(m, n);
                    end
                end

                gaussian_filtered_img(i, j, c) = pixel_conv_value;
            end
        end
    end
end


     