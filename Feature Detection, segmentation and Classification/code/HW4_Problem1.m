%  EE569 Homework Assignment #4
% Date  : March 29, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 1a : Texture Analysis 
% Implementation : Texture Classification and Feature Extraction
% M-file: HW4_Problem1a
% Input Image File : train set and test set
% Open Source Code used : readraw.m and writeraw.m , kmeans.m, pca,
% fitcecoc.m 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc


% samples of the blanket brink grass and stones %%%


height = 128;
width = 128;
f1= "train/blanket_1.raw";
blanket_1 = readraw(f1,height, width, true);

figure;
imshow(blanket_1/255);
title('blanket 1')

f2= "train/brick_1.raw";
brick_1 = readraw(f2,height, width, true);

figure;
imshow(brick_1/255);
title('brick 1')

f3= "train/grass_1.raw";
grass_1 = readraw(f3,height, width, true);

figure;
imshow(grass_1/255);
title('grass 1')

f4= "train/stones_1.raw";
stones_1 = readraw(f4,height, width, true);

figure;
imshow(stones_1/255);
title('stones 1')


%%%% 5x5 law filters %%%%%%

L5 = [1 4 6 4 1];
E5 = [-1 -2 0 2 1];
S5 = [-1 0 2 0 -1];
W5 = [-1 2 0 -2 1];
R5 = [1 -4 6 -4 1];

kernel_1D = {L5, E5, S5, W5, R5};
kernel_5x5 = zeros(5, 5, 25);

filter_num = 1;
for i = 1:length(kernel_1D)
    for j = 1:length(kernel_1D)
        kernel_2D = kernel_1D{i}' * kernel_1D{j};
        kernel_5x5(:,:,filter_num) = kernel_2D;
        filter_num = filter_num + 1;
    end
end

%%%%%% each image will have 25 energy levels 
% step-1 I1 conv with L5*L5 % each of thits energy as e1 e2 e3 e25,
% I2 conv with L5*E5.......... 25 times

%%% arrange all the train files in a array 

train_folder_path="train";


train_set_energy= {};
train_set_features = [];

train_images= dir(fullfile(train_folder_path,'*.raw'));
for i= 1:36 
    filename= fullfile(train_folder_path,train_images(i).name);
    train_image= readraw(filename,height,width,true);
    train_image = double(train_image);
    energy_levels = get_AverageEnergy(train_image,kernel_5x5);
    train_set_energy = [train_set_energy, energy_levels];
    train_set_features = [ train_set_features;cell2mat(train_set_energy(i))];
end

[strongest_feature,weakest_feature]  = get_DiscriminantPower(train_set_features)


mean_features = mean(train_set_features,1);
norm_features = train_set_features - mean_features;

[train_coeff, train_score, train_latent] = pca(norm_features);
transformed_train_features = train_set_features*train_coeff(:,1:3); 

train_blanket = transformed_train_features(1:9,:);
train_brick = transformed_train_features(10:18,:);
train_grass = transformed_train_features(19:27,:);
train_stone = transformed_train_features(28:36,:);
labels_train = [1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4];
scatter3(train_blanket(:,1),train_blanket(:,2),train_blanket(:,3));
hold on
scatter3(train_brick(:,1),train_brick(:,2),train_brick(:,3));
hold on
scatter3(train_grass(:,1),train_grass(:,2),train_grass(:,3));
hold on
scatter3(train_stone(:,1),train_stone(:,2),train_stone(:,3));
legend('Blanket','Brick','Grass','Stone');
xlabel('1st Principal Component')
ylabel('2nd Principal Component')
zlabel('3rd Principal Component')

% test data
test_folder_path="test";

test_set_energy= {};
test_set_features = [];

test_images= dir(fullfile(test_folder_path,'*.raw'));
for i= 1:12 
    filename= fullfile(test_folder_path,test_images(i).name);
    test_image= readraw(filename,height,width,true);
    test_image = double(test_image);
    energy_levels = get_AverageEnergy(test_image,kernel_5x5);
    test_set_energy = [test_set_energy, energy_levels];
    test_set_features = [ test_set_features;cell2mat(test_set_energy(i))];
