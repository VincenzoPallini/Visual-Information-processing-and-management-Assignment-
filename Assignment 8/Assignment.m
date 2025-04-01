clear all
clc

net=alexnet;
sz=net.Layers(1).InputSize;

%% Taglio dei layer
layersTransfer=net.Layers(1:end-3); 
layersTransfer=freezeWeights(layersTransfer);

%% Aggiungiamo i nostri layer Fully Connected
numClasses = 10;

layers=[
    layersTransfer
    fullyConnectedLayer(numClasses, 'WeightLearnRateFactor',20,...
    'BiasLearnRateFactor', 20) 
    softmaxLayer
    classificationLayer];

%% Preparazione dati
imds=imageDatastore('image.orig/');
labels=[];

for ii=1:size(imds.Files,1)
    name=imds.Files{ii,1};
    [p,n,ex]=fileparts(name);
    class=floor(str2double(n)/100);
    labels=[labels; class];
end
labels=categorical(labels);
imds=imageDatastore('image.orig/','labels',labels);

%% Split Train Test
[imdsTrain, imdsTest] = splitEachLabel(imds, 0.7, 'randomized');

%% Data Augmentation (perchè il nostro dataset è piccolo)

pixelRange = [-10,10];
imageAugmenter = imageDataAugmenter(...
    'RandXReflection',true,...
    'RandXTranslation',pixelRange,...
    'RandYTranslation',pixelRange);

augimdsTrain=augmentedImageDatastore(sz(1:2), imdsTrain, 'DataAugmentation', imageAugmenter);
augimdsTest=augmentedImageDatastore(sz(1:2), imdsTest);


%% Configurazione Fine Tuning

options = trainingOptions('sgdm',...
    'MiniBatchSize',10,...
    'MaxEpochs',6,...
    'InitialLearnRate',1e-4,...
    'Shuffle','every-epoch',...
    'ValidationData',augimdsTest,...
    'ValidationFrequency',3,...
    'Verbose',false,...
    'Plots','training-progress');


%% Training della Rete
netTransfer = trainNetwork(augimdsTrain, layers, options);

%% Test sul test set
[lab_pred_te, scores] = classify(netTransfer, augimdsTest);

%% Performance
acc=numel(find(lab_pred_te==imdsTest.Labels))/numel(lab_pred_te)


%% Commenti finali
% Modificando gli iperparametri di "trainingOptions" non ho ottenuto alcun miglioramento significativo nelle performance.

% Aumentado il range di "pixelRange" per la data augmentation invece ho ottenuto un netto miglioramento delle performance.
