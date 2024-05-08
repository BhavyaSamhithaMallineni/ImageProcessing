%  EE569 Homework Assignment #3
% Date  : March 10, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 3 : Morphological Processing 
% Implementation : Obect Segmentation and Analysis
% M-file: HW3_Problem3c
% Input Image File : beans.raw
% Open Source Code used : edge.m and readraw.m and writeraw.m and bwlabel.m
% and bwareaopen.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = 'beans.raw';

height = 82;
width= 494;


beans_image = readraw(filename, height, width, false);

figure;
imshow(beans_image/255);

 grayscale = get_grayscale(beans_image/255);

binary_edge = edge(grayscale,'canny');
figure;
imshow(binary_edge);

se = strel('disk', 5);
closed_binary = imclose(binary_edge, se);
figure;
imshow(closed_binary);

binaryFiltered = bwareaopen(closed_binary, 50);
imshow(binaryFiltered);

[labels, num_beans] = bwlabel(binaryFiltered);
fprintf('Number of beans: %d\n', num_beans);

bean_area = zeros(1, num_beans); 
for i = 1:num_beans
    bean_area(i) = sum(labels(:) == i);
end


[sortedAreas, sortOrder] = sort(bean_area, 'ascend');


bean_area = zeros(1, num_beans);

% Calculate the area for each bean
for i = 1:num_beans
    bean_area(i) = sum(labels(:) == i); 
end
hold on;
imshow(beans_image);


for i = 1:num_beans
    
    [row, col] = find(labels == i);
    centroidRow = round(mean(row));
    centroidCol = round(mean(col));

    areaText = sprintf('%d', bean_area(i));
    
    text(centroidCol, centroidRow, areaText, 'Color', 'black', 'FontSize', 12);
end


  function grayscale_img = get_grayscale(rgb_img)
     R_ch = rgb_img(:, :, 1);
     G_ch = rgb_img(:, :, 2);
     B_ch = rgb_img(:, :, 3);

     grayscale_img = 0.2989 * R_ch + 0.5870 * G_ch + 0.1140 * B_ch;
 end
function binary_image = get_binary_image(gray_image, height, width)
    Fmax = max(gray_image(:));

    T = round(0.5*Fmax);
    binary_image = zeros(height, width);
    for i=1:height
        for j=1:width
            if gray_image(i,j) <= T
                binary_image(i,j) = 0;
            else
                binary_image(i,j) = 1;
            end
        end
    end

end