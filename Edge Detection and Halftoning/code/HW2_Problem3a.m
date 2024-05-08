%  EE569 Homework Assignment #2
% Date  : February 19, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 3a : Colour Halftoning 
% Implementation :Separable Error Diffusion
% M-file: HW2_Problem3a
% Input Image File : Bird.raw
% Output Image File : Sep_Bird.raw
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = 'Bird.raw';
width = 500;
height = 375;



rgb_img = readraw(filename, height, width, false);

figure
imshow(rgb_img/255)
title('Original Bird RGB Image')

R_ch = rgb_img(:, :, 1)/255;
G_ch = rgb_img(:, :, 2)/255;
B_ch = rgb_img(:, :, 3)/255 ;

C_ch = (1 - R_ch)*255;
M_ch = (1 - G_ch)*255;
Y_ch = (1 - B_ch)*255;

cmy_img = cat(3, C_ch, M_ch, Y_ch); 

figure
imshow(cmy_img/255)
title('Bird CMY Image')

fs_error_C = get_FSError_image(C_ch, height, width);
fs_error_M = get_FSError_image(M_ch, height, width);
fs_error_Y = get_FSError_image(Y_ch, height, width);

fs_error_R = 1 - fs_error_C;
fs_error_G = 1 - fs_error_M;
fs_error_B = 1 - fs_error_Y;

fs_error_rgb(:,:,1) = fs_error_R;
fs_error_rgb(:,:,2) = fs_error_G;
fs_error_rgb(:,:,3) = fs_error_B;


% fs_error_rgb= cat(3, fs_error_R,fs_error_G, fs_error_B);
% fs_error_cmy= cat(3, fs_error_C,fs_error_M, fs_error_Y);
figure
imshow(fs_error_rgb)
title('FS RGB Image')

filename = 'Sep_Bird.raw';
writeraw(fs_error_rgb, filename, false);

function fs_error_img = get_FSError_image(image, height, width)
    dup_light_img = image; 
    fs_error_img = zeros(height, width);
    a = 7/16;
    b = 3/16;
    c = 5/16;
    d = 1/16;
    for i = 1:height
        for j = 1:width
            if dup_light_img(i, j) < 128
                fs_error_img(i, j) = 0;
                error = dup_light_img(i, j);
            else
                fs_error_img(i, j) = 255;
                error = dup_light_img(i, j) - 255;
            end

            if i < height
                if j > 1
                    dup_light_img(i+1, j-1) = dup_light_img(i+1, j-1) + error * b;
                end
                dup_light_img(i+1, j) = dup_light_img(i+1, j) + error * c;
                if j < width
                    dup_light_img(i+1, j+1) = dup_light_img(i+1, j+1) + error * d;
                end
            end

            if j < width
                dup_light_img(i, j+1) = dup_light_img(i, j+1) + error * a;
            end
        end
    end
end

