clear all;

load('HCTSA_N.mat');

% Load in operation set files - only important data is operation IDs
fName1 = 'auto_chosen_ops_26.mat';
fName2 = 'auto_chosen_ops_43.mat';
opFile1 = load(fName1);
opFile2 = load(fName2);

ids1 = [opFile1.autoChosenOps.ID];
ids2 = [opFile2.autoChosenOps.ID];

fullSetIds = [Operations.ID];

% Match the operations to those calculated in the data matrix
opIdxs1 = find(ismember(fullSetIds, ids1));
opIdxs2 = find(ismember(fullSetIds, ids2));

% Create reduced data matrices using operation sets to be compared
redMat1 = TS_DataMat(:,opIdxs1);
redMat2 = TS_DataMat(:,opIdxs2);
opNames1 = strcat('',{Operations(opIdxs1).Name},'\it A');
opNames2 = strcat('', {Operations(opIdxs2).Name},'\it B');

allNames = {opNames1{:} , opNames2{:}};
allNames = strrep(allNames,'_','\_');
fullRedMat = [redMat1 , redMat2];

D = pdist(fullRedMat','correlation');
D = 1 - abs(1 - D);
[D_clust,clusters,ord] = BF_ClusterDown(D,'whatDistance',...
    'general','clusterThreshold',0.2,'linkageMeth','average');

colors = BF_getcmap('dark2',9);
for i = 1:length(clusters)
    mems = cell2mat(clusters(i));
    if length(mems) > 1
    color = colors(datasample(1:length(colors),1),:);
    colorStr = ['\color[rgb]{',num2str(color(1)),' ',num2str(color(2)),' ',num2str(color(3)),'}'];
    
    for j = 1:length(mems)
        newStr = strcat('\bf ',colorStr,allNames(mems(j)));
        allNames(mems(j)) = newStr;
    end
    end
end
orderedNames = allNames(ord);
set(gca,'Ytick',1:length(allNames),'YtickLabel',orderedNames);
% colormap(BF_getcmap('redyellowblue',10));
