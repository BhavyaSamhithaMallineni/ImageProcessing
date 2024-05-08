
%  EE569 Homework Assignment #3
% Date  : March 10, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 1a : Histographic Transformation and Image Stitching 
% Implementation : Histographic Transformation and Image Stitching
% M-file: HW3_Problem2
% Input Image File : toys_left.raw, toys_right.raw, toys_middle.raw
% Output Image File : panorama.raw
% Open Source Code used :  readraw.m and writeraw.m and
% detectSURFFeatures.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename_left = 'toys_left.raw';
filename_center = 'toys_middle.raw';
filename_right = 'toys_right.raw';
width = 605;
height = 454;

left = readraw(filename_left, height, width, false);
middle = readraw(filename_center, height, width, false);
right = readraw(filename_right, height ,width, false);

% figure;
% imshow(left_rgb_image/255);
% title('Left Toys Image');
% 
% figure;
% imshow(center_rgb_image/255);
% title('Center Toys Image');
% 
% figure;
% imshow(right_rgb_image/255);
% title('Right Toys Image');

%Convert to grayscale

left_gray= get_grayscale(left);
gray_l = uint8(left_gray);
middle_gray=get_grayscale(middle);
gray_m = uint8(middle_gray);
right_gray = get_grayscale(right);
gray_r = uint8(right_gray);

% figure;
% imshow(left_image/255);
% title('Left Toys GrayScaleImage');
% 
% figure;
% imshow(center_image/255);
% title('Center Toys GrayScaleImage');
% 
% figure;
% imshow(right_image/255);
% title('Right Toys GrayScaleImage');


lp = detectSURFFeatures(gray_l);
mp= detectSURFFeatures(gray_m);
rp = detectSURFFeatures(gray_r);

[left_f, points_left] = extractFeatures(gray_l, lp);
[middle_f, points_middle] = extractFeatures(gray_m, mp);
[right_f, points_right] = extractFeatures(gray_r, rp);


index_left_middle = matchFeatures(middle_f, left_f,'Unique',true);
index_right_middle = matchFeatures(middle_f, right_f,'Unique',true);

left_matched_points = points_left(index_left_middle(:,2), :);
right_matched_points = points_right(index_right_middle(:,2), :);
left_middle_matched_points = points_middle(index_left_middle(:,1), :);
right_middle_matched_points = points_middle(index_right_middle(:,1), :);

figure; imshow(gray_l);
axis on;
hold on;
plot(left_matched_points([10, 24, 3, 14]));
title('Left Matching Points');

figure; imshow(gray_m);
axis on;
hold on;
plot(left_middle_matched_points([10, 24, 3, 14]));
title('Left and Middle Matching Points');

figure; imshow(gray_r);
axis on;
hold on;
plot(right_matched_points([10, 24, 3, 14]));
title('Right Matching Points')

figure; imshow(gray_m);
axis on;
hold on;
plot(right_middle_matched_points([10, 24, 3, 14]));
title('Right and Middle Matching Points')


plot_indices = [10, 24, 3, 14];

if size(index_left_middle, 1) >= plot_indices(end) && size(index_right_middle, 1) >= plot_indices(end)

    plot_left_middle = index_left_middle(plot_indices, :);
    plot_right_middle = index_right_middle(plot_indices, :);

    specificMatchedPoints_L = points_left(plot_left_middle(:,2), :);
    specificMatchedPoints_R = points_right(plot_right_middle(:,2), :);
    specificMatchedPoints_LM = points_middle(plot_left_middle(:,1), :);
    specificMatchedPoints_RM = points_middle(plot_right_middle(:,1), :);
end   

    figure; showMatchedFeatures(gray_m, gray_l, specificMatchedPoints_LM, specificMatchedPoints_L, 'montage');
    legend(' matched points middle', 'matched points left');

    figure; showMatchedFeatures(gray_m, gray_r, specificMatchedPoints_RM, specificMatchedPoints_R, 'montage');
    legend(' matched points middle', 'matched points right');

%%%%% Canvas 

image_canvas = zeros(1400, 2215, 3);


image_canvas(473:926, 1:605, :) = left(:,:,:);
image_canvas(473:926, 805:1409, :) = middle(:,:,:);
image_canvas(473:926, 1610:2214, :) = right(:,:,:);

figure;
imshow(uint8(image_canvas));
title("Arranging the Images on Canvas");

% left
left_x = left_matched_points.Location([10, 24, 3, 14],1);             
left_y = left_matched_points.Location([10, 24, 3, 14],2) + 322; 
%middle
middle_left_x = left_middle_matched_points.Location([10, 24, 3, 14],1) + 605+200;    
middle_left_y = left_middle_matched_points.Location([10, 24, 3, 14],2) + 322;    
middle_right_x = right_middle_matched_points.Location([10, 24, 3, 14],1) + 605+200;       
middle_right_y = right_middle_matched_points.Location([10, 24, 3, 14],2) + 322; 
%right
right_x = right_matched_points.Location([10, 24, 3, 14],1) + (605+200)*2;         
right_y = right_matched_points.Location([10, 24, 3, 14],2) + 322;          

% left and middle homography matrix
syms h11 h12 h13 h21 h22 h23 h31 h32 
s1 = h11*left_x(1) + h12*left_y(1) + h13 == middle_left_x(1)*(h31*left_x(1) + h32*left_y(1) + 1);
s2 = h21*left_x(1) + h22*left_y(1) + h23 == middle_left_y(1)*(h31*left_x(1) + h32*left_y(1) + 1);
s3 = h11*left_x(2) + h12*left_y(2) + h13 == middle_left_x(2)*(h31*left_x(2) + h32*left_y(2) + 1);
s4 = h21*left_x(2) + h22*left_y(2) + h23 == middle_left_y(2)*(h31*left_x(2) + h32*left_y(2) + 1);
s5 = h11*left_x(3) + h12*left_y(3) + h13 == middle_left_x(3)*(h31*left_x(3) + h32*left_y(3) + 1);
s6 = h21*left_x(3) + h22*left_y(3) + h23 == middle_left_y(3)*(h31*left_x(3) + h32*left_y(3) + 1);
s7 = h11*left_x(4) + h12*left_y(4) + h13 == middle_left_x(4)*(h31*left_x(4) + h32*left_y(4) + 1);
s8 = h21*left_x(4) + h22*left_y(4) + h23 == middle_left_y(4)*(h31*left_x(4) + h32*left_y(4) + 1);

[M, N] = equationsToMatrix([s1, s2, s3, s4, s5, s6, s7, s8], [h11, h12, h13, h21, h22, h23, h31, h32]);
x = linsolve(M,N);

h11 = double(x(1));
h12 = double(x(2));
h13 = double(x(3));
h21 = double(x(4));
h22 = double(x(5));
h23 = double(x(6));
h31 = double(x(7));
h32 = double(x(8));
h33 = double(1);

left_homo_mat = [h11 h12 h13; h21 h22 h23; h31 h32 h33];

% right and middle homography matrix
syms h11_r h12_r h13_r h21_r h22_r h23_r h31_r h32_r 
s1 = h11_r*right_x(1) + h12_r*right_y(1) + h13_r == middle_right_x(1)*(h31_r*right_x(1) + h32_r*right_y(1) + 1);
s2 = h21_r*right_x(1) + h22_r*right_y(1) + h23_r == middle_right_y(1)*(h31_r*right_x(1) + h32_r*right_y(1) + 1);
s3 = h11_r*right_x(2) + h12_r*right_y(2) + h13_r == middle_right_x(2)*(h31_r*right_x(2) + h32_r*right_y(2) + 1);
s4 = h21_r*right_x(2) + h22_r*right_y(2) + h23_r == middle_right_y(2)*(h31_r*right_x(2) + h32_r*right_y(2) + 1);
s5 = h11_r*right_x(3) + h12_r*right_y(3) + h13_r == middle_right_x(3)*(h31_r*right_x(3) + h32_r*right_y(3) + 1);
s6 = h21_r*right_x(3) + h22_r*right_y(3) + h23_r == middle_right_y(3)*(h31_r*right_x(3) + h32_r*right_y(3) + 1);
s7 = h11_r*right_x(4) + h12_r*right_y(4) + h13_r == middle_right_x(4)*(h31_r*right_x(4) + h32_r*right_y(4) + 1);
s8 = h21_r*right_x(4) + h22_r*right_y(4) + h23_r == middle_right_y(4)*(h31_r*right_x(4) + h32_r*right_y(4) + 1);

[M, N] = equationsToMatrix([s1, s2, s3, s4, s5, s6, s7, s8], [h11_r, h12_r, h13_r, h21_r, h22_r, h23_r, h31_r, h32_r]);
x = linsolve(M,N);


h11_r = double(x(1));
h12_r = double(x(2));
h13_r = double(x(3));
h21_r = double(x(4));
h22_r = double(x(5));
h23_r = double(x(6));
h31_r = double(x(7));
h32_r = double(x(8));
h33_r = double(1);

right_homo_mat = [h11_r h12_r h13_r; h21_r h22_r h23_r; h31_r h32_r h33_r];


left_image_canvas = zeros(1400, 2215, 3);
left_image_canvas(473:926, 605+200+10:605+200+605+9, :) = middle(:,:,:);

figure;
imshow(uint8(left_image_canvas));


for a = 1:height
    for b = 1:width
        for c = 1:3
            
            x = b-0.5;
            y = (a+473)-0.5;
            x_i = x*left_homo_mat(1,1) + y*left_homo_mat(1,2) + left_homo_mat(1,3);
            y_i = x*left_homo_mat(2,1) + y*left_homo_mat(2,2) + left_homo_mat(2,3);
            z_i = x*left_homo_mat(3,1) + y*left_homo_mat(3,2) + left_homo_mat(3,3);
            xnew = x_i/z_i;
            ynew = y_i/z_i;
            i_loc = round(ynew-0.5);
            j_loc = round(xnew+0.5);

            if ((473<=i_loc)&&(i_loc<=926))&&((605+200+50<=j_loc)&&(j_loc<=605+200+605+49))
                left_image_canvas(i_loc, j_loc, c) = left_image_canvas(i_loc, j_loc, c);
            else
                left_image_canvas(i_loc, j_loc, c) = left(a, b, c);
            end
        end
    end
end
figure;
imshow(uint8(left_image_canvas));
title('left stiching')



for a = 1:height
    for b = 1:width
        for c = 1:3
            x = (b+(605+200)*2)-0.5;
            y = (a+473)-0.5;

            x_i = x*right_homo_mat(1,1) + y*right_homo_mat(1,2) + right_homo_mat(1,3);
            y_i = x*right_homo_mat(2,1) + y*right_homo_mat(2,2) + right_homo_mat(2,3);
            z_i = x*right_homo_mat(3,1) + y*right_homo_mat(3,2) + right_homo_mat(3,3);

            
            xnew = x_i/z_i;
            ynew = y_i/z_i;

            i_loc = round(ynew-0.5);
            j_loc = round(xnew+0.5);

            if ((473<=i_loc)&&(i_loc<=926))&&((605+200-10<=j_loc)&&(j_loc<=605+200+605-11))
                left_image_canvas(i_loc, j_loc, c) = left_image_canvas(i_loc, j_loc, c);
            else
                left_image_canvas(i_loc, j_loc+21, c) = right(a, b, c);
            end
        end
    end
end
imshow(uint8(left_image_canvas));


right_image_canvas = left_image_canvas;



for i = 2:1399
    for j = 2:2214
        for k = 1:3

            if left_image_canvas(i,j, k) == 0

                if left_image_canvas(i-1, j-1, k) ~= 0
                    right_image_canvas(i,j,k) = left_image_canvas(i-1, j-1, k);

                elseif left_image_canvas(i-1, j, k) ~= 0
                    right_image_canvas(i,j,k) = left_image_canvas(i-1, j, k);

                elseif left_image_canvas(i-1, j+1, k) ~= 0
                    right_image_canvas(i,j,k) = left_image_canvas(i-1, j+1, k);

                elseif left_image_canvas(i, j-1, k) ~= 0
                    right_image_canvas(i,j,k) = left_image_canvas(i, j-1, k);

                elseif left_image_canvas(i, j+1, k) ~= 0
                    right_image_canvas(i,j,k) = left_image_canvas(i, j+1, k);
                elseif left_image_canvas(i+1, j-1, k) ~= 0
                    right_image_canvas(i,j,k) = left_image_canvas(i+1, j-1, k);

                elseif left_image_canvas(i+1, j+1, k) ~= 0
                    right_image_canvas(i,j, k) = left_image_canvas(i+1, j+1, k);

                elseif left_image_canvas(i+1, j, k) ~= 0
                    right_image_canvas(i,j,k) = left_image_canvas(i+1, j, k);
                end
            end
        end
    end
end

figure;
imshow(uint8(right_image_canvas));
title('Right Stitching')

panorama = right_image_canvas;


for i = 2:1054
    for j = 2:1499
        for k = 1:3

            if right_image_canvas(i,j,k) == 0
               
                if right_image_canvas(i-1, j-1, k) ~= 0
                    panorama(i,j,k) = right_image_canvas(i-1, j-1, k);
               
                elseif right_image_canvas(i-1, j, k) ~= 0
                    panorama(i,j,k) = right_image_canvas(i-1, j, k);
                
                elseif right_image_canvas(i-1, j+1, k) ~= 0
                    panorama(i,j,k) = right_image_canvas(i-1, j+1, k);
                
                elseif right_image_canvas(i, j-1, k) ~= 0
                    panorama(i,j,k) = right_image_canvas(i, j-1, k);
                
                elseif right_image_canvas(i, j+1, k) ~= 0
                    panorama(i,j,k) = right_image_canvas(i, j+1, k);
                
                elseif right_image_canvas(i+1, j-1, k) ~= 0
                    panorama(i,j,k) = right_image_canvas(i+1, j-1, k);
               
                elseif right_image_canvas(i+1, j+1, k) ~= 0
                    panorama(i,j,k) = right_image_canvas(i+1, j+1, k);
                
                elseif right_image_canvas(i+1, j, k) ~= 0
                    panorama(i,j,k) = right_image_canvas(i+1, j, k);
                end
            end
        end
    end
end

figure;
imshow(uint8(panorama));

title("Panorama Image");

filename = 'Panorama.raw';
writeraw(paorama, filename, false);