end


mean_features = mean(test_set_features,1);
norm_features = test_set_features - mean_features;

%[test_coeff, test_score, test_latent] = pca(norm_features);

transformed_test_features = test_set_features*train_coeff(:,1:3);

true_labels = [2, 2, 1, 3, 1, 4, 1, 4, 3,3, 4, 2 ];
pred_labels = [];
for i = 1:size(transformed_test_features)
    test_d = transformed_test_features(i,:);
    label = get_NearestNeighbors(transformed_train_features, test_d);
    pred_labels = [pred_labels, label];
end

correct_pred_nn = 0;
for i = 1:12
    if true_labels(i) == pred_labels(i)
        correct_pred_nn = correct_pred_nn + 1;
    end
end

acc_nearest_neighbor = correct_pred_nn/12;
error = (12-correct_pred_nn)/12;


%% 1b
%here we use k-means on the test data using the 25D features we obtained
%and the 3D features we obtained after feature reduction.
% 
% % 25D features k-Means
% 
% %MaxIters = 1000;

pred_kmeans_25D = kmeans(test_set_features,4,'Distance','cityblock','MaxIter',100000);

correct_pred_kmeans = 0;
for i = 1:12
    if true_labels(i) == pred_kmeans_25D(i)
        correct_pred_kmeans = correct_pred_kmeans + 1;
    end
end
acc_kmeans_25D = correct_pred_kmeans/12;
%%%%%%%%%%%%
counter_25 = zeros(4, 4);
for i = 1:size(pred_kmeans_25D, 1)
    counter_25(pred_kmeans_25D(i), true_labels(i)) = counter_25(pred_kmeans_25D(i), true_labels(i)) + 1;
end
label_kmeans = zeros(1, 4);
for i = 1:4
    [~, I] = max(counter_25(i, :));
    label_kmeans(i) = I;
