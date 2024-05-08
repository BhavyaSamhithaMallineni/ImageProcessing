%  EE569 Homework Assignment #3
% Date  : March 10, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 3 : Morphological Processing 
% Implementation : Shape detection and Counting 
% M-file: HW3_Problem3b
% Input Image File : board.raw
% Open Source Code used : readraw.m and writeraw.m and bwmorph.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = 'board.raw';

height = 768;
width= 768;

board_grayscale_image = readraw(filename, height, width, true);

figure;
imshow(board_grayscale_image/255);

board_bin = get_binary_image(board_grayscale_image,height,width);

invertedImage = ~board_bin;

figure;
imshow(invertedImage);
title('Inverted Image (Black Holes to White Holes)');

shrunkImage = bwmorph(invertedImage, 'shrink',inf);
figure;
imshow(shrunkImage);
title('shrunk ');


num_dots=get_dot_count(shrunkImage);
disp(['Number of black dots: ', num2str(num_dots)]);
fill_black_dots= coverDots(shrunkImage);

figure;
imshow(fill_black_dots);


 se = strel('disk', 1);
 dilatedImage = imdilate(board_bin, se);
 filledHoles = imfill(dilatedImage, 'holes');
 isolatedHoles = filledHoles & ~board_bin; 

 figure;
 imshow(filledHoles);
 shrunk_white_Image = bwmorph(filledHoles, 'shrink',inf);
 figure;
 imshow(shrunk_white_Image);
 title('shrunk ');

 num_white_dots=get_dot_count(shrunk_white_Image);
 disp(['Number of white objects: ', num2str(num_white_dots)]);

 [labels, numObjects] = bwlabel(filledHoles);

num_rect = 0;
num_circles = 0;

for obj = 1:numObjects
    object = (labels == obj);
    area = sum(object(:));

    objectEroded = imerode(object, [1 1 1; 1 1 1; 1 1 1]);
    perimeterImage = object & ~objectEroded;
    perimeter = sum(perimeterImage(:));

    [rows, cols] = find(object);
    minRow = min(rows); maxRow = max(rows);
    minCol = min(cols); maxCol = max(cols);
    boundingBoxWidth = maxCol - minCol + 1;
    boundingBoxHeight = maxRow - minRow + 1;

    aspectRatio = boundingBoxWidth / boundingBoxHeight;

    circularity = 4 * pi * area / (perimeter^2);
    
    aspectRatioThreshold = [0.8, 1.25];
    circularityThreshold = 0.6;
    
    if aspectRatio >= aspectRatioThreshold(1) && aspectRatio <= aspectRatioThreshold(2)
        num_rect = num_rect + 1;
    elseif circularity > circularityThreshold
        num_circles = num_circles + 1;
    end
end

% Display results
fprintf('Number of Rectangles: %d\n', num_rect);
fprintf('Number of Circles: %d\n', num_circles);



%%%%%%%%%%%%
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

function numDots = get_dot_count(image)
    [rows, cols] = size(image);
    numDots = 0;

    for i = 2:(rows-1)
        for j = 2:(cols-1)

            block = image(i-1:i+1, j-1:j+1);
            if get_if_isDot(block)
                numDots = numDots + 1;
            end
        end
    end
end

function isDot = get_if_isDot(block)

    dotPattern = [0 0 0; 0 1 0; 0 0 0];

    isDot = isequal(block, dotPattern);
end

function coveredImage = coverDots(image)
    [rows, cols] = size(image);
    coveredImage = image; 
    for i = 2:(rows-1)
        for j = 2:(cols-1)
            block = coveredImage(i-1:i+1, j-1:j+1);
            if get_if_isDot(block)
                coveredImage(i, j) = 0;
            end
        end
    end
end






