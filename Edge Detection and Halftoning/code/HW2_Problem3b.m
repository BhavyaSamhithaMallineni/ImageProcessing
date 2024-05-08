%  EE569 Homework Assignment #2
% Date  : February 19, 2024
% Name  : Bhavya Samhitha Mallineni
% USCID : 6580252371
% email : mallinen@usc.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 3b : Colour Halftoning 
% Implementation :MBVQ Error Diffusion
% M-file: HW2_Problem3b
% Input Image File : Bird.raw
% Output Image File : MBVQ_Bird.raw
% Open Source Code used : readraw.m and writeraw.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


filename = 'Bird.raw';
width = 500;
height = 375;

rgb_img = readraw(filename, height, width, false);

R_ch = rgb_img(:, :, 1);
G_ch = rgb_img(:, :, 2);
B_ch = rgb_img(:, :, 3);
Rch_padded = get_padded_image(R_ch, height, width);
Gch_padded = get_padded_image(G_ch, height, width);
Bch_padded = get_padded_image(B_ch, height, width);


mbvq_red_img = zeros(height, width);
mbvq_green_img = zeros(height, width);
mbvq_blue_img = zeros(height, width);

diff=(1/16)*[0 0 0;0 0 7;3 5 1];
diffu_inv_=(1/16)*[0 0 0;7 0 0;1 5 3];




for i = 2:height+1 
    if(mod(i,2) == 0)
        for j = 2:width +1
            mbvq_value = get_mbvq(R_ch(i-1,j-1), G_ch(i-1,j-1), B_ch(i-1,j-1));
            vertex = get_vertex(mbvq_value, Rch_padded(i,j) ./ 255, Gch_padded(i,j) ./ 255, Bch_padded(i,j) ./ 255);
            [quant_error_red,quant_error_green,quant_error_blue]= get_Error(vertex);

            error_red = Rch_padded(i,j) - quant_error_red;
            error_green = Gch_padded(i,j) - quant_error_green;
            error_blue = Bch_padded(i,j) - quant_error_blue;

            mbvq_red_img(i-1, j-1) = quant_error_red;
            mbvq_green_img(i-1, j-1) = quant_error_green;
            mbvq_blue_img(i-1, j-1) = quant_error_blue;

            for k = i-1 : i+1
                for l = j-1 : j+1
                    Rch_padded(k, l) = Rch_padded(k, l) + error_red * diff(k-i+2, l-j+2);
                    Gch_padded(k, l) = Gch_padded(k, l) + error_green * diff(k-i+2, l-j+2);
                    Bch_padded(k, l) = Bch_padded(k, l) + error_blue * diff(k-i+2, l-j+2);
                end
            end
        end
    elseif(mod(i,2) == 1)
        for j = width+1:-1:2
            mbvq_value = mbvq_return(R_ch(i-1,j-1), G_ch(i-1,j-1), B_ch(i-1,j-1));
            vertex = getNearestVertex(mbvq_value, Rch_padded(i,j) ./ 255, Gch_padded(i,j) ./ 255, Bch_padded(i,j) ./ 255);
            [quant_error_red,quant_error_green,quant_error_blue]= get_Error(vertex);
            

            error_red = Rch_padded(i,j) - quant_error_red;
            error_green = Gch_padded(i,j) - quant_error_green;
            error_blue = Bch_padded(i,j) - quant_error_blue;

            mbvq_red_img(i-1, j-1) = quant_error_red;
            mbvq_green_img(i-1, j-1) = quant_error_green;
            mbvq_blue_img(i-1, j-1) = quant_error_blue;

            for k = i-1 : i+1
                for l = j-1 : j+1
                    Rch_padded(k, l) = Rch_padded(k, l) + error_red * diffu_inv_(k-i+2, l-j+2);
                    Gch_padded(k, l) = Gch_padded(k, l) + error_green * diffu_inv_(k-i+2, l-j+2);
                    Bch_padded(k, l) = Bch_padded(k, l) + error_blue * diffu_inv_(k-i+2, l-j+2);
                end
            end
        end
    end
end

mbvq_bird(:,:,1) = mbvq_red_img;
mbvq_bird(:,:,2) = mbvq_green_img;
mbvq_bird(:,:,3) = mbvq_blue_img;

figure(10);
imshow(mbvq_bird/255);
title('MBVQ Image');

filename = 'MBVQ_Bird.raw';
writeraw(mbvq_bird, filename, false);

