% EE569 Homework Assignment #1
% Date  : January 28, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 2a : Image Denoising 
% Implementation : Linear Filtering and Gaussian Filtering 
% M-file: HW1_Problem2a
% Input Image File : Flower_gray_noisy.raw, Flower_gray.raw
% Output Image File : Flower_avg_denoise.raw, Flower_gaussian_denoise.raw
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For Each filter the Average and the Gaussian filter are added with a kernel
% size of 3x3 and 5x5 to compare the performance
og_filename = 'Flower_gray.raw';
noisy_filename = 'Flower_gray_noisy.raw';

width = 768;
height = 512;

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

% Zero-padding for convolution
padded_noisy_img = zeros(height + 2, width + 2);
padded_noisy_img(2:end-1, 2:end-1) = greyscale_noisy_img;

% Average Filter

% 3x3 filter
avg_filtered_img = zeros(height, width);
average_filter = ones(3) / 9;

for i = 1:height
    for j = 1:width
        conv_pixels = padded_noisy_img(i:i+2, j:j+2);
        pixel_conv_value = sum(sum(conv_pixels .* average_filter));
        avg_filtered_img(i, j) = pixel_conv_value;
    end
end

figure
imshow(avg_filtered_img/255)
title('3x3 Average Linear Filter Denoised Image')

psnr_og_vs_avgfilter = CalculatePSNR(greyscale_og_img, avg_filtered_img, height, width);

disp(['PSNR between original and average 3x3 filtered images: ', num2str(psnr_og_vs_avgfilter)]);

psnr_noisy_vs_avg3filter = CalculatePSNR(greyscale_noisy_img, avg_filtered_img, height, width);

disp(['PSNR between noisy and average 3x3 filtered images: ', num2str(psnr_noisy_vs_avg3filter)]);

% repeating the same for a 5X5 filter 
padded_noisy_img_5x5 = zeros(height + 4, width + 4);
padded_noisy_img_5x5(3:end-2, 3:end-2) = greyscale_noisy_img;

avg_filtered_img_5x5 = zeros(height, width);
average_filter = ones(5) / 25;

for i = 1:height
    for j = 1:width
        conv_pixels = padded_noisy_img_5x5(i:i+4, j:j+4);
        pixel_conv_value = sum(sum(conv_pixels .* average_filter));
        avg_filtered_img_5x5(i, j) = pixel_conv_value;
    end
end

figure
imshow(avg_filtered_img_5x5/255)
title('5x5 Average Linear Filter Denoised Image')

psnr_og_vs_avg5filter = CalculatePSNR(greyscale_og_img, avg_filtered_img_5x5, height, width);

disp(['PSNR between original and average 5x5 filtered images: ', num2str(psnr_og_vs_avg5filter)]);

psnr_noisy_vs_avg5filter = CalculatePSNR(greyscale_noisy_img, avg_filtered_img_5x5, height, width);

disp(['PSNR between noisy and average 5x5 filtered images: ', num2str(psnr_noisy_vs_avg5filter)]);

filename = 'Flower_avg_denoise.raw';
writeraw(avg_filtered_img_5x5, filename, true);


% Gaussian Filter Method 3x3
gaussian_filtered_img_tct = GetGaussianFilteredImage(padded_noisy_img, height, width, 1, 3);

figure
imshow(gaussian_filtered_img_tct/255)
title('Linear Gaussian Denoised Image')

psnr_og_vs_gaussianfilter = CalculatePSNR(greyscale_og_img, gaussian_filtered_img_tct, height, width);

disp(['PSNR between original and 3x3 gaussian filtered images: ', num2str(psnr_og_vs_gaussianfilter)]);

psnr_noisy_vs_gaussianfilter = CalculatePSNR(greyscale_noisy_img, gaussian_filtered_img_tct, height, width);

disp(['PSNR between noisy and 3x3 gaussian filtered images: ', num2str(psnr_noisy_vs_gaussianfilter)]);



% Gaussian Filter Method 5x5


gaussian_filtered_img_fcf = GetGaussianFilteredImage(padded_noisy_img_5x5, height, width, 2, 5);

figure
imshow(gaussian_filtered_img_fcf/255)
title('Linear Gaussian Denoised Image')

psnr_og_vs_gaussianfilter = CalculatePSNR(greyscale_og_img, gaussian_filtered_img_fcf, height, width);

disp(['PSNR between original and 5x5 gaussian filtered images: ', num2str(psnr_og_vs_gaussianfilter)]);

psnr_noisy_vs_gaussianfilter = CalculatePSNR(greyscale_noisy_img, gaussian_filtered_img_fcf, height, width);

disp(['PSNR between noisy and 5x5 gaussian filtered images: ', num2str(psnr_noisy_vs_gaussianfilter)]);

filename = 'Flower_gaussian_denoise.raw';
writeraw(gaussian_filtered_img_fcf, filename, true);


function psnr = CalculatePSNR(img1, img2,height, width)
     
      max = 255;
      mse= 0;

      for i = 1:height
        for j = 1:width
            error = img2(i,j)- img1(i,j);
            squared_error = error*error;
            mse= mse + squared_error;
        end
      end
 
      mse = mse/(height*width);
      psnr = 10*log10(max*max/mse);
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
    gaussian_filtered_img = zeros(img_height, img_width);

        for i = 1 : img_height
            for j = 1 : img_width
                pixel_conv_value = 0;

                for m = 1 : window_size
                    for n = 1 : window_size
                        pixel_conv_value = pixel_conv_value + padded_img(i + m - 1, j + n - 1) * gaussian_filter(m, n);
                    end
                end

                gaussian_filtered_img(i, j) = pixel_conv_value;
            end
        end
 end
