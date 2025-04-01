%% Caricamento del modello e analisi della rete 
net = alexnet;
analyzeNetwork(net);

%% Dimensione input e definizione layer
sz = net.Layers(1).InputSize; 
layers = {'conv2', 'relu4', 'relu7'}; % Layer scelti per estrarre le feature

indir = 'Micro_Organism/'; 
time_per_layer = zeros(1, numel(layers)); 

categories = {'Amoeba', 'Euglena', 'Hydra', 'Paramecium', 'Rod_bacteria', 'Spherical_bacteria', 'Spiral_bacteria', 'Yeast'};

%% Funzione per validare immagini
function im = validateImage(image_path, sz)
    try
        im = imread(image_path);
        if size(im, 3) ~= 3
            im = cat(3, im, im, im); 
        end
        im = imresize(im, sz(1:2));
    catch
        im = [];
    end
end

%% Loop sui diversi layer
for layer_idx = 1:numel(layers)
    layer = layers{layer_idx};
    disp(['Estrazione feature dal layer: ' layer]);

    %% Estrazione feature sul training set
    feat_tr = [];
    labels_tr = [];
    tic;
    for class_idx = 1:numel(categories)
        class_name = categories{class_idx};
        image_files = dir([indir class_name '/*.jpg']);
        num_images = numel(image_files);
        Nim4tr = round(0.8 * num_images); % 80% per il training
        for nimage = 1:Nim4tr
            image_path = [image_files(nimage).folder '/' image_files(nimage).name];
            im = validateImage(image_path, sz);
            if isempty(im)
                warning(['Immagine non valida: ' image_path]);
                continue;
            end
            feat_tmp = activations(net, double(im), layer, 'OutputAs', 'rows');
            feat_tr = [feat_tr; feat_tmp];
        end
        labels_tr = [labels_tr; class_idx * ones(size(feat_tr, 1) - size(labels_tr, 1), 1)];
    end
    time_per_layer(layer_idx) = toc;

    %% Estrazione feature sul test set
    feat_te = [];
    labels_te = [];
    tic;
    for class_idx = 1:numel(categories)
        class_name = categories{class_idx};
        image_files = dir([indir class_name '/*.jpg']);
        num_images = numel(image_files);
        Nim4tr = round(0.8 * num_images); % 80% per il training
        Nim4te = num_images - Nim4tr; % 20% per il test
        for nimage = Nim4tr+1:num_images
            image_path = [image_files(nimage).folder '/' image_files(nimage).name];
            im = validateImage(image_path, sz);
            if isempty(im)
                warning(['Immagine non valida: ' image_path]);
                continue;
            end
            feat_tmp = activations(net, double(im), layer, 'OutputAs', 'rows');
            feat_te = [feat_te; feat_tmp];
        end
        labels_te = [labels_te; class_idx * ones(size(feat_te, 1) - size(labels_te, 1), 1)];
    end
    toc;

    %% Normalizzazione delle feature
    if ~isempty(feat_tr) && ~isempty(feat_te)
        feat_tr = feat_tr ./ sqrt(sum(feat_tr.^2, 2));
        feat_te = feat_te ./ sqrt(sum(feat_te.^2, 2));

        %% Classificazione con 1-NN
        D = pdist2(feat_te, feat_tr);
        [~, idx_pred_te] = min(D, [], 2);
        lab_pred_te = labels_tr(idx_pred_te);
        acc = numel(find(lab_pred_te == labels_te)) / numel(labels_te);

        %% Risultati
        disp(['Accuratezza con il layer ' layer ': ' num2str(acc * 100) '%']);
    else
        disp(['Nessuna feature valida estratta per il layer ' layer]);
    end
end

%% Confronto tempi di estrazione
disp('Tempi di estrazione per layer:');
disp(array2table(time_per_layer, 'VariableNames', layers));
