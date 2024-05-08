% EE569 Homework Assignment #1
% Date  : January 28, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 2c: Image Denoising (Non-Local Means Filter)
% Implementation: Non-Local Means Filter
% M-file: HW1_Problem2d
% Input Image File: Flower_gray_noisy.raw, Flower_gray.raw
% Output Image File: Flower_nlmeans_denoise.raw
% Open Source Code used: readraw.m , writeraw.m , imnlmfilt()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

og_filename = 'Flower_gray.raw';
noisy_filename = 'Flower_gray_noisy.raw';

width = 768;
height = 512;

greyscale_og_img = readraw(og_filename, height, width, true);
greyscale_noisy_img = readraw(noisy_filename, height, width, true);

figure
imshow(greyscale_og_img/255)
title('Original Greyscale Image')

figure
imshow(greyscale_noisy_img/255)
title('Greyscale Noisy Image')

psnr_og_vs_noisy = CalculatePSNR(greyscale_og_img, greyscale_noisy_img, height, width);
disp(['PSNR between original and noisy images: ', num2str(psnr_og_vs_noisy)]);

search_window_size = 21;
degree_of_smoothing = 10;


nlm_denoised_img = GetNLMFilteredImage(greyscale_noisy_img, search_window_size, degree_of_smoothing);

figure
imshow(nlm_denoised_img/255)
title('Denoised Image using Non-Local Means Filter')

psnr_og_vs_denoised = CalculatePSNR(greyscale_og_img, nlm_denoised_img, height, width);
disp(['PSNR between original and denoised images: ', num2str(psnr_og_vs_denoised)]);


filename_nlmeans = 'Flower_nlmeans_denoise.raw';
writeraw(nlm_denoised_img, filename_nlmeans, true);

function denoised_image = GetNLMFilteredImage(noisy_image, search_window_size, degree_of_smoothing)
    denoised_image = imnlmfilt(noisy_image, 'SearchWindowSize', search_window_size, 'DegreeOfSmoothing', degree_of_smoothing);
end

function psnr = CalculatePSNR(img1, img2, height, width)
    max_val = 255;
    mse = sum((img2(:) - img1(:)).^2) / (height * width);
    psnr = 10 * log10(max_val^2 / mse);
end
