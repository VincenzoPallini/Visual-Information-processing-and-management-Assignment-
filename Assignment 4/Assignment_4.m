close all
clear all

boxImage = imread("elephant.jpg");
sceneImage = imread("clutteredDesk.jpg");

%% Rileviamo Keypoint 

boxPoints = detectSURFFeatures(boxImage, ...
    "MetricThreshold",1000, ...
    "NumOctaves",4, ...
    NumScaleLevels=4);

scenePoints = detectSURFFeatures(sceneImage,  ...
    "MetricThreshold",1000, ...
    "NumOctaves",4, ...
    NumScaleLevels=4);


%% Calcoliamo Features dei Keypoint rilevati
[boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);

%% Match tra feature
boxPairs = matchFeatures(boxFeatures, sceneFeatures, ...
                           Method="Exhaustive", ...
                           MatchThreshold=50.0, ...  
                           MaxRatio=1, ...    
                           Metric="SAD", ...
                           Unique=true);

matchedBoxPoints = boxPoints(boxPairs(:,1),:);
matchedScenePoints = scenePoints(boxPairs(:,2),:);

% Pulizia Match points
[tform, inlierBoxPoints, inlierScenePoints] = estimateGeometricTransform(matchedBoxPoints, matchedScenePoints, 'affine');
figure(1), showMatchedFeatures(boxImage, sceneImage, inlierBoxPoints, inlierScenePoints, 'montage');



%% Prendo punti più precisi
% figure(10)
% imshow(boxImage)
% [x ,y] = ginput
% %% salvo coordinate
% coord = [x y];
% save('coordinate', 'coord');

%% Carico coordinate (calcolate precedentemente) e visualizzo segmentazione
coordinate = load("coordinate.mat");
cd = coordinate.coord;

newBoxPoly = transformPointsForward(tform, cd);
figure(2), clf, imshow(sceneImage), hold on, line(newBoxPoly(:,1), newBoxPoly(:,2), 'Color', 'y'), hold off







