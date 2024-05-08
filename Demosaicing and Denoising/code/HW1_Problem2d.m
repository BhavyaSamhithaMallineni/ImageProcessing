
% EE569 Homework Assignment #1
% Date  : January 28, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 2c: Colour Image Denoising 
% Implementation: Non-Local Means Filter
% M-file: HW1_Problem2c
% Input Image File: Flower_noisy.raw, Flower.raw
% Output Image File: Flower_denoise.raw
% Open Source Code used: readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

og_filename = 'Flower.raw';
noisy_filename = 'Flower_noisy.raw';

width = 768;
height = 512;

og_img = readraw(og_filename, height, width, false);
noisy_img = readraw(noisy_filename, height, width, false);

figure
imshow(og_img/255)
title('Original Image')

figure
imshow(noisy_img/255)
title('Noisy Image')

% to find teh type of noise we can plot the histogram and check the
% distribution
histogram_og_img = GetHistogram(og_img, height, width);
figure;
for k = 1:3
    subplot(1, 3, k);
    bar(1:256, histogram_og_img(k, :));
    title(['Histogram of Channel ' num2str(k)]);
    xlabel('Intensity');
    ylabel('Pixel Frequency');
end
histogram_noisy_img = GetHistogram(noisy_img, height, width);


figure;
for k = 1:3
    subplot(1, 3, k);
    bar(1:256, histogram_noisy_img(k, :));
    title(['Noisy Histogram of Channel ' num2str(k)]);
    xlabel('Intensity');
    ylabel('Pixel Frequency');
end
% histograms show gaussian noise 
% going to use low pass median filter 
padded_image = GetPaddedImage(noisy_img,height,width , 7);
median_filtered_img_fcf = GetMedianFilteredImage(padded_image,height,width,7);

figure
imshow(median_filtered_img_fcf/255)
title('Median_filtered image 7x7')

filename = 'Flower_denoise.raw';
writeraw(median_filtered_img_fcf, filename, false);

histogram_noisy_img_mf = GetHistogram(median_filtered_img_fcf, height, width);


figure;
for k = 1:3
    subplot(1, 3, k);
    bar(1:256, histogram_noisy_img_mf(k, :));
    title(['MfHistogram of Channel ' num2str(k)]);
    xlabel('Intensity');
    ylabel('Pixel Frequency');
end

% we will try using bilateral filter 

bilateral_filtered_image = GetBilateralFilteredImage(padded_image, height, width, 10, 20, 7);
figure
imshow(bilateral_filtered_image/255)
title('After Bilateral Filter')


function pixel_freq = GetHistogram(image, height, width)

    pixel_freq = zeros(3, 256);
    
    for i = 1:height
        for j = 1:width
            for k = 1:3
                intensity = floor(image(i, j, k)) + 1;
                pixel_freq(k, intensity) = pixel_freq(k, intensity) + 1;
            end
        end
    end

end

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