% Si consiglia di eseguire lo script a partire dallo step 7 "Caricamento dati Training + Test + Classificatore"
% poiché gli step precedenti riguardano il calcolo delle feature per il classificatore e hanno tempi di esecuzione abbastanza elevati.

% Nello step 7 vengono caricati il modello già addestrato e le feature di training previamente calcolate con i seguenti parametri:
% featStep = 10; imsize = 400; Nim4Training = 90; K = 200.



% Se si desidera eseguire tutto il codice dall'inizio, commentare lo step 7 e assicurarsi di aggiungere il dataset "image.orig".


%% 1) Creazione Griglia
clear all

disp('Creazione griglia')
pointPosition = [];
featStep = 10; %TDB
imsize = 400;  %TDB
tic
for ii=featStep:featStep:imsize-featStep
    for jj=featStep:featStep:imsize-featStep
        pointPosition =[pointPosition; ii jj]; 
    end
end
toc

%% 2) Estrazione feature per le imagini di Training
disp('Estrazione features')
Nim4Training=90; %TDB  
features=[];
labels=[];

tic
for class=0:9 
    for nimage=0:Nim4Training-1 
        im =im2double(imread(['image.orig/' num2str(100*class+nimage) '.jpg']));
        im = imresize(im, [imsize imsize]);
        im = rgb2gray(im);
        [imfeatures, ~] = extractFeatures(im, pointPosition, 'Method','SURF');
        features= [features; imfeatures];
        labels = [labels; repmat(class, size(imfeatures,1),1) repmat(nimage, size(imfeatures,1),1)];      
    end
end
toc

%% 3) Creazione vocabolario
disp('Correazione vocabolario (con kmeans)')
K=200; %TDB
tic
[IDX, C]=kmeans(features, K);
toc

%% 4) Istrogrammi Training
disp('Rappresentazione BOW del training')
BOW_tr=[];
labels_tr=[];
tic
for class=0:9
    for nimage=0:Nim4Training-1
        u=find(labels(:,1)== class & labels(:,2)==nimage);  
        imfeaturesIDX=IDX(u);
        H=hist(imfeaturesIDX, 1:K);
        H=H./sum(H); 
        BOW_tr=[BOW_tr; H];
        labels_tr=[labels_tr; class];
    end
end
toc


%% 5) Istogrammi test
disp('Rappresentazione BOW del Test')
BOW_te=[];
labels_te=[];
tic
for class=0:9 
    for nimage=Nim4Training:99 

        im =im2double(imread(['image.orig/' num2str(100*class+nimage) '.jpg']));
        im = imresize(im, [imsize imsize]);
        im = rgb2gray(im);
        [imfeatures, ~] = extractFeatures(im, pointPosition, 'Method','SURF');  
        D=pdist2(imfeatures, C);
        [~, words]=min(D, [], 2);    
        H=hist(words, 1:K); 
        H=H./sum(H);
        BOW_te=[BOW_te; H];
        labels_te=[labels_te; class];
    end
end
toc


%% 6) Classificatore 
classifier = fitcnet(BOW_tr, labels_tr, "OptimizeHyperparameters","all");


%% 7) Caricamento dati Training + Test + Classificatore
load("dati.mat");


%% 8) Predizione test set
disp('Classificazione test set')
predicted_class=predict(classifier,BOW_te);


%% 9) Misurazione performance
disp('Accuracy')
CM=confusionmat(labels_te, predicted_class);
CM=CM ./repmat(sum(CM,2),1,size(CM,2));
CM
accuracy=mean(diag(CM))


%% Commento finale
% Con i parametri scelti, utilizzando il classificatore (rete neurale FNN), si è raggiunto l'accuratezza: 74%.



