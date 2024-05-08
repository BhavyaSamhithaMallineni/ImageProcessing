%  EE569 Homework Assignment #1
% Date  : January 28, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 1b : Histogram Equilization
% Implementation : Trasfer-function, bucket-filling
% M-file: HW1_Problem1b
% Input Image File : DimLight.raw
% Output Image File : DimLight_tf_equilized.raw, DimLight_bf_equilized
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Read the raw file
filename = 'DimLight.raw';
% declare the dimensions of the image
width = 596 ;
height = 340 ;
original_img = readraw(filename, height, width, true);

figure
imshow(original_img/255)
title('Original Image')

% find the initial histogram of the intensities.
histogram_og_img = GetHistogram(original_img,height,width);
figure
bar(1:256, histogram_og_img)
title('Histogram of Original Image')
xlabel('Intensity')
ylabel('Pixel Frequency')

% Histogram Equilization using Tansfer Function 
tf_equilized_image = zeros(height, width);
tf_equilized_img = GetTfEquilizedImage(original_img,height,width);
figure
imshow(tf_equilized_img/255)
title('Image after Transer function Histogram Equilization')

histogram_tf_img = GetHistogram(tf_equilized_img,height,width);
figure
bar(1:256, histogram_tf_img)
title('Histogram of Transfer Function Equilized Image')
xlabel('Intensity')
ylabel('Pixel Frequency')


% Histogram Equilization using Tansfer Function 
bf_equilized_image = zeros(height, width);
bf_equilized_img = GetBfEquilizedImage(original_img,height,width);
figure
imshow(bf_equilized_img/255)
title('Image after Bucket Histogram Equilization')

% Writing the image into a raw file
filename = 'DimLight_tf_equilized.raw';
writeraw(tf_equilized_img, filename, true);

filename = 'DimLight_bf_equilized.raw';
writeraw(bf_equilized_img, filename, true);

% this functions counts the frequency of each pixel intensity and stores it
function pixel_freq = GetHistogram(image, height, width)

     pixel_freq = zeros (1,256);
     for i =1: height
        for j = 1: width
           intensity = image(i,j) + 1 ;
           pixel_freq(intensity) = pixel_freq(intensity) + 1 ;
        end
     end
end


function tf_equilized_image = GetTfEquilizedImage(image, height, width)
 
 tf_equilized_image=zeros(height, width);

 pixel_freq = GetHistogram(image, height, width);

 total_pixel_count = sum(pixel_freq);
 probability = pixel_freq / total_pixel_count;

 cumulative_freq = zeros(1, 256);
 cumulative_freq(1) = probability(1);
 for i = 2:256
        cumulative_freq(i) = cumulative_freq(i - 1) + probability(i);
 end
 cumulative_dist = cumulative_freq * 255;

 for i = 1:height
     for j = 1:width
         intensity = image(i, j) + 1;
        tf_equilized_image(i,j) = floor(cumulative_dist(intensity));
      end
  end
end

function bf_equilized_image = GetBfEquilizedImage(image, height, width)
   bf_equilized_image=zeros(height, width);
   total_pixel_count = height*width;

   pixel_freq= GetHistogram(image, height, width);

   cdf = zeros(1,256);
   cdf(1) = pixel_freq(1);
    
    for i = 2:256
        cdf(i) = cdf(i - 1) + pixel_freq(i);
    end

    cdf = cdf / total_pixel_count;

    bf_equilized_image=zeros(height, width);
     for i = 1:height
        for j = 1:width
            bf_equilized_image(i, j) = floor(cdf(image(i, j) + 1) * 255);
        end
     end

    equalizedHistogram = zeros(1, 256);

    for intensity = 0:255
        count = sum(bf_equilized_image(:) == intensity);
        equalizedHistogram(intensity + 1) = count;
    end

    og_cdf = cumsum(pixel_freq) / total_pixel_count;
    bf_cdf = cumsum(equalizedHistogram) / total_pixel_count;

    % Display cumulative histograms
    figure;
    plot(0:255, og_cdf, 'g', 'LineWidth', 2);
    hold on;
    plot(0:255, bf_cdf, 'b', 'LineWidth', 2);
    title('Cumulative Histograms Before and After Enhancement');
    xlabel('Intensity Level');
    ylabel('Cumulative Probability');
    legend('Original Image', 'Equalized Image');
    hold off;
    
end







     
  