im = imread('underexposed.jpg');
figure(1), clf, imshow(im), title('Immagine Originale')

%% Gamma correction globale
im = im2double(im);

gamma=0.4;
im1 = im.^gamma;

gamma=4;
im2 = im.^gamma;

figure(2),clf
subplot(1,2,1), imshow(im1), title('Gamma = 0.4')
subplot(1,2,2), imshow(im2), title('Gamma = 4')

% Converto in YCbCr
Ycbcr = rgb2ycbcr(im);

% Estraggo il canale Y
canaleY = double(Ycbcr(:,:,1)) * 255;

% Calcolo la maschera invertendo il canale Y
Mask = 255 - canaleY;

% Filtro Gaussiano
sigma = 15;
Mask_blurred_gaussian = imgaussfilt(Mask, sigma);

Exponent_gaussian = 2 .^ ((128 - Mask_blurred_gaussian) / 128);
nuovoCanaleY_gaussian = 255 * (canaleY/255) .^ Exponent_gaussian;

% Normalizzo i valori tra 0 e 1
nuovoCanaleY_gaussian = nuovoCanaleY_gaussian / 255;

% Sovrascrivo il canale Y con il nuovo canale
Ycbcr_gaussian = Ycbcr;
Ycbcr_gaussian(:,:,1) = nuovoCanaleY_gaussian;

% Riconverto in RGB
imc_gaussian = ycbcr2rgb(Ycbcr_gaussian);
figure, imshow(imc_gaussian), title('Gamma Correction Adattativa con Filtro Gaussiano')

% Filtro Bilaterale
degreeOfSmoothing = 0.05; 
spatialSigma = 15;
Mask_blurred_bilateral = imbilatfilt(Mask, degreeOfSmoothing, spatialSigma);

Exponent_bilateral = 2 .^ ((128 - Mask_blurred_bilateral) / 128);
nuovoCanaleY_bilateral = 255 * (canaleY/255) .^ Exponent_bilateral;

% Normalizzo i valori tra 0 e 1
nuovoCanaleY_bilateral = nuovoCanaleY_bilateral / 255;

% Sovrascrivo il canale Y con il nuovo canale
Ycbcr_bilateral = Ycbcr;
Ycbcr_bilateral(:,:,1) = nuovoCanaleY_bilateral;

% Riconverto in RGB
imc_bilateral = ycbcr2rgb(Ycbcr_bilateral);
figure, imshow(imc_bilateral), title('Gamma Correction Adattativa con Filtro Bilaterale')

imwrite(imc_gaussian, 'output_gaussian.jpg');
imwrite(imc_bilateral, 'output_bilateral.jpg');
