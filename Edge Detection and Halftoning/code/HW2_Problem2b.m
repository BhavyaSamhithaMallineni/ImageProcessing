%  EE569 Homework Assignment #2
% Date  : February 19, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 2a : Digital Halftoning 
% Implementation : error Diffusion
% M-file: HW2_Problem2b
% Input Image File : LightHouse.raw
% Output Image File : FS_LightHouse.raw, JJN_LightHouse.raw, Stucki_LightHouse.raw
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = 'LightHouse.raw';
width = 750;
height = 500;

light_img = readraw(filename, height, width, true);


%Floyd-Steinberg
fs_error_img= get_FSError_image(light_img,height,width);

figure;
imshow(fs_error_img/255);
title('Floyd Steinberg Error Image');

filename = 'FS_LightHouse.raw';
writeraw(fs_error_img, filename, true);

jjn_error_img= get_JJN_error_image(light_img,height,width);

figure;
imshow(jjn_error_img/255);
title('JJN Error Image');

filename = 'JJN_LightHouse.raw';
writeraw(jjn_error_img, filename, true);

stucki_error_img= get_Stucki_error_image(light_img,height,width);

filename = 'Stucki_LightHouse.raw';
writeraw(stucki_error_img, filename, true);

figure;
imshow(stucki_error_img/255);
title('Stucki Error Image');

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

function jjn_error_img = get_JJN_error_image(image, height, width)
    dup_light_img = image; 
    jjn_error_img = zeros(height, width);
    
    % JJN coefficients
    a = 7/48;
    b = 5/48;
    c = 3/48;
    d = 1/48;
    
    for i = 1:height
        for j = 1:width
            if dup_light_img(i, j) < 128
                jjn_error_img(i, j) = 0;
                error = dup_light_img(i, j);
            else
                jjn_error_img(i, j) = 255;
                error = dup_light_img(i, j) - 255;
            end

            if i < height
                if j > 1
                    dup_light_img(i+1, j-1) = dup_light_img(i+1, j-1) + error * a;
                end
                if j > 2
                    dup_light_img(i+1, j-2) = dup_light_img(i+1, j-2) + error * b;
                end
                dup_light_img(i+1, j) = dup_light_img(i+1, j) + error * c;
                if j < width
                    dup_light_img(i+1, j+1) = dup_light_img(i+1, j+1) + error * a;
                end
                if j < width - 1
                    dup_light_img(i+1, j+2) = dup_light_img(i+1, j+2) + error * b;
                end
                if i < height - 1
                    if j > 1
                        dup_light_img(i+2, j-1) = dup_light_img(i+2, j-1) + error * d;
                    end
                    dup_light_img(i+2, j) = dup_light_img(i+2, j) + error * c;
                    if j < width
                        dup_light_img(i+2, j+1) = dup_light_img(i+2, j+1) + error * d;
                    end
                end
            end
        end
    end
end

function stucki_error_img = get_Stucki_error_image(image, height, width)
    dup_light_img = image; 
    stucki_error_img = zeros(height, width);
    
    a = 8/42;
    b = 4/42;
    c = 2/42;
    d = 1/42;
    
    for i = 1:height
        for j = 1:width
            if dup_light_img(i, j) < 128
                stucki_error_img(i, j) = 0;
                error = dup_light_img(i, j);
            else
                stucki_error_img(i, j) = 255;
                error = dup_light_img(i, j) - 255;
            end

            if i < height
                if j > 1
                    dup_light_img(i+1, j-1) = dup_light_img(i+1, j-1) + error * a;
                end
                if j > 2
                    dup_light_img(i+1, j-2) = dup_light_img(i+1, j-2) + error * b;
                end
                dup_light_img(i+1, j) = dup_light_img(i+1, j) + error * c;
                if j < width
                    dup_light_img(i+1, j+1) = dup_light_img(i+1, j+1) + error * a;
                end
                if j < width - 1
                    dup_light_img(i+1, j+2) = dup_light_img(i+1, j+2) + error * b;
                end
                if i < height - 1
                    if j > 1
                        dup_light_img(i+2, j-1) = dup_light_img(i+2, j-1) + error * d;
                    end
                    dup_light_img(i+2, j) = dup_light_img(i+2, j) + error * c;
                    if j < width
                        dup_light_img(i+2, j+1) = dup_light_img(i+2, j+1) + error * d;
                    end
                end
            end
        end
    end
end

