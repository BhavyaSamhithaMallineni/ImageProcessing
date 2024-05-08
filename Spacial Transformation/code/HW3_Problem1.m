
%  EE569 Homework Assignment #3
% Date  : March 10, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 1a : Geometric Warping
% Implementation : Thinning
% M-file: HW3_Problem1
% Input Image File : cat.raw, dog.raw
% Output Image File : frwd_warped_cat.raw, frwd_warped_dog.raw,
% reconstructed_cat.raw, reconstructed_dog.raw
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cat_filename = 'cat.raw';
dog_filename = 'dog.raw';
width = 328;
height = 328;


%%%% Cat Warping %%%%%%%
cat_image = readraw(cat_filename, height, width, false);
figure;
imshow(cat_image/255);
title('CAT Original Image');

frwd_warped_cat=zeros(height,width,3);
 frwd_warped_cat= Get_Warped_Image(cat_image, height, width);
figure;
imshow(frwd_warped_cat/255);
title('Cat Warped Image');
filename = 'frwd_warped_cat.raw';
writeraw(frwd_warped_cat, filename, false);

reconstructed_cat = Get_Reconstructed_Image(frwd_warped_cat,height, width);
figure;
interpolated_cat= Get_Interpolated_Image(reconstructed_cat, height, width)
figure;

imshow(reconstructed_cat/255);
title('Reconstructed Cat');

imshow(interpolated_cat/255);
title('ReStored Cat ');


filename = 'reconstructed_cat.raw';
writeraw(interpolated_cat, filename, false);

%%%% Dog Warping %%%%%%%
dog_image = readraw(dog_filename, height, width, false);
figure;
imshow(dog_image/255);
title('Dog Original Image');

frwd_warped_dog=zeros(height,width,3);
frwd_warped_dog= Get_Warped_Image(dog_image, height, width);

figure;
imshow(frwd_warped_dog/255);
title('Dog Warped Image');

filename = 'frwd_warped_dog.raw';
writeraw(frwd_warped_dog, filename, false);

reconstructed_dog = Get_Reconstructed_Image(frwd_warped_dog,height, width);
figure;
imshow(reconstructed_dog/255);
title('Reconstructed Dog ');

interpolated_dog= Get_Interpolated_Image(reconstructed_dog, height, width)
figure;
imshow(interpolated_dog/255);
title('ReStored Dog ');






filename = 'reconstructed_dog.raw';
writeraw(interpolated_dog, filename, false);


%%%%%%%%%%%% functions %%%%%%%%%%%%%%%%%%%

function warped_image = Get_Warped_Image(raw_img, height, width)

warped_image = zeros(height, width, 3);

%%%%% Top Warping %%%
top_triangle = [1, -163, 163, (-163)^2, (-163*163), 163^2;
                1, -163/2, 163/2, (-163/2)^2, (-163*163/4), (163/2)^2;
                1, 0, 0, (0)^2, (0*0), 0^2;
                1, 164, 163, (164)^2, (164*163), 163^2;
                1, 164/2, 163/2, (164/2)^2, (164*163/4), (163/2)^2;
                1, 0, 163, (0)^2, (0*163), 163^2];

top_x = [-163, -163/2, 0, 164, 164/2, 0];
top_y = [163, 163/2, 0, 163, 163/2, 100];

top_a = pinv(top_triangle) * top_x';
top_b = pinv(top_triangle) * top_y';
top_inv = pinv([top_a, top_b]);
topxy_ = [top_x; top_y];
topy_ = topxy_ * inv(top_triangle');

for i = 1:164
    for j = i:328-i
        x = j - 163;
        y = 327 - i - 164;
        point = [1; x; y; x^2; x*y; y^2];
        warp = topy_ * point;
        u = warp(1);
        v = warp(2);
        r = round(u) + 163;
        s = 327 - 164 - round(v);
        if r < 1 || s < 1 || r > height || s > width
            continue;
        end
        warped_image(s, r, :) = raw_img(i, j, :);
    end
end

%%%%% Left Warping %%%
left_triangle = [1, -163, 163, (-163)^2, (-163*163), 163^2;
                 1, -163/2, 163/2, (-163/2)^2, (-163*163/4), (163/2)^2;
                 1, 0, 0, (0)^2, (0*0), 0^2;
                 1, -163, -164, (-163)^2, ((-163)*(-164)), (-164)^2;
                 1, -163/2, -164/2, (-163/2)^2, (163*164/4), (-164/2)^2;
                 1, -163, 0, (-163)^2, (0*163), 0^2];

left_x = [-163, -163/2, 0, -163, -163/2, -100];
left_y = [163, 163/2, 0, -164, -164/2, 0];

left_a = pinv(left_triangle) * left_x';
left_b = pinv(left_triangle) * left_y';
leftxy_ = [left_x; left_y];
lefty_ = leftxy_ * inv(left_triangle');

for i = 1:164
    for j = i:328-i
        x = i - 163;
        y = 327 - j - 164;
        point = [1; x; y; x^2; x*y; y^2];
        warp = lefty_ * point;
        u = warp(1);
        v = warp(2);
        r = round(u) + 163;
        s = 327 - 164 - round(v);
        if r < 1 || s < 1 || r > height || s > width
            continue;
        end
        warped_image(s, r, :) = raw_img(j, i, :);
    end
end

%%%%% Bottom Warping %%%
bottom_triangle = [1, -163, -164, (-163)^2, ((-163)*(-164)), (-164)^2;
                    1, -163/2, -164/2, (-163/2)^2, ((-163)*(-164)/4), (-164/2)^2;
                    1, 0, 0, (0)^2, (0*0), 0^2;
                    1, 164, -164, (164)^2, ((164)*(-164)), (-164)^2;
                    1, 164/2, -164/2, (164/2)^2, ((164)*(-164)/4), (-164/2)^2;
                    1, 0, -164, (0)^2, ((0)*(-164)), (-164)^2];

bottom_x = [-163, -163/2, 0, 164, 164/2, 0];
bottom_y = [-164, -164/2, 0, -164, -164/2, -100];

bottom_a = pinv(bottom_triangle) * bottom_x';
bottom_b = pinv(bottom_triangle) * bottom_y';
bottomxy_ = [bottom_x; bottom_y];
bottomy_ = bottomxy_ * inv(bottom_triangle');

for i = 327:-1:163
    for j = 327-i:i
        x = j - 163;
        y = 327 - i - 164;
        point = [1; x; y; x^2; x*y; y^2];
        warp = bottomy_ * point;
        u = warp(1);
        v = warp(2);
        r = round(u) + 163;
        s = 327 - 164 - round(v);
        if r < 1 || s < 1 || r > height || s > width
            continue;
        end
        warped_image(s, r, :) = raw_img(i, j, :);
    end
end

%%%%% Right Warping %%%
right_triangle = [1, 164, -164, (164)^2, ((164)*(-164)), (-164)^2;
                   1, 164/2, -164/2, (164/2)^2, ((164)*(-164)/4), (-164/2)^2;
                   1, 0, 0, (0)^2, (0*0), 0^2;
                   1, 164, 163, (164)^2, ((164)*(163)), (163)^2;
                   1, 164/2, 163/2, (164/2)^2, ((164)*(163)/4), (163/2)^2;
                   1, 164, 0, (164)^2, ((164)*(-0)), (0)^2];

right_x = [164, 164/2, 0, 164, 164/2, 101];
right_y = [-164, -164/2, 0, 163, 163/2, 0];

right_a = pinv(right_triangle) * right_x';
right_b = pinv(right_triangle) * right_y';
rightxy_ = [right_x; right_y];
righty_ = rightxy_ * inv(right_triangle');

for i = 327:-1:163
    for j = 327-i:i
        x = i - 163;
        y = 327 - j - 164;
        point = [1; x; y; x^2; x*y; y^2];
        warp = righty_ * point;
        u = warp(1);
        v = warp(2);
        r = round(u) + 163;
        s = 327 - 164 - round(v);
        if r < 1 || s < 1 || r > height || s > width
            continue;
        end
        warped_image(s, r, :) = raw_img(j, i, :);
    end
end

end
%%%%%%%%%%%%%%%%%
function warped_image = Get_Reconstructed_Image(raw_img, height, width)

warped_image = zeros(height, width, 3);

%%%%% Top Warping %%%
top_triangle = [1, -163, 163, (-163)^2, (-163*163), 163^2;
                1, -163/2, 163/2, (-163/2)^2, (-163*163/4), (163/2)^2;
                1, 0, 0, (0)^2, (0*0), 0^2;
                1, 164, 163, (164)^2, (164*163), 163^2;
                1, 164/2, 163/2, (164/2)^2, (164*163/4), (163/2)^2;
                1, 0, 163, (0)^2, (0*163), 163^2];

top_x = [-163, -163/2, 0, 164, 164/2, 0];
top_y = [163, 163/2, 0, 163, 163/2, 328];

top_a = pinv(top_triangle) * top_x';
top_b = pinv(top_triangle) * top_y';
top_inv = pinv([top_a, top_b]);
topxy_ = [top_x; top_y];
topy_ = topxy_ * inv(top_triangle');

for i = 1:164
    for j = i:328-i
        x = j - 163;
        y = 327 - i - 164;
        point = [1; x; y; x^2; x*y; y^2];
        warp = topy_ * point;
        u = warp(1);
        v = warp(2);
        r = round(u) + 163;
        s = 327 - 164 - round(v);
        if r < 1 || s < 1 || r > height || s > width
            continue;
        end
        warped_image(s, r, :) = raw_img(i, j, :);
    end
end

%%%%% Left Warping %%%
left_triangle = [1, -163, 163, (-163)^2, (-163*163), 163^2;
                 1, -163/2, 163/2, (-163/2)^2, (-163*163/4), (163/2)^2;
                 1, 0, 0, (0)^2, (0*0), 0^2;
                 1, -163, -164, (-163)^2, ((-163)*(-164)), (-164)^2;
                 1, -163/2, -164/2, (-163/2)^2, (163*164/4), (-164/2)^2;
                 1, -163, 0, (-163)^2, (0*163), 0^2];

left_x = [-163, -163/2, 0, -163, -163/2, -328];
left_y = [163, 163/2, 0, -164, -164/2, 0];

left_a = pinv(left_triangle) * left_x';
left_b = pinv(left_triangle) * left_y';
leftxy_ = [left_x; left_y];
lefty_ = leftxy_ * inv(left_triangle');

for i = 1:164
    for j = i:328-i
        x = i - 163;
        y = 327 - j - 164;
        point = [1; x; y; x^2; x*y; y^2];
        warp = lefty_ * point;
        u = warp(1);
        v = warp(2);
        r = round(u) + 163;
        s = 327 - 164 - round(v);
        if r < 1 || s < 1 || r > height || s > width
            continue;
        end
        warped_image(s, r, :) = raw_img(j, i, :);
    end
end

%%%%% Bottom Warping %%%
bottom_triangle = [1, -163, -164, (-163)^2, ((-163)*(-164)), (-164)^2;
                    1, -163/2, -164/2, (-163/2)^2, ((-163)*(-164)/4), (-164/2)^2;
                    1, 0, 0, (0)^2, (0*0), 0^2;
                    1, 164, -164, (164)^2, ((164)*(-164)), (-164)^2;
                    1, 164/2, -164/2, (164/2)^2, ((164)*(-164)/4), (-164/2)^2;
                    1, 0, -164, (0)^2, ((0)*(-164)), (-164)^2];

bottom_x = [-163, -163/2, 0, 164, 164/2, 0];
bottom_y = [-164, -164/2, 0, -164, -164/2, -328];

bottom_a = pinv(bottom_triangle) * bottom_x';
bottom_b = pinv(bottom_triangle) * bottom_y';
bottomxy_ = [bottom_x; bottom_y];
bottomy_ = bottomxy_ * inv(bottom_triangle');

for i = 327:-1:163
    for j = 327-i:i
        x = j - 163;
        y = 327 - i - 164;
        point = [1; x; y; x^2; x*y; y^2];
        warp = bottomy_ * point;
        u = warp(1);
        v = warp(2);
        r = round(u) + 163;
        s = 327 - 164 - round(v);
        if r < 1 || s < 1 || r > height || s > width
            continue;
        end
        warped_image(s, r, :) = raw_img(i, j, :);
    end
end

%%%%% Right Warping %%%
right_triangle = [1, 164, -164, (164)^2, ((164)*(-164)), (-164)^2;
                   1, 164/2, -164/2, (164/2)^2, ((164)*(-164)/4), (-164/2)^2;
                   1, 0, 0, (0)^2, (0*0), 0^2;
                   1, 164, 163, (164)^2, ((164)*(163)), (163)^2;
                   1, 164/2, 163/2, (164/2)^2, ((164)*(163)/4), (163/2)^2;
                   1, 164, 0, (164)^2, ((164)*(-0)), (0)^2];

right_x = [164, 164/2, 0, 164, 164/2, 328];
right_y = [-164, -164/2, 0, 163, 163/2, 0];

right_a = pinv(right_triangle) * right_x';
right_b = pinv(right_triangle) * right_y';
rightxy_ = [right_x; right_y];
righty_ = rightxy_ * inv(right_triangle');

for i = 327:-1:163
    for j = 327-i:i
        x = i - 163;
        y = 327 - j - 164;
        point = [1; x; y; x^2; x*y; y^2];
        warp = righty_ * point;
        u = warp(1);
        v = warp(2);
        r = round(u) + 163;
        s = 327 - 164 - round(v);
        if r < 1 || s < 1 || r > height || s > width
            continue;
        end
        warped_image(s, r, :) = raw_img(j, i, :);
    end
end

end

function interpolated_image = Get_Interpolated_Image(reconstructed_dog, height, width)
    interpolated_image = zeros(height, width, 3);
    for c = 1:3
        interpolated_point = reconstructed_dog(:,:,c);
        [rows, cols, values] = find(interpolated_point);
        if length(values) < 4 
            interpolated_image(:,:,c) = interpolated_point;
            continue;
        end

        [interpolated_x, interpolated_y] = meshgrid(1:width, 1:height);

        interpolated_channel = griddata(cols, rows, values, interpolated_x, interpolated_y, 'linear');

        zero_indices = interpolated_point == 0;
        interpolated_point(zero_indices) = interpolated_channel(zero_indices);

        interpolated_image(:,:,c) = interpolated_point;
    end
end

