%  EE569 Homework Assignment #4
% Date  : March 29, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 3 : SIFT and Image Matching 
% Implementation : Image Matching
% M-file: HW4_Problem3b
% Input Image File : cat_1.png, cat_2.png, cat_3.png and dog_1.png
% Open Source Code used : vl_sift.m, vl_ubcmatch ,vl_plotframe and vl_plotsiftdescriptor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc
% read the  cat and dog  images  

height = 180;
width = 270;

filename_cat1= "cat_3.png";
cat_1 = imread(filename_cat1);

figure;
imshow(cat_1);
title('Cat 1')


filename_cat2= "cat_2.png";
cat_2 = imread(filename_cat2);

figure;
imshow(cat_2);
title('Cat 2')


filename_cat3= "cat_1.png";
cat_3 = imread(filename_cat3);

figure;
imshow(cat_3);
title('Cat 3')


filename_dog1= "dog_1.png";
dog_1= imread(filename_dog1);

figure;
imshow(dog_1);
title('Dog 1')

% convert the images to grayscale
cat_1_gray = rgb2gray(cat_1);
cat_2_gray = rgb2gray(cat_2);
cat_3_gray = rgb2gray(cat_3);
dog_1_gray = rgb2gray(dog_1);

% convert these images to single precision suitable for vl_sift
cat_1_gray_single = single(cat_1_gray);
cat_2_gray_single = single(cat_2_gray);
cat_3_gray_single = single(cat_3_gray);
dog_1_gray_single = single(dog_1_gray);

% extract the features and the descriptors using vl_sift
[feature_cat1, descriptors_cat1] = vl_sift(cat_1_gray_single);
[feature_cat2, descriptors_cat2] = vl_sift(cat_2_gray_single);
[feature_cat3, descriptors_cat3] = vl_sift(cat_3_gray_single);
[feature_dog1, descriptors_dog1] = vl_sift(dog_1_gray_single);


%% Comparision between Cat 1 and Cat 3
key_point_cat1 = get_LargeScale(feature_cat1)

% findig the key point in cat3 

d_cat1 = descriptors_cat1(:,key_point_cat1);
closest_key_13 = get_Closest_Descriptor(d_cat1,descriptors_cat3)


%plotting 
figure(1);
subplot(1,2,1);
imshow(cat_1);
kpfh_cat1 = vl_plotframe(feature_cat1(:,key_point_cat1));
set(kpfh_cat1,'color','r','linewidth',2) ;
kpdh_cat1 = vl_plotsiftdescriptor(descriptors_cat1(:,key_point_cat1),feature_cat1(:,key_point_cat1));
set(kpdh_cat1,'color','y') ;


figure(1);
subplot(1,2,2);
imshow(cat_3);
kpfh_cat3 = vl_plotframe(feature_cat3(:,closest_key_13));
set(kpfh_cat3,'color','r','linewidth',2) ;
kpdh_cat3 = vl_plotsiftdescriptor(descriptors_cat3(:,closest_key_13), feature_cat3(:,closest_key_13));
set(kpdh_cat3,'color','y') ;


[matches_13, scores_13] = vl_ubcmatch(descriptors_cat1, descriptors_cat3, 1.25);
cat_1_and_cat_3 = [cat_1, cat_3];
figure; imshow(cat_1_and_cat_3);
title('Feature Matches between Cat 1 and Cat 3');
hold on;

feature_cat3_adjusted = feature_cat3;
feature_cat3_adjusted(1,:) = feature_cat3(1,:) + size(cat_1, 2);

xa = feature_cat1(1,matches_13(1,:));
ya = feature_cat1(2,matches_13(1,:));
xb = feature_cat3_adjusted(1,matches_13(2,:));
yb = feature_cat3_adjusted(2,matches_13(2,:));
h = line([xa ; xb], [ya ; yb]);
set(h,'linewidth', 1, 'color', 'b');

vl_plotframe(feature_cat1(:,matches_13(1,:)));
vl_plotframe(feature_cat3_adjusted(:,matches_13(2,:)));

%% Comparison between Cat 3 and Cat 2
key_point_cat3 = get_LargeScale(feature_cat3)

% Finding the key points in cat_2
d_cat3 = descriptors_cat3(:, key_point_cat3);
closest_key_23 = get_Closest_Descriptor(d_cat3, descriptors_cat2)

% Plotting
figure(2);
subplot(1,2,1);
imshow(cat_3);
kpfh_cat3 = vl_plotframe(feature_cat3(:, key_point_cat3));
set(kpfh_cat3, 'color', 'r', 'linewidth', 2);
kpdh_cat3 = vl_plotsiftdescriptor(descriptors_cat3(:, key_point_cat3), feature_cat3(:, key_point_cat3));
set(kpdh_cat3, 'color', 'y');

subplot(1,2,2);
imshow(cat_2);
kpfh_cat2 = vl_plotframe(feature_cat2(:, closest_key_23));
set(kpfh_cat2, 'color', 'r', 'linewidth', 2);
kpdh_cat2 = vl_plotsiftdescriptor(descriptors_cat2(:, closest_key_23), feature_cat2(:, closest_key_23));
set(kpdh_cat2, 'color', 'y');

% Matching Features between Cat 3 and Cat 2
[matches_32, scores_32] = vl_ubcmatch(descriptors_cat3, descriptors_cat2, 1.35);
cat_3_and_cat_2 = [cat_3, cat_2];
figure; imshow(cat_3_and_cat_2);
title('Feature Matches between Cat 3 and Cat 2');
hold on;

feature_cat2_adjusted = feature_cat2;
feature_cat2_adjusted(1, :) = feature_cat2(1, :) + size(cat_3, 2);

xa = feature_cat3(1, matches_32(1, :));
ya = feature_cat3(2, matches_32(1, :));
xb = feature_cat2_adjusted(1, matches_32(2, :));
yb = feature_cat2_adjusted(2, matches_32(2, :));
h = line([xa ; xb], [ya ; yb]);
set(h, 'linewidth', 1, 'color', 'b');

vl_plotframe(feature_cat3(:, matches_32(1, :)));
vl_plotframe(feature_cat2_adjusted(:, matches_32(2, :)));

%% Comparison between Dog 1 and Cat 3
key_point_dog1 = get_LargeScale(feature_dog1);

% Finding the key points in cat_3
d_dog1 = descriptors_dog1(:, key_point_dog1);
closest_key_13 = get_Closest_Descriptor(d_dog1, descriptors_cat3);

% Plotting
figure(3);
subplot(1,2,1);
imshow(dog_1);
kpfh_dog1 = vl_plotframe(feature_dog1(:, key_point_dog1));
set(kpfh_dog1, 'color', 'r', 'linewidth', 2);
kpdh_dog1 = vl_plotsiftdescriptor(descriptors_dog1(:, key_point_dog1), feature_dog1(:, key_point_dog1));
set(kpdh_dog1, 'color', 'y');

subplot(1,2,2);
imshow(cat_3);
kpfh_cat3 = vl_plotframe(feature_cat3(:, closest_key_13));
set(kpfh_cat3, 'color', 'r', 'linewidth', 2);
kpdh_cat3 = vl_plotsiftdescriptor(descriptors_cat3(:, closest_key_13), feature_cat3(:, closest_key_13));
set(kpdh_cat3, 'color', 'y');

% Matching Features between Dog 1 and Cat 3
[matches_13, scores_13] = vl_ubcmatch(descriptors_dog1, descriptors_cat3, 1.35);
dog_1_and_cat_3 = [dog_1, cat_3];
figure; imshow(dog_1_and_cat_3);
title('Feature Matches between Dog 1 and Cat 3');
hold on;

feature_cat3_adjusted = feature_cat3;
feature_cat3_adjusted(1, :) = feature_cat3(1, :) + size(dog_1, 2);

xa = feature_dog1(1, matches_13(1, :));
ya = feature_dog1(2, matches_13(1, :));
xb = feature_cat3_adjusted(1, matches_13(2, :));
yb = feature_cat3_adjusted(2, matches_13(2, :));
h = line([xa ; xb], [ya ; yb]);
set(h, 'linewidth', 1, 'color', 'b');

vl_plotframe(feature_dog1(:, matches_13(1, :)));
vl_plotframe(feature_cat3_adjusted(:, matches_13(2, :)));

%% Comparison between Cat 1 and Dog 1
key_point_cat1 = get_LargeScale(feature_cat1);

% Finding the key points in dog_1
d_cat1 = descriptors_cat1(:, key_point_cat1);
closest_key_11 = get_Closest_Descriptor(d_cat1, descriptors_dog1);

% Plotting
figure(4);
subplot(1,2,1);
imshow(cat_1);
kpfh_cat1 = vl_plotframe(feature_cat1(:, key_point_cat1));
set(kpfh_cat1, 'color', 'r', 'linewidth', 2);
kpdh_cat1 = vl_plotsiftdescriptor(descriptors_cat1(:, key_point_cat1), feature_cat1(:, key_point_cat1));
set(kpdh_cat1, 'color', 'y');

subplot(1,2,2);
imshow(dog_1);
kpfh_dog1 = vl_plotframe(feature_dog1(:, closest_key_11));
set(kpfh_dog1, 'color', 'r', 'linewidth', 2);
kpdh_dog1 = vl_plotsiftdescriptor(descriptors_dog1(:, closest_key_11), feature_dog1(:, closest_key_11));
set(kpdh_dog1, 'color', 'y');

% Matching Features between Cat 1 and Dog 1
[matches_11, scores_11] = vl_ubcmatch(descriptors_cat1, descriptors_dog1, 1.25);
cat_1_and_dog_1 = [cat_1, dog_1];
figure; imshow(cat_1_and_dog_1);
title('Feature Matches between Cat 1 and Dog 1');
hold on;

feature_dog1_adjusted = feature_dog1;
feature_dog1_adjusted(1, :) = feature_dog1(1, :) + size(cat_1, 2);

xa = feature_cat1(1, matches_11(1, :));
ya = feature_cat1(2, matches_11(1, :));
xb = feature_dog1_adjusted(1, matches_11(2, :));
yb = feature_dog1_adjusted(2, matches_11(2, :));
h = line([xa ; xb], [ya ; yb]);
set(h, 'linewidth', 1, 'color', 'b');

vl_plotframe(feature_cat1(:, matches_11(1, :)));
vl_plotframe(feature_dog1_adjusted(:, matches_11(2, :)));


%% Functions

% function to find the key point corresponding to largest scale
function key_point = get_LargeScale(feature_frame)
    key_point = 0;
    scale = 0;
    for i = 1:size(feature_frame,2)
       pixl_scale = feature_frame(3,i);
       if pixl_scale > scale
           scale = pixl_scale;
           key_point = i;
       end
    end
end
% function to find the nearest neighbor 
function closest_key = get_Closest_Descriptor(descriptor1, descriptor2)
    initial_dist = 100000000;
    closest_key = 0;
    d1 = double(descriptor1);
    for i = 1:size(descriptor2, 2)
        d2 = double(descriptor2(:,i));
        distance = sum((d1 - d2).^2);
        if distance < initial_dist
            closest_key = i;
            initial_dist = distance;
        end
    end
end
