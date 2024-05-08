%  EE569 Homework Assignment #2
% Date  : February 19, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 2a : Digital Halftoning Dithering 
% Implementation : Dithering Matrix 
% M-file: HW2_Problem2a3
% Input Image File : LightHouse.raw
% Output Image File : DMI2_LightHouse.raw, DMI8_LightHouse.raw, DMI32_LightHouse.raw
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


filename = 'LightHouse.raw';
width = 750;
height = 500;

light_img = readraw(filename, height, width, true);

dither_imgI2=zeros(height, width);
dither_imgI8=zeros(height, width);
dither_imgI32=zeros(height, width);


I2 = getBayerMatrix(2);
I8= getBayerMatrix(8);
I32= getBayerMatrix(32);

T2 = getThresholdMatrix(I2);
T8= getThresholdMatrix(I8);
T32= getThresholdMatrix(I32);

for i = 1:height
    for j = 1:width
        if light_img(i, j) <= T2(mod(i,2)+1, mod(j,2)+1)
            dither_imgI2(i, j) = 0;
        else
            dither_imgI2(i, j) = 255;
        end
        
        if light_img(i, j) <= T8(mod(i,8)+1, mod(j,8)+1)
            dither_imgI8(i, j) = 0;
        else
            dither_imgI8(i, j) = 255;
        end
        
        if light_img(i, j) <= T32(mod(i,32)+1, mod(j,32)+1)
            dither_imgI32(i, j) = 0;
        else
            dither_imgI32(i, j) = 255;
        end
    end
end


figure;
imshow(dither_imgI2/255);
title('Halftoned Image  using I2');

figure;
imshow(dither_imgI8/255);
title('Halftoned Image  using I8');

figure;
imshow(dither_imgI32/255);
title('Halftoned Image  using I32');

filename = 'DMI2_LightHouse.raw';
writeraw(dither_imgI2, filename, true);

filename = 'DMI8_LightHouse.raw';
writeraw(dither_imgI8, filename, true);

filename = 'DMI32_LightHouse.raw';
writeraw(dither_imgI32, filename, true);



function I2n = getBayerMatrix(size)
    if size == 2
        I2n = [1, 2; 3, 0];
        return;
    end
    In = getBayerMatrix(size / 2);
    In4 = 4 * In;
    rc1 = In4 + 1;
    rc2 = In4 + 2;
    rc3 = In4 + 3;
    rc4 = In4;
    I2n = [rc1, rc2; rc3, rc4];
end

function Tn = getThresholdMatrix(In)
    scaling = 255 / (size(In, 1) * size(In, 2));
    Tn = round((In + 0.5) * scaling);
end
