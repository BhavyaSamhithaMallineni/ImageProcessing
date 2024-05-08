%  EE569 Homework Assignment #4
% Date  : March 29, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 3 : SIFT and Image Matching 
% Implementation : Bag of Words
% M-file: HW4_Problem3c.m
% Input Image File : cat_1.png, cat_2.png, cat_3.png and dog_1.png
% Open Source Code used : vlsift.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

%%% read the cat and dog images %%%

height = 180;
width = 270;

filename_cat1= "cat_3.png";
cat_1 = imread(filename_cat1);

filename_cat2= "cat_2.png";
cat_2 = imread(filename_cat2);

filename_cat3= "cat_1.png";
cat_3 = imread(filename_cat3);

filename_dog1= "dog_1.png";
dog_1= imread(filename_dog1);

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
[feature_cat1, descriptors_cat1] = vl_sift(cat_1_gray_single,'Levels',28,'WindowSize',7,'Magnif',3,'PeakThresh',0.02,'EdgeThresh',8);
[feature_cat2, descriptors_cat2] = vl_sift(cat_2_gray_single,'Levels',28,'WindowSize',7,'Magnif',3,'PeakThresh',0.02,'EdgeThresh',8);
[feature_cat3, descriptors_cat3] = vl_sift(cat_3_gray_single,'Levels',28,'WindowSize',7,'Magnif',3,'PeakThresh',0.02,'EdgeThresh',8);
[feature_dog1, descriptors_dog1] = vl_sift(dog_1_gray_single,'Levels',28,'WindowSize',7,'Magnif',3,'PeakThresh',0.02,'EdgeThresh',8);

% combine all descriptors of 4 images
%data = [descriptors_cat1, descriptors_cat2, descriptors_cat3, descriptors_dog1];
desc_cat1 = get_ReducedFeatures(descriptors_cat1, 20);
desc_cat2 = get_ReducedFeatures(descriptors_cat2, 20);
desc_cat3 = get_ReducedFeatures(descriptors_cat3, 20);
desc_dog1 = get_ReducedFeatures(descriptors_dog1, 20);


data = [];
% 
% Cat 1
start_idx_cat1 = 1;
end_idx_cat1 = size(desc_cat1,1);
data = [data; desc_cat1];
% Cat 2
start_idx_cat2 = end_idx_cat1 + 1;
end_idx_cat2 = start_idx_cat2 + size(desc_cat2,2) - 1;
data = [data; desc_cat2];
% Cat 3
start_idx_cat3 = end_idx_cat2 + 1;
end_idx_cat3 = start_idx_cat3 + size(desc_cat3,2) - 1;
data = [data; desc_cat3];
% Dog
start_idx_dog1 = end_idx_cat3 + 1;
end_idx_dog1 = start_idx_dog1 + size(desc_dog1,2) - 1;
data = [data; desc_dog1];

 prediction = kmeans(data, 8, 'Distance', 'sqeuclidean', 'MaxIter', 100000);

 kmeans_cat1 = prediction(1:end_idx_cat1,:);
histogram_cat1 = zeros(1, 8);
for i = 1:size(kmeans_cat1, 1)
    histogram_cat1(kmeans_cat1(i)) = histogram_cat1(kmeans_cat1(i)) + 1;
end

kmeans_cat2 = prediction(152:321,:);
histogram_cat2 = zeros(1, 8);
for i = 1:size(kmeans_cat2, 1)
    histogram_cat2(kmeans_cat2(i)) = histogram_cat2(kmeans_cat2(i)) + 1;
end

kmeans_cat3 = prediction(322:523,:);
histogram_cat3 = zeros(1, 8);
for i = 1:size(kmeans_cat3, 1)
    histogram_cat3(kmeans_cat3(i)) = histogram_cat3(kmeans_cat3(i)) + 1;
end

kmeans_dog1 = prediction(524:700,:);
histogram_dog1 = zeros(1, 8);
for i = 1:size(kmeans_dog1, 1)
    histogram_dog1(kmeans_dog1(i)) = histogram_dog1(kmeans_dog1(i)) + 1;
end

% matching cat3 with cat1, cat2, and dog1
match_cat31 = get_SimilarityIndex(histogram_cat3, histogram_cat1);
match_cat32 = get_SimilarityIndex(histogram_cat3, histogram_cat2);
match_cat3dog = get_SimilarityIndex(histogram_cat3, histogram_dog1);

fprintf('Similarity between cat3 and cat1: %.2f%%\n', match_cat31 * 100);
fprintf('Similarity between cat3 and cat2: %.2f%%\n', match_cat32 * 100);
fprintf('Similarity between cat3 and dog1: %.2f%%\n', match_cat3dog * 100);

% Plot histograms
figure;

myColormap = parula(4); 

subplot(2, 2, 1);
bar(histogram_cat1, 'FaceColor', myColormap(1,:));
title('Histogram of Cat 1');

subplot(2, 2, 2);
bar(histogram_cat2, 'FaceColor', myColormap(2,:));
title('Histogram of Cat 2');


subplot(2, 2, 3);
bar(histogram_cat3, 'FaceColor', myColormap(3,:));
title('Histogram of Cat 3');

subplot(2, 2, 4);
bar(histogram_dog1, 'FaceColor', myColormap(4,:));
title('Histogram of Dog 1');


%% functions

function feature = get_ReducedFeatures(features, num)
    feat_transpose = transpose(features);
    feat_transpose = double(feat_transpose);

    [coeff, score, latent] = pca(feat_transpose);
    feature = feat_transpose * coeff(:,1:num);
end



% function to calculate match
function match = get_SimilarityIndex(h1, h2)
    min_val = 0;
    max_val = 0;
    for i = 1:size(h1, 2)
        min_val = min_val + min(h1(i), h2(i));
        max_val = max_val + max(h1(i), h2(i));
    end
    match = double(min_val / max_val);
end

