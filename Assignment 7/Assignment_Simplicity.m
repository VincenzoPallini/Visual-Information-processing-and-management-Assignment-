%% Caricamento del modello e analisi della rete
net = alexnet;
analyzeNetwork(net);

%% Dimensione input e definizione layer
sz = net.Layers(1).InputSize; 
layers = {'conv2', 'relu4', 'relu7'}; % Layer scelti per estrarre le feature

indir = 'image.orig/'; 
time_per_layer = zeros(1, numel(layers)); 

Nim4tr = 70; % Numero di immagini per classe nel training set

%% Loop sui diversi layer
for layer_idx = 1:numel(layers)
    layer = layers{layer_idx};
    disp(['Estrazione feature dal layer: ' layer]);

    %% Estrazione feature sul training set
    feat_tr = [];
    labels_tr = [];
    tic;
    for class = 0:9
        for nimage = 0:Nim4tr-1
            im = double(imread([indir num2str(100 * class + nimage) '.jpg']));
            im = imresize(im, sz(1:2));
            feat_tmp = activations(net, im, layer, 'OutputAs', 'rows');
            feat_tr = [feat_tr; feat_tmp];
        end
        labels_tr = [labels_tr; class * ones(Nim4tr, 1)];
    end
    time_per_layer(layer_idx) = toc;

    %% Estrazione feature sul test set
    feat_te = [];
    labels_te = [];
    tic;
    for class = 0:9
        for nimage = Nim4tr:99
            im = double(imread([indir num2str(100 * class + nimage) '.jpg']));
            im = imresize(im, sz(1:2));
            feat_tmp = activations(net, im, layer, 'OutputAs', 'rows');
            feat_te = [feat_te; feat_tmp];
        end
        labels_te = [labels_te; class * ones(100 - Nim4tr, 1)];
    end
    toc;

    %% Normalizzazione delle feature
    feat_tr = feat_tr ./ sqrt(sum(feat_tr.^2, 2));
    feat_te = feat_te ./ sqrt(sum(feat_te.^2, 2));

    %% Classificazione con 1-NN
    D = pdist2(feat_te, feat_tr);
    [~, idx_pred_te] = min(D, [], 2);
    lab_pred_te = labels_tr(idx_pred_te);
    acc = numel(find(lab_pred_te == labels_te)) / numel(labels_te);

    %% Risultati
    disp(['Accuratezza con il layer ' layer ': ' num2str(acc * 100) '%']);
end

%% Confronto tempi di estrazione
disp('Tempi di estrazione per layer:');
disp(array2table(time_per_layer, 'VariableNames', layers));
