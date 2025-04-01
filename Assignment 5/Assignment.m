%% Preparazione delle features e labels per il training
train_list = readtable('parts_train.txt');

features_tr = [];
labels_tr = [];
for ii = 1:height(train_list) % <--- Limite fissato
    nome = [train_list.Var1{ii} '_' num2str(train_list.Var2(ii), '%0.4d')]; 
    % Lettura dell'immagine RGB
    im_rgb = imread(['lfw_funneled' filesep train_list.Var1{ii} filesep nome '.jpg']);
    im_rgb = im2double(im_rgb);
    % figure(1), clf, imshow(im_rgb)
    
    % Lettura dell'immagine dei superpixel
    % Per capire quali pixel compongono ciascun superpixel
    % Indici da 0 a N
    im_superpixel = readtable(['parts_lfw_funneled_superpixels_mat' filesep train_list.Var1{ii} filesep nome '.dat']);
    im_superpixel = table2array(im_superpixel);
    N = max(im_superpixel(:));
    % figure(2), clf, imagesc(im_superpixel)
    
    % Lettura dei label associati a ciascun superpixel
    superpixel_labels = readtable(['parts_lfw_funneled_gt' filesep train_list.Var1{ii} filesep nome '.dat']);
    superpixel_labels = table2array(superpixel_labels);
    
    % In base alle features che vogliamo estrarre valutiamo se fare reshape
    % delle immagini RGB e superpixel. Ad esempio, estraiamo la media dei canali RGB
    im_rgb = reshape(im_rgb, [], 3);
    im_superpixel = reshape(im_superpixel, [], 1);
    
    % Ciclo sui superpixel per estrarre le features
    for nsup = 0:N
        curr_label = superpixel_labels(nsup + 2);        
        labels_tr = [labels_tr; curr_label]; % Accodo al vettore delle labels
        u = find(im_superpixel == nsup);
        % Estrazione delle features: media dei canali RGB
        curr_feat = mean(im_rgb(u, :), 1); 
        features_tr = [features_tr; curr_feat]; % Accodo alla matrice delle features
    end
end

%% Preparazione delle features e labels per la validation
val_list = readtable('parts_validation.txt');

features_val = [];
labels_val = [];
for ii = 1:height(val_list)
    nome = [val_list.Var1{ii} '_' num2str(val_list.Var2(ii), '%0.4d')]; 
    % Lettura dell'immagine RGB
    im_rgb = imread(['lfw_funneled' filesep val_list.Var1{ii} filesep nome '.jpg']);
    im_rgb = im2double(im_rgb);
    
    % Lettura dell'immagine dei superpixel
    im_superpixel = readtable(['parts_lfw_funneled_superpixels_mat' filesep val_list.Var1{ii} filesep nome '.dat']);
    im_superpixel = table2array(im_superpixel);
    N = max(im_superpixel(:));
    
    % Lettura dei label associati a ciascun superpixel
    superpixel_labels = readtable(['parts_lfw_funneled_gt' filesep val_list.Var1{ii} filesep nome '.dat']);
    superpixel_labels = table2array(superpixel_labels);
    
    % Reshape delle immagini
    im_rgb = reshape(im_rgb, [], 3);
    im_superpixel = reshape(im_superpixel, [], 1);
    
    % Ciclo sui superpixel per estrarre le features
    for nsup = 0:N
        curr_label = superpixel_labels(nsup + 2);        
        labels_val = [labels_val; curr_label]; % Accodo al vettore delle labels
        u = find(im_superpixel == nsup);
        % Estrazione delle features: media dei canali RGB
        curr_feat = mean(im_rgb(u, :), 1);
        features_val = [features_val; curr_feat]; % Accodo alla matrice delle features
    end
end

%% Preparazione delle features e labels per il test
test_list = readtable('parts_test.txt');

features_test = [];
labels_test = [];
for ii = 1:height(test_list)
    nome = [test_list.Var1{ii} '_' num2str(test_list.Var2(ii), '%0.4d')]; 
    % Lettura dell'immagine RGB
    im_rgb = imread(['lfw_funneled' filesep test_list.Var1{ii} filesep nome '.jpg']);
    im_rgb = im2double(im_rgb);
    
    % Lettura dell'immagine dei superpixel
    im_superpixel = readtable(['parts_lfw_funneled_superpixels_mat' filesep test_list.Var1{ii} filesep nome '.dat']);
    im_superpixel = table2array(im_superpixel);
    N = max(im_superpixel(:));
    
    % Lettura dei label associati a ciascun superpixel
    superpixel_labels = readtable(['parts_lfw_funneled_gt' filesep test_list.Var1{ii} filesep nome '.dat']);
    superpixel_labels = table2array(superpixel_labels);
    
    % Reshape delle immagini
    im_rgb = reshape(im_rgb, [], 3);
    im_superpixel = reshape(im_superpixel, [], 1);
    
    % Ciclo sui superpixel per estrarre le features
    for nsup = 0:N
        curr_label = superpixel_labels(nsup + 2);        
        labels_test = [labels_test; curr_label]; % Accodo al vettore delle labels
        u = find(im_superpixel == nsup);
        % Estrazione delle features: media dei canali RGB
        curr_feat = mean(im_rgb(u, :), 1);
        features_test = [features_test; curr_feat]; % Accodo alla matrice delle features
    end
end

%% Training del classificatore sul training
SVMModel = fitcecoc(features_tr, labels_tr);

%% Calcolo delle predizioni del classificatore sul test
predictions = predict(SVMModel, features_test);


%% Predizioni e accuratezza
accuracy_test = mean(predict(SVMModel, features_test) == labels_test);
accuracy_val = mean(predict(SVMModel, features_val) == labels_val);

fprintf('Accuratezza sul test set: %.4f\n', accuracy_test);
fprintf('Accuratezza sul validation set: %.4f\n', accuracy_val);

