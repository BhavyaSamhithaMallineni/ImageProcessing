%  EE569 Homework Assignment #3
% Date  : March 10, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 3 : Morphological Processing 
% Implementation : Thinning
% M-file: HW3_Problem3a
% Input Image File : flower.raw, jar.raw, spring.raw
% Output Image File : thinned_flower.raw, thinned_jar.raw and
% thinned_spring.raw
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename_flower = 'flower.raw';
filename_jar = 'jar.raw';
filename_spring = 'spring.raw';

f_height = 247;
f_width= 247;
js_height= 252;
js_width = 252;

flower_gray_image = readraw(filename_flower, f_height, f_width, true);
jar_gray_image = readraw(filename_jar, js_height, js_width, true);
spring_gray_image = readraw(filename_spring, js_height ,js_width, true);

% figure;
% imshow(flower_gray_image/255);
% title('Flower Original Picture');
% 
% figure;
% imshow(jar_gray_image/255);
% title('Jar Original Picture');
% 
% figure;
% imshow(spring_gray_image/255);
% title('Spring Original Picture');


%%%%%%%% Converting the grayscale to binary images %%%%%%%%%%%%%%%%%

flower_bin = get_binary_image(flower_gray_image,f_height,f_width);
jar_bin = get_binary_image(jar_gray_image, js_height,js_width );
spring_bin = get_binary_image(spring_gray_image, js_height,js_width );

 figure;
 imshow(flower_bin);
 title('Flower Binary Image');

iterations = 0; 
count = 1; 
thinned_flower_bin = flower_bin;

while count ~= 0
    [mask, thinned_flower_bin, count] = morphological(thinned_flower_bin, f_height, f_width); 
    iterations = iterations + 1; 

    if iterations == 20

        figure;
        imshow(thinned_flower_bin);
        title(['Flower Binary Image After ', num2str(iterations), ' Iterations']);
    end
end

disp(['Iterations required for convergence: ', num2str(iterations)]);



figure;
imshow(thinned_flower_bin);
title('Flower Binary Image After Thinning');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
imshow(jar_bin);
title('Jar Binary Image');

iterations_jar = 0;
count_jar = 1; 
thinned_jar_bin = jar_bin;

while count_jar ~= 0
    [mask, thinned_jar_bin, count] = morphological(thinned_jar_bin, js_height, js_width); 
    iterations_jar = iterations_jar + 1; 


    if iterations_jar == 20

        figure;
        imshow(thinned_jar_bin);
        title(['Jar Binary Image After ', num2str(iterations_jar), ' Iterations']);
    elseif iterations_jar == 30

        imshow(thinned_jar_bin);
        title(['Jar Binary Image After ', num2str(iterations_jar), ' Iterations']);
    end
end

disp(['Iterations required for convergence (Jar): ', num2str(iterations_jar)]);


figure;
imshow(thinned_jar_bin);
title('Jar Binary Image After Thinning');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
imshow(spring_bin);
title('Spring Binary Image');

iterations_spring = 0; 
count_spring = 1; 
thinned_spring_bin = spring_bin;

while count_spring ~= 0
    [mask, thinned_spring_bin, count] = morphological(thinned_spring_bin, js_height, js_width); 
    iterations_spring = iterations_spring + 1; 
    
   
    if iterations_spring == 20
        
        figure;
        imshow(thinned_spring_bin);
        title(['Spring Binary Image After ', num2str(iterations_spring), ' Iterations']);
     elseif iterations_spring == 30
     
         imshow(thinned_spring_bin);
        title(['Spring Binary Image After ', num2str(iterations_spring), ' Iterations']);
    end

end

disp(['Iterations required for convergence (Spring): ', num2str(iterations_spring)]);

figure;
imshow(thinned_spring_bin);
title('Spring Binary Image After Thinning');

filename = 'thinned_flower.raw';
writeraw(thinned_flower_bin, filename, true);
filename = 'thinned_jar.raw';
writeraw(thinned_jar_bin, filename, true);
filename = 'thinned_spring.raw';
writeraw(thinned_spring_bin, filename, true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mask,thinning_image, count] = morphological(binary_image, height, width)
    mask = zeros(height, width);
    thinning_image = binary_image; 
    count = 0; 

    padded_image = get_padded_image(thinning_image, height, width);

    for i = 1:height
        for j = 1:width
            block = padded_image(i:i+2, j:j+2);
            pattern = get_pattern(block);
            hit = get_conditional(pattern);

            
            if hit
                mask(i, j) = 1;
            else
                mask(i, j) = 0;
            end
        end
    end
    
    padded_mask = get_padded_image(mask, height, width);

    for i = 1:height
        for j = 1:width
            if mask(i, j) == 1
                block = padded_mask(i:i+2, j:j+2);
                pattern = get_pattern(block);
                hit = get_unconditional(pattern);

                if ~hit
                    if thinning_image(i, j) == 1 
                        count = count + 1; 
                        thinning_image(i, j) = 0;
                    end
                end
            end
        end
    end
end
function pattern = get_pattern(block)
    pattern = 0;
    for k = 1:3
        for l = 1:3
            pattern = bitshift(pattern, 1);
            if block(k, l) == 1
                pattern = bitor(pattern, 1);
            end
        end
    end
    pattern = dec2bin(pattern, 9);
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

function padded_image = get_padded_image(image, height, width)

    padded_image=zeros(height+2,width +2);
    for i = 1: height 
        for j= 1:width
            padded_image(i+1,j+1) = image(i,j);
        end
    end

end
function hit = get_conditional(pattern)
    patterns = [ ...
        bin2dec('000110100'), bin2dec('000010110'), bin2dec('000010011'), bin2dec('000011001'), ...
        bin2dec('110011000'), bin2dec('010011001'), bin2dec('011110000'), bin2dec('001011010'), ...
        bin2dec('011011000'), bin2dec('110110000'), bin2dec('000110110'), bin2dec('000011011'), ...
        bin2dec('110011001'), bin2dec('011110100'), ...
        bin2dec('011011011'), bin2dec('111111000'), bin2dec('110110110'), bin2dec('000111111'), ...
        bin2dec('111011011'), bin2dec('011011111'), bin2dec('111111100'), bin2dec('111111001'), ...
        bin2dec('111110110'), bin2dec('110110111'), bin2dec('100111111'), bin2dec('001111111'), ...
        bin2dec('111011111'), bin2dec('111111101'), bin2dec('111110111'), bin2dec('101111111'), ...
        bin2dec('001011001'), bin2dec('111010000'), bin2dec('100110100'), bin2dec('000010111'), ...
        bin2dec('111011000'), bin2dec('011011001'), bin2dec('111110000'), bin2dec('110110100'), ...
        bin2dec('100110110'), bin2dec('000110111'), bin2dec('000011111'), bin2dec('001011011'), ...
        bin2dec('111011001'), bin2dec('111110100'), bin2dec('100110111'), bin2dec('001011111') ...
    ];

    patternDec = bin2dec(pattern);
    hit = any(patterns == patternDec);
end
function hit = get_unconditional(pattern)

    ST_no_D = [ ...
        bin2dec('001010000'), bin2dec('100010000'), bin2dec('000010010'), bin2dec('000011000'), ...
        bin2dec('001011000'), bin2dec('011010000'), bin2dec('110010000'), bin2dec('100110000'), ...
        bin2dec('000110100'), bin2dec('000010110'), bin2dec('000010011'), bin2dec('000011001'), ...
        bin2dec('011110000'), bin2dec('110011000'), bin2dec('010011001'), bin2dec('001011010'), ...
        bin2dec('011011100'), bin2dec('001011100'), bin2dec('011010100'), bin2dec('110110001'), ...
        bin2dec('100110001'), bin2dec('110010001'), bin2dec('001110110'), bin2dec('001110100'), ...
        bin2dec('001010110'), bin2dec('100011011'), bin2dec('100011001'), bin2dec('100010011') ...
    ];
    ST_with_D = [ ...
        bin2dec('110110000'), bin2dec('000011011'), ...
        bin2dec('010111000'), bin2dec('010111000'), bin2dec('000111010'), bin2dec('000111010'), ...
        bin2dec('010110010'), bin2dec('010110010'), bin2dec('010011010'), bin2dec('010011010'), ...
        bin2dec('101010001'), bin2dec('101010010'), bin2dec('101010011'), bin2dec('101010100'), ...
        bin2dec('101010101'), bin2dec('101010110'), bin2dec('101010111'), bin2dec('100010101'), ...
        bin2dec('100011100'), bin2dec('100011101'), bin2dec('101010100'), bin2dec('101010101'), ...
        bin2dec('101011100'), bin2dec('101011101'), bin2dec('001010101'), bin2dec('010010101'), ...
        bin2dec('011010101'), bin2dec('100010101'), bin2dec('101010101'), bin2dec('110010101'), ...
        bin2dec('111010101'), bin2dec('001010101'), bin2dec('001110001'), bin2dec('001110101'), ...
        bin2dec('101010001'), bin2dec('101010101'), bin2dec('101110001'), bin2dec('101110101'), ...
        bin2dec('010011100'), bin2dec('010110001'), bin2dec('001110010'), bin2dec('100011010') ...
    ];
    ST_mask = [ ...
        bin2dec('110110000'), bin2dec('000011011'), ...
        bin2dec('011111011'), bin2dec('110111110'), bin2dec('110111110'), bin2dec('011111011'), ...
        bin2dec('010111111'), bin2dec('111111010'), bin2dec('111111010'), bin2dec('010111111'), ...
        bin2dec('101010111'), bin2dec('101010111'), bin2dec('101010111'), bin2dec('101010111'), ...
        bin2dec('101010111'), bin2dec('101010111'), bin2dec('101010111'), bin2dec('101011111'), ...
        bin2dec('101011111'), bin2dec('101011111'), bin2dec('101011111'), bin2dec('101011111'), ...
        bin2dec('101011111'), bin2dec('101011111'), bin2dec('111010101'), bin2dec('111010101'), ...
        bin2dec('111010101'), bin2dec('111010101'), bin2dec('111010101'), bin2dec('111010101'), ...
        bin2dec('111010101'), bin2dec('101110101'), bin2dec('101110101'), bin2dec('101110101'), ...
        bin2dec('101110101'), bin2dec('101110101'), bin2dec('101110101'), bin2dec('101110101'), ...
        bin2dec('011111110'), bin2dec('110111011'), bin2dec('011111110'), bin2dec('110111011') ...
    ];

    decimal = bin2dec(num2str(pattern));
    hit = any(ST_no_D == decimal);
    if hit
        return;
    end
    for i = 1:length(ST_with_D)
        check = bitand(decimal, ST_mask(i));
        if check == ST_with_D(i)
            hit = true;
            return;
        end
    end

    hit = false;
end

