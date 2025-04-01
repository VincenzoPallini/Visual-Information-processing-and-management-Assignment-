close all

%% lettura immagine
im = imread('IMG_1295ss.tiff');
figure(1),imshow(im)

% conversione immagine in double nel range [0 1]
im = im2double(im);

% Auto Exposure (finto)
im = im./max(im(:));
figure(1),clf,imshow(im)

% demosaiking
% Configurazione del sensore (Bayer pattern)
% R G R G
% G B G B
% R G R G
% G B G B
% Implementazione dell'interpolazione
im2 = zeros(size(im,1), size(im,2), 3);

% Itera su ogni pixel esclusi i bordi
for r = 2:size(im,1)-1
    for c = 2:size(im,2)-1
        if mod(r, 2) == 1 && mod(c, 2) == 1
            % Pixel R (rosso) nelle righe dispari e colonne dispari
            im2(r, c, 1) = im(r, c); % Assegna il canale rosso
            % Interpola G e B dai vicini
            im2(r, c, 2) = (im(r-1, c) + im(r+1, c) + im(r, c-1) + im(r, c+1)) / 4; % Verde
            im2(r, c, 3) = (im(r-1, c-1) + im(r-1, c+1) + im(r+1, c-1) + im(r+1, c+1)) / 4; % Blu

        elseif mod(r, 2) == 0 && mod(c, 2) == 0
            % Pixel B (blu) nelle righe pari e colonne pari
            im2(r, c, 3) = im(r, c); % Assegna il canale blu
            % Interpola G e R dai vicini
            im2(r, c, 2) = (im(r-1, c) + im(r+1, c) + im(r, c-1) + im(r, c+1)) / 4; % Verde
            im2(r, c, 1) = (im(r-1, c-1) + im(r-1, c+1) + im(r+1, c-1) + im(r+1, c+1)) / 4; % Rosso

        elseif mod(r, 2) == 1 && mod(c, 2) == 0
            % Pixel G (verde) nelle righe dispari e colonne pari
            im2(r, c, 2) = im(r, c); % Assegna il canale verde
            % Interpola R e B dai vicini
            im2(r, c, 1) = (im(r, c-1) + im(r, c+1)) / 2; % Rosso
            im2(r, c, 3) = (im(r-1, c) + im(r+1, c)) / 2; % Blu

        elseif mod(r, 2) == 0 && mod(c, 2) == 1
            % Pixel G (verde) nelle righe pari e colonne dispari
            im2(r, c, 2) = im(r, c); % Assegna il canale verde
            % Interpola R e B dai vicini
            im2(r, c, 1) = (im(r-1, c) + im(r+1, c)) / 2; % Rosso
            im2(r, c, 3) = (im(r, c-1) + im(r, c+1)) / 2; % Blu
        end
    end
end

figure(2), imshow(im2) 

% AWB - Auto White Balance
awb_method = 'WhitePoint'; 

S = size(im2);
im_reshaped = reshape(im2, [], 3);

switch awb_method
    case 'GrayWorld'
        % Gray World Algorithm
        mean_values = mean(im_reshaped);
        coeff = [0.5, 0.5, 0.5] ./ mean_values;
    case 'WhitePatch'
        % WhitePatch Algorithm
        max_values = max(im_reshaped);
        coeff = [1, 1, 1] ./ max_values;
    case 'WhitePoint'
        % WhitePoint Algorithm
        reference_white = [1, 1, 1];
        mean_values = mean(im_reshaped);
        coeff = reference_white ./ mean_values;
    otherwise
        error('Metodo AWB non riconosciuto.');
end

% Applica i coefficienti di bilanciamento del bianco
im_awb = im_reshaped * diag(coeff);

% Clipping dei valori per mantenerli nel range [0, 1]
im_awb = min(max(im_awb, 0), 1);

im_awb = reshape(im_awb, S);
figure(3), imshow(im_awb), title(['AWB con metodo: ', awb_method])

% Aggiorna l'immagine per le prossime operazioni
im2 = im_awb;

% image enhancement
Sfactor = 1; % modificare fattore per aumento saturazione
im2 = rgb2hsv(im2); % conversione nello spazio HSV
im2(:,:,2) = im2(:,:,2) * Sfactor; % modifica della saturazione
im2 = hsv2rgb(im2); % riconversione in RGB

% compressione e salvataggio
imwrite(im2uint8(im2),'immagine_raw_to_srgb.jpg')
