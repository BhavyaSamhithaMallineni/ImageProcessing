% EE569 Homework Assignment #1
% Date  : January 28, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 2a : Image Denoising (Bilateral Filter )
% Implementation : (Bilateral Filter )
% M-file: HW1_Problem2b
% Input Image File : Flower_gray_noisy.raw, Flower_gray.raw
% Output Image File : Flower_bilateral_denoise.raw
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Each filter f the Average and the Gaussian filter are added with a kernel
% size of 3x3 and 5x5 to compare the performance
og_filename = 'Flower_gray.raw';
noisy_filename = 'Flower_gray_noisy.raw';

width = 768;
height = 512;

% Read the greyscale img from the readraw file %
% This grey scale image is a double %
greyscale_og_img = readraw(og_filename, height, width, true);
greyscale_noisy_img = readraw(noisy_filename, height, width, true);

figure
imshow(greyscale_og_img/255)
title('Original Graycale Image')

figure
imshow(greyscale_noisy_img/255)
title('Grayscale Noisy Image')

psnr_og_vs_noisy = CalculatePSNR(greyscale_og_img, greyscale_noisy_img, height, width);

disp(['PSNR between original and noisy images: ', num2str(psnr_og_vs_noisy)]);

% Bilateral filtering 5x5 winsow size
sigma_s = 10; 
sigma_c = 5; 

padded_image = GetPaddedImage(greyscale_noisy_img,height,width , 5);
denoised_img = GetBilateralFilteredImage(padded_image, height, width, sigma_s, sigma_c, 5);

figure
imshow(denoised_img/255)
title('Bileteral Denoised Image')



psnr_og_vs_denoised = CalculatePSNR(greyscale_og_img, denoised_img, height, width);
disp(['PSNR between original and Bilateal denoised images: ', num2str(psnr_og_vs_denoised)]);


filename = 'Flower_bilateral_denoise.raw';
writeraw(denoised_img, filename, true);


function padded_image = GetPaddedImage(image,img_height,img_width , window_size)
 
        padding = floor(window_size/2);
        padded_img_height = img_height + 2*padding;
        padded_img_width = img_width + 2*padding;

        padded_image = zeros(padded_img_height,padded_img_width);
        padded_image(padding + 1:end -padding,padding + 1:end -padding) = image;

end

function bilateral_filtered_image = GetBilateralFilteredImage(padded_image, height, width, sigma_s, sigma_c, window_size)
    bilateral_filtered_image = zeros(height, width);
    num_padding = floor(window_size / 2);

    for i = num_padding+1 : height+num_padding
        for j = num_padding+1 : width+num_padding
            pixel_value = 0;
            weight_sum = 0;

            for m = max(1, i - num_padding) : min(height + 2 * num_padding, i + num_padding)
                for n = max(1, j - num_padding) : min(width + 2 * num_padding, j + num_padding)
                    spatial_diff = sqrt((i - m)^2 + (j - n)^2);
                    intensity_diff = abs(padded_image(i, j) - padded_image(m, n));
                    weight = exp(-spatial_diff^2 / (2 * sigma_s^2) - intensity_diff^2 / (2 * sigma_c^2));
                    pixel_value = pixel_value + weight * padded_image(m, n);
                    weight_sum = weight_sum + weight;
                end
            end

            bilateral_filtered_image(i - num_padding, j - num_padding) = pixel_value / weight_sum;
        end
    end
end


function psnr = CalculatePSNR(img1, img2, height, width)
    max_val = 255;
    mse = sum((img2(:) - img1(:)).^2) / (height * width);
    psnr = 10 * log10(max_val^2 / mse);
end
