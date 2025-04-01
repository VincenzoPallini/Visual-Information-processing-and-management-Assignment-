close all

% lettura delle immagini
im1 = imread("image7.jpg");
im2 = imread("image8.jpg");

% visualizzazione immagini
figure(1), imshow(im1)
figure(2), imshow(im2)

% calcolo dimensioni delle immagini
S1 = size(im1);
S2 = size(im2);

% conversione delle immagini in double
im1 = im2double(im1);
im2 = im2double(im2);

% visualizzazione dei canali RGB
figure(3)
for ch = 1:3
    subplot(1,3,ch)
    imshow(im1(:,:,ch))
end

% conversione nello spazio colore YCbCr
im1_ycbcr = rgb2ycbcr(im1);
im2_ycbcr = rgb2ycbcr(im2);

% visualizzazione dei canali YCbCr
figure(4)
for ch = 1:3
    subplot(1,3,ch)
    imshow(im1_ycbcr(:,:,ch))
end

% estrazione delle statistiche
im1_ycbcr_reshaped = reshape(im1_ycbcr, [], 3); % la fa diventare nx3
im2_ycbcr_reshaped = reshape(im2_ycbcr, [], 3);

stat_im1 = mean(im1_ycbcr_reshaped);
stat_im2 = mean(im2_ycbcr_reshaped);

im1_ycbcr_reshaped(:, 2) = im1_ycbcr_reshaped(:, 2) - stat_im1(2) + stat_im2(2);
im1_ycbcr_reshaped(:, 3) = im1_ycbcr_reshaped(:, 3) - stat_im1(3) + stat_im2(3);

% ricompongo le immagini 
im1_ycbcr = reshape(im1_ycbcr_reshaped, S1);
im2_ycbcr = reshape(im2_ycbcr_reshaped, S2);

% le ritrasformo in RGB
im1_rgb = ycbcr2rgb(im1_ycbcr);
im2_rgb = ycbcr2rgb(im2_ycbcr);

% assicura che i valori siano nell'intervallo valido [0, 1]
im1_rgb = max(min(im1_rgb, 1), 0);
im2_rgb = max(min(im2_rgb, 1), 0);

% le trasformo in uint8
im1_rgb = im2uint8(im1_rgb);
im2_rgb = im2uint8(im2_rgb);

figure(5), imshow(im1_rgb)
figure(6), imshow(im2_rgb)

% salvo il risultato su disco
imwrite(im1_rgb, 'im1_trasformata.png');
imwrite(im2_rgb, 'im2_trasformata.png');
