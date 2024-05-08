%  EE569 Homework Assignment #2
% Date  : February 19, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 1b : Edge Detection
% Implementation : Sobel Edge Detection 
% M-file: HW2_Problem1a
% Input Image File : Tiger.raw, Pig.raw
% Output Image File : Tiger_SobelEdgeDetected.raw, Pig_SobelEdgeDetected.raw
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% Tiger %%%%%
tiger_filename = 'Tiger.raw';

width = 481 ;
height = 321 ;

tiger_rgb_img = readraw(tiger_filename, height, width, false);
 
figure
imshow(tiger_rgb_img/255)
title('Original Tiger Image')

% conversion to grayscale from colour
tiger_grayscale_img =  get_grayscale(tiger_rgb_img);

figure
imshow(tiger_grayscale_img/255)
title('Grayscale Tiger Image')

% mirror padding before convolution
padded_tiger_img = get_padded_image(tiger_grayscale_img,height, width);


%Sobel Edge Detection:-
x_gradient = [ -1 0 1;
      -2,0,2;
      -1,0,1];
  
y_gradient = [ -1 -2 -1;
      0,0,0;
      1,2,1];

% finding x_gradient using sobel filter and normalizing it
x_gradient_tiger=zeros(height,width);
x_gradient_tiger=get_convoluted_image(padded_tiger_img,x_gradient,height, width);
max_dx_tiger = max(x_gradient_tiger(:));
min_dx_tiger = min(x_gradient_tiger(:));
norm_dx_tiger = ((x_gradient_tiger - min_dx_tiger) / (max_dx_tiger - min_dx_tiger)) * 255;
% finding y_gradient using sobel filter and normalizing it
y_gradient_tiger=zeros(height,width);
y_gradient_tiger=get_convoluted_image(padded_tiger_img,y_gradient,height, width);
max_dy_tiger = max(y_gradient_tiger(:));
min_dy_tiger = min(y_gradient_tiger(:));
norm_dy_tiger = ((y_gradient_tiger - min_dy_tiger) / (max_dy_tiger - min_dy_tiger)) * 255;
figure
imshow(norm_dx_tiger/255)
title('Normalized X-Gradient Tiger Image') 
figure
imshow(norm_dy_tiger/255)
title('Normalized Y-Gradient Tiger Image')
 
% computing the magnitude image and normalizing it
 tiger_magnitude = zeros(height, width);
 maginitude=0;

 for i = 1:height
     for j = 1: width
         magnitude= sqrt((x_gradient_tiger(i,j).^2 )+ (y_gradient_tiger(i,j).^2 ));
         tiger_magnitude(i,j)=magnitude;

     end
 end
max_mag_tiger = max(tiger_magnitude(:));
min_mag_tiger = min(tiger_magnitude(:));
norm_mag_tiger = ((tiger_magnitude - min_mag_tiger) / (max_mag_tiger - min_mag_tiger)) * 255;
figure;
imshow(norm_mag_tiger/255)
title('Normalized Tiger Magnitude Image')

% we find the cdf of the image and find the 90% for the threshold
histogram_tiger = zeros(1, 256); 

for i = 1:height
    for j = 1:width
         pixel_intensity= floor(norm_mag_tiger(i, j)) + 1;
         histogram_tiger(pixel_intensity) = histogram_tiger(pixel_intensity) + 1;
    end
end

figure;
bar(0:255, histogram_tiger, 'BarWidth', 1);
title('Histogram of Tiger');
xlabel('Pixel Intensity');
ylabel('Frequency');

cdf_tiger = zeros(size(histogram_tiger));
cumulative_sum = 0;
for i = 1:length(histogram_tiger)
    cumulative_sum = cumulative_sum + histogram_tiger(i);
    cdf_tiger(i) = cumulative_sum;
end
total_pixels = sum(histogram_tiger);
threshold_90_Tiger = find(cdf_tiger >= 0.9 * total_pixels, 1) - 1;
fprintf('Tiger image with 90%% threshold value: %d\n', threshold_90_Tiger);

threshold_tiger_img = zeros(height, width);

for i = 1:height
    for j = 1:width
        if norm_mag_tiger(i,j) < threshold_90_Tiger
            threshold_tiger_img(i, j) = 255; 
        else
            threshold_tiger_img(i, j) = 0; 
        end
    end
end

figure
imshow(threshold_tiger_img/255)
title('Threshold Tiger Image')

% Writing the image into a raw file
filename = 'Tiger_SobelEdgeDetected.raw';
writeraw(threshold_tiger_img, filename, true);

imwrite(norm_mag_tiger, 'Sobel_detected_tiger.png');
%%%%%% Pig %%%%%
pig_filename = 'pig.raw';


pig_rgb_img = readraw(pig_filename, height, width, false);

figure
imshow(pig_rgb_img/255)
title('Original pig Image')

% conversion to grayscale from colour
pig_grayscale_img =  get_grayscale(pig_rgb_img);

figure
imshow(pig_grayscale_img/255)
title('Grayscale pig Image')

% mirror padding before convolution
padded_pig_img = get_padded_image(pig_grayscale_img,height, width);

% finding x_gradient using sobel filter and normalizing it
x_gradient_pig=zeros(height,width);
x_gradient_pig=get_convoluted_image(padded_pig_img,x_gradient,height, width);
max_dx_pig = max(x_gradient_pig(:));
min_dx_pig = min(x_gradient_pig(:));
norm_dx_pig = ((x_gradient_pig - min_dx_pig) / (max_dx_pig - min_dx_pig)) * 255;

% finding y_gradient using sobel filter and normalizing it
y_gradient_pig=zeros(height,width);
y_gradient_pig=get_convoluted_image(padded_pig_img,y_gradient,height, width);
max_dy_pig = max(y_gradient_pig(:));
min_dy_pig = min(y_gradient_pig(:));
norm_dy_pig = ((y_gradient_pig - min_dy_pig) / (max_dy_pig - min_dy_pig)) * 255;
figure
imshow(norm_dx_pig/255)
title('Normalized X-Gradient pig Image') 
figure
imshow(norm_dy_pig/255)
title('Normalized Y-Gradient pig Image')

% computing the magnitude image and normalizing it
 pig_magnitude = zeros(height, width);
 maginitude=0;

 for i = 1:height
     for j = 1: width
         magnitude= sqrt((x_gradient_pig(i,j).^2 )+ (y_gradient_pig(i,j).^2 ));
         pig_magnitude(i,j)=magnitude;

     end
 end
max_mag_pig = max(pig_magnitude(:));
min_mag_pig = min(pig_magnitude(:));
norm_mag_pig = ((pig_magnitude - min_mag_pig) / (max_mag_pig - min_mag_pig)) * 255;
figure;
imshow(norm_mag_pig/255)
title('Magnitude pig')

% we find the cdf of the image and find the 90% for the threshold

histogram_pig = zeros(1, 256); 

for i = 1:height
    for j = 1:width
         pixel_intensity= floor(norm_mag_pig(i, j)) + 1;
         histogram_pig(pixel_intensity) = histogram_pig(pixel_intensity) + 1;
    end
end

figure;
bar(0:255, histogram_pig, 'BarWidth', 1);
title('Histogram of pig');
xlabel('Pixel Intensity');
ylabel('Frequency');


cdf_pig = zeros(size(histogram_pig));
cumulative_sum = 0;
for i = 1:length(histogram_pig)
    cumulative_sum = cumulative_sum + histogram_pig(i);
    cdf_pig(i) = cumulative_sum;
end
total_pixels_pig = sum(histogram_pig);
threshold_90_pig = find(cdf_pig >= 0.9 * total_pixels_pig, 1) - 1;
fprintf('Pig image with 90%% threshold value: %d\n', threshold_90_pig);

threshold_pig_img = zeros(height, width);

for i = 1:height
    for j = 1:width
        if norm_mag_pig(i,j) < threshold_90_pig
            threshold_pig_img(i, j) = 255; 
        else
            threshold_pig_img(i, j) = 0; 
        end
    end
end

figure
imshow(threshold_pig_img/255)
title('Threshold Tiger Pig')

filename = 'Pig_SobelEdgeDetected.raw';
writeraw(threshold_pig_img, filename, true);

imwrite(norm_mag_pig, 'Sobel_detected_pig.png');

% functions for grayscale img, convolution and padding 

  function grayscale_img = get_grayscale(rgb_img)
     R_ch = rgb_img(:, :, 1);
     G_ch = rgb_img(:, :, 2);
     B_ch = rgb_img(:, :, 3);

     grayscale_img = 0.2989 * R_ch + 0.5870 * G_ch + 0.1140 * B_ch;
 end

 function padded_img = get_padded_image(grayscale_img, height, width)
    padded_img = zeros(height + 2, width + 2);
    padded_img(2:end-1, 2:end-1) = grayscale_img;
    padded_img(1, 2:end-1) = grayscale_img(1, :);
    padded_img(end, 2:end-1) = grayscale_img(end, :);
    padded_img(2:end-1, 1) = grayscale_img(:, 1);
    padded_img(2:end-1, end) = grayscale_img(:, end);
    padded_img(1, 1) = grayscale_img(1, 1);
    padded_img(1, end) = grayscale_img(1, end);
    padded_img(end, 1) = grayscale_img(end, 1);
    padded_img(end, end) = grayscale_img(end, end);
 end

function conv_img = get_convoluted_image(padded_img,kernel,height,width)
    for i = 1:height
      for j= 1: width
          conv_pixels = padded_img(i:i+2,j:j+2);
          pixel_conv_value = sum(sum(conv_pixels.*kernel));
          conv_img(i,j) = pixel_conv_value;
      end
    end
end


