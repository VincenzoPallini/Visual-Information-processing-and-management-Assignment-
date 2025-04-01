% lettura delle immagini
im1 = im2double(imread('godzilla_1.jpg'));
im2 = im2double(imread('godzilla_2.jpg'));

% ridimensionamento delle immagini per avere le stesse dimensioni
im2 = imresize(im2, [size(im1, 1), size(im1, 2)]);

% conversione nello spazio colore YCbCr
im1_ycbcr = rgb2ycbcr(im1);
im2_ycbcr = rgb2ycbcr(im2);

% Estrai i singoli canali Cb, Cr
Cb1 = im1_ycbcr(:,:,2); Cr1 = im1_ycbcr(:,:,3);
Cb2 = im2_ycbcr(:,:,2); Cr2 = im2_ycbcr(:,:,3);

% Combina i canali Cb, Cr con una media ponderata tra im1 e im2
alpha = 0.6; % Peso 
Cb_mix = (1 - alpha) * Cb1 + alpha * Cb2;
Cr_mix = (1 - alpha) * Cr1 + alpha * Cr2;

% Ricompone l'immagine YCbCr con i canali misti
im1_ycbcr(:,:,2) = Cb_mix;
im1_ycbcr(:,:,3) = Cr_mix;

% Trasforma di nuovo in RGB
im1_rgb = ycbcr2rgb(im1_ycbcr);

% Assicura che i valori siano nell'intervallo valido [0, 1]
im1_rgb = max(min(im1_rgb, 1), 0);

% Creazione del "modello" del colore background per due aree
% Crop per il verde scuro 
crop_dark = imcrop(im1_rgb, [317.5 59.5 63 33]);
crop_dark = reshape(crop_dark, [], 3);
modello_dark = unique(crop_dark, 'rows');

% Crop per il verde chiaro 
crop_light = imcrop(im1_rgb, [399.5 515.5 30 22]);
crop_light = reshape(crop_light, [], 3);
modello_light = unique(crop_light, 'rows');

% Dimensioni dell'immagine
S = size(im1_rgb);
im1_reshaped = reshape(im1_rgb, [], 3);

% Inizializzazione delle maschere
M_dark = zeros(size(im1_reshaped, 1), 1);
M_light = zeros(size(im1_reshaped, 1), 1);
T = 0.11; % Aumentata la soglia per decidere se background o foreground

% Maschera per il verde scuro
tic
for ii = 1:size(im1_reshaped, 1)
    d = repmat(im1_reshaped(ii, :), size(modello_dark, 1), 1) - modello_dark;
    d = sqrt(sum(d.^2, 2));
    if min(d) < T
        M_dark(ii) = 1;
    end
end
toc

% Maschera per il verde chiaro
tic
for ii = 1:size(im1_reshaped, 1)
    d = repmat(im1_reshaped(ii, :), size(modello_light, 1), 1) - modello_light;
    d = sqrt(sum(d.^2, 2));
    if min(d) < T
        M_light(ii) = 1;
    end
end
toc

% Unione delle maschere
M = max(M_dark, M_light);

M_combined = reshape(M, S(1), S(2));
M_rgb = repmat(M_combined, 1, 1, 3); 

% Visualizzazione delle maschere
M_dark = reshape(M_dark, S(1), S(2));
M_light = reshape(M_light, S(1), S(2));

figure(1), imshow(M_dark), title('Maschera Verde Scuro')
figure(2), imshow(M_light), title('Maschera Verde Chiaro')
figure(3), imshow(M_combined), title('Maschera Combinata')

% Risultato finale
risultato = im2 .* M_rgb + im1_rgb .* (1 - M_rgb);
figure(6), imshow(risultato), title('Risultato')
