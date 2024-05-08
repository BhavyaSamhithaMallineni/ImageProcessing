%  EE569 Homework Assignment #2
% Date  : February 19, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 1a : Edge Detection
% Implementation : Canny Edge Detection 
% M-file: HW2_Problem1b
% Input Image File : Tiger.raw, Pig.raw
% Output Image File : Tiger_CannyEdgeDetected.raw, Pig_CannyEdgeDetected.raw
% Open Source Code used : edge.m and readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% Tiger %%%%%
tiger_filename = 'Tiger.raw';
pig_filename ='Pig.raw';

width = 481 ;
height = 321 ;

tiger_rgb_img = readraw(tiger_filename, height, width, false);

tiger_grayscale_img =  get_grayscale(tiger_rgb_img);

Canny_tiger_20_80 = edge(tiger_grayscale_img, 'canny', [0.2 0.8]);
figure
imshow(Canny_tiger_20_80)
title('Canny Edge Tiger Image values 20% and 80%')

Canny_tiger_40_70 = edge(tiger_grayscale_img, 'canny', [0.4 0.7]);
figure
imshow(Canny_tiger_40_70)
title('Canny Edge Tiger Image values 40% and 70%')

Canny_tiger_30_50 = edge(tiger_grayscale_img, 'canny', [0.3 0.5]);
figure
imshow(Canny_tiger_30_50)
title('Canny Edge Tiger Image values 30% and 50%')

Canny_tiger_30_40 = edge(tiger_grayscale_img, 'canny', [0.3 0.4]);
figure
imshow(Canny_tiger_30_40)
title('Canny Edge Tiger Image values 30% and 40%')
% Writing the image into a raw file
filename = 'Tiger_CannyEdgeDetected.raw';
writeraw(Canny_tiger_30_50, filename, true);

Canny_tiger_30_50= im2uint8(Canny_tiger_30_50); 
imwrite(Canny_tiger_30_50, 'Canny_detected_tiger.png');

%%%%% Pig %%%%%%

pig_rgb_img = readraw(pig_filename, height, width, false);

pig_grayscale_img =  get_grayscale(pig_rgb_img);

Canny_pig_30_80 = edge(pig_grayscale_img, 'canny', [0.5 0.8]);
figure
imshow(Canny_pig_30_80)
title('Canny Edge pig Image values 30% and 80%')

Canny_pig_10_50 = edge(pig_grayscale_img, 'canny', [0.1 0.5]);
figure
imshow(Canny_pig_10_50)
title('Canny Edge pig Image values 40% and 50%')

Canny_pig_10_35 = edge(pig_grayscale_img, 'canny', [0.1 0.35]);
figure
imshow(Canny_pig_10_35)
title('Canny Edge pig Image values 10% and 35%')


filename = 'Pig_CannyEdgeDetected.raw';
writeraw(Canny_pig_10_35, filename, true);

Canny_pig_10_35= im2uint8(Canny_pig_10_35);
imwrite(Canny_pig_10_35, 'Canny_detected_pig.png');


% functions for grayscale img, convolution and padding 

  function grayscale_img = get_grayscale(rgb_img)
     R_ch = rgb_img(:, :, 1);
     G_ch = rgb_img(:, :, 2);
     B_ch = rgb_img(:, :, 3);

     grayscale_img = 0.2989 * R_ch + 0.5870 * G_ch + 0.1140 * B_ch;
 end

 