function [red_error, green_error, blue_error] = get_Error(vertex)
    % Initialize variables
    red_error = 0;
    green_error = 0;
    blue_error = 0;

    if (vertex == 7)
        red_error = 255;
        green_error = 255;
        blue_error = 0;
    elseif (vertex == 8)
        red_error = 255;
        green_error = 255;
        blue_error = 255;
    elseif (vertex == 6) 
        red_error = 0;
        green_error = 255;
        blue_error = 255;
    elseif (vertex == 5) 
        red_error = 255;
        green_error = 0;
        blue_error = 255;
    elseif (vertex == 4) 
        red_error = 0;
        green_error = 255;
        blue_error = 0;
    elseif (vertex == 3) 
        red_error = 255;
        green_error = 0;
        blue_error = 0;
    elseif (vertex == 2) 
        red_error = 0;
        green_error = 0;
        blue_error = 255;
    elseif (vertex == 1)
        red_error = 0;
        green_error = 0;
        blue_error = 0;
    end
end

function vertex = get_vertex(mbvq, red, green, blue)
    % Color Codes:
    % 1 - Black, 2 - Blue, 3 - Red, 4 - Green, 5 - Magenta,
    % 6 - Cyan, 7 - Yellow, 8 - White
    
    if (mbvq == 'CMYW')
        vertex = 8; 
        if (blue < 0.5)
            if (blue <= red)
                if (blue <= green)
                    vertex = 7; 
                end
            end
        end
        if (green < 0.5)
            if (green <= blue)
                if (green <= red)
                    vertex = 5; 
                end
            end
        end
        if (red < 0.5)
            if (red <= blue)
                if (red <= green)
                    vertex = 6; 
                end
            end
        end
    end

    if (mbvq == 'MYGC')
        vertex = 5; 
        if (green >= blue)
            if (red >= blue)
                if (red >= 0.5)
                    vertex = 7; 
                else
                    vertex = 4; 
                end
            end
        end
        if (green >= red)
            if (blue >= red)
                if (blue >= 0.5)
                    vertex = 6; 
                else
                    vertex = 4; 
                end
            end
        end
    end

    if (mbvq == 'RGMY')
        if (blue > 0.5)
            if (red > 0.5)
                if (blue >= green)
                    vertex = 5; 
                else
                    vertex = 7; 
                end
            else
                if (green > blue + red)
                    vertex = 4; 
                else
                    vertex = 5; 
                end
            end
        else
            if (red >= 0.5)
                if (green >= 0.5)
                    vertex = 7; 
                else
                    vertex = 3; 
                end
            else
                if (red >= green)
                    vertex = 3; 
                else
                    vertex = 4; 
                end
            end
        end
    end

    if (mbvq == 'KRGB')
        vertex = 1; 
        if (blue > 0.5)
            if (blue >= red)
                if (blue >= green)
                    vertex = 2; 
                end
            end
        end
        if (green > 0.5)
            if (green >= blue)
                if (green >= red)
                    vertex = 4; 
                end
            end
        end
        if (red > 0.5)
            if (red >= blue)
                if (red >= green)
                    vertex = 3; 
                end
            end
        end
    end

    if (mbvq == 'RGBM')
        vertex = 4; 
        if (red > green)
            if (red >= blue)
                if (blue < 0.5)
                    vertex = 3; 
                else
                    vertex = 5; 
                end
            end
        end
        if (blue > green)
            if (blue >= red)
                if (red < 0.5)
                    vertex = 2; 
                else
                    vertex = 5; 
                end
            end
        end
    end

    if (mbvq == 'CMGB')
        if (blue > 0.5)
            if (red > 0.5)
                if (green >= red)
                    vertex = 6; 
                else
                    vertex = 5; 
                end
            else
                if (green > 0.5)
                    vertex = 6; 
                else
                    vertex = 2; 
                end
            end
        else
            if (red > 0.5)
                if (red - green + blue >= 0.5)
                    vertex = 5; 
                else
                    vertex = 4; 
                end
            else
                if (green >= blue)
                    vertex = 4; 
                else
                    vertex = 2; 
                end
            end
        end
    end
end

function mbvq_value= get_mbvq(red,green,blue)

if ((red+green)>255)
   if ((green+blue)>255)
       if((red+green+blue)>510)
           mbvq_value = 'CMYW';
       else
       mbvq_value = 'MYGC';
       end
   else
mbvq_value = 'RGMY';
   end       
elseif (~((green+blue)>255))
if (~((red+green+blue)>255))
 mbvq_value = 'KRGB';
else
 mbvq_value = 'RGBM';
end
else
 mbvq_value = 'CMGB';           
end
end