end
num_correct = sum(label_kmeans(pred_kmeans_25D') == true_labels);
acc1 = num_correct / 12;
%%%%%%
pred_kmeans_3D = kmeans(transformed_test_features,4,'Distance','cityblock','MaxIter',100000);

correct_pred_kmeans = 0;
for i = 1:12
    if true_labels(i) == pred_kmeans_3D(i)
        correct_pred_kmeans = correct_pred_kmeans + 1;
    end
end
acc_kmeans_3D = correct_pred_kmeans/12;
counter_3 = zeros(4, 4);
for i = 1:size(pred_kmeans_3D, 1)
    counter_3(pred_kmeans_3D(i), true_labels(i)) = counter_3(pred_kmeans_3D(i), true_labels(i)) + 1;
end
label_kmeans = zeros(1, 4);
for i = 1:4
    [~, I] = max(counter_3(i, :));
    label_kmeans(i) = I;
end
num_correct =sum(label_kmeans(pred_kmeans_3D') == true_labels);
acc2 = num_correct / 12;

%% SVM 
labels_train = [1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4];
true_labels = [2, 1, 4, 1, 4, 3,3, 4, 2, 2, 1, 3];


kernel_svm = templateSVM('Standardize',true,'KernelFunction','polynomial','Solver','ISDA');
%SVM= fitcecoc(train_fea, label_train, 'Learners', kernel_svm, 'FitPosterior',true);


SVM_25D = fitcecoc(train_set_features, labels_train, 'Learners', kernel_svm, 'FitPosterior',true);
pred_svm_25D = predict(SVM_25D, test_set_features);
correct_pred_svm = 0;
for i = 1:12
    if true_labels(i) == pred_svm_25D(i)
        correct_pred_svm = correct_pred_svm + 1;
    end
end
acc_svm_25D = correct_pred_svm/12;


SVM_3D = fitcecoc(transformed_train_features, labels_train, 'Learners', kernel_svm, 'FitPosterior',true);
pred_svm_3D = predict(SVM_3D, transformed_test_features);
correct_pred_svm = 0;
for i = 1:12
    if true_labels(i) == pred_svm_3D(i)
        correct_pred_svm = correct_pred_svm + 1;
    end
end
acc_svm_3D = correct_pred_svm/12;


error_nearest_neighbor= (12-acc_nearest_neighbor)/12 ;
error_kmeans_25D = (12-acc_kmeans_25D)/12 ;
error_kmeans_3D= (12-acc_kmeans_3D)/12 ;
error_svm_25D = (12-acc_svm_25D)/12 ;
error_kmeans_3D= (12-acc_svm_3D)/12 ;




%% Functions

function conv_img = get_ConvolutedImage(image, filter, height, width)

    conv_img = 0;
    for i = 0:4
        for j = 0:4
            conv_img = conv_img + (image(height+i, width+j) * filter(i+1, j+1));
        end
    end
end

function energy = get_AverageEnergy(image, law_filters)

    feat_vec = {};
    norm_mean = 0;
    for i = 1:128
        for j = 1:128
            norm_mean = norm_mean + image(i,j);
        end
    end
    norm_mean = (norm_mean / (128*128));

     for i = 1:128
         for j = 1:128
             image(i,j) = (image(i,j)-norm_mean); %/255.0;
         end
     end
        
    padded_img = zeros(132);
    %padded_img(3:130, 3:130) = img_data;
    padded_img = padarray(image, [2, 2], 'symmetric');


    for filter_index = 1:size(law_filters,3)
        out_filter = zeros(128);
        for row = 1:128
            for col = 1:128
                out_filter(row,col) = get_ConvolutedImage(padded_img, law_filters(:,:,filter_index), row, col);
            end
        end

        feat_vec = [feat_vec, out_filter];
    end
    
    energy = [];
    for i = 1:size(feat_vec,2)
        sum = 0;
        matrix = cell2mat(feat_vec(1,i));
        for j = 1:128
            for k = 1:128
                sum = sum + (matrix(i,j)*matrix(i,j));
            end
        end
        sum = sum/(128*128);
        energy = [energy, sum];
    end

     mean_energy = mean(energy);
     std_energy = std(energy);
     
     for i = 1:size(energy,2)
         energy(i) = (energy(i)-mean_energy)/std_energy;
     end
end



function [strongest_idx, weakest_idx] = get_DiscriminantPower(features)
    discrim_avg_blanket = mean(features(1:9,:));
    discrim_avg_brick = mean(features(10:18,:));
    discrim_avg_grass = mean(features(19:27,:));
    discrim_avg_stone = mean(features(28:36,:));

    intra_blanket = sum((features(1:9,:) - discrim_avg_blanket).^2);
    intra_brick = sum((features(10:18,:) - discrim_avg_brick).^2);
    intra_grass = sum((features(19:27,:) - discrim_avg_grass).^2);
    intra_stone = sum((features(28:36,:) - discrim_avg_stone).^2);

    intra_class_variation = intra_blanket + intra_brick + intra_grass + intra_stone;

    global_avg = mean(features);
    
    inter_class_variation = (8 * (discrim_avg_blanket - global_avg).^2) + ...
                            (8 * (discrim_avg_brick - global_avg).^2) + ...
                            (8 * (discrim_avg_grass - global_avg).^2) + ...
                            (8 * (discrim_avg_stone - global_avg).^2);

    discrim_power = intra_class_variation ./ inter_class_variation;
    
    % Finding the indices of the maximum and minimum discriminant power
    [~, strongest_idx] = max(discrim_power);
    [~, weakest_idx] = min(discrim_power);
end
function nearest_label = get_NearestNeighbors(train, test)
    blanket = train(1:9,:);
    brick = train(10:18,:);
    grass = train(19:27,:);
    stone = train(28:36,:);

    blanket = mahal(test, blanket);
    brick = mahal(test, brick);
    grass = mahal(test, grass);
    stone = mahal(test, stone);

    if (blanket < brick) && (blanket < grass) && (blanket < stone)
        nearest_label = 1;
    elseif (brick < blanket) && (brick < grass) && (brick < stone)
        nearest_label = 2;
    elseif (grass < blanket) && (grass < brick) && (grass < stone)
        nearest_label = 3;
    elseif (stone < blanket) && (stone < brick) && (stone < grass)
        nearest_label = 4;
    end
end

