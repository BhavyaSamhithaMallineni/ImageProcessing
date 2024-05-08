function grayscale_img = get_grayscale(rgb_img)
     R_ch = rgb_img(:, :, 1);
     G_ch = rgb_img(:, :, 2);
     B_ch = rgb_img(:, :, 3);

     grayscale_img = 0.2989 * R_ch + 0.5870 * G_ch + 0.1140 * B_ch;
end

