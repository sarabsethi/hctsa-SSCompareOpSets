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

% opNames1 = {Operations(opIdxs1).Name};
% opNames2 = {Operations(opIdxs2).Name};
% 
% opKeys1 = {Operations(opIdxs1).Keywords};
% opKeys2 = {Operations(opIdxs2).Keywords};
% 
% fID = fopen('comparedOpCorrelations.txt','w');
% 
% fprintf(fID,'Comparing 2 sets of operations\nSet1 (n = %i): %s \n\nSet2 (n = %i): %s\n\n',...
%     length(opNames1),strjoin(opNames1,','),length(opNames2),strjoin(opNames2,','));
% for i = 1:size(D,1)
%    % Pick a row - corresponds to an operation from set 1
%    D_row = D(i,:);
%    fprintf(fID,'Op %i : %s (%s)\n',i,cell2mat(opNames1(i)),cell2mat(opKeys1(i)));
%    
%    % Order operations from set 2 in descending correlation order
%    [sortedD,sortIdx] = sort(D_row);
%    sortedNames = opNames2(sortIdx);
%    sortedKeys = opKeys2(sortIdx);
%    
%    % Print best correlated operations from set2
%    for j = 1:min(length(sortedD),5)
%       fprintf(fID,'%.3f - %s (%s)\n',sortedD(j),cell2mat(sortedNames(j)),cell2mat(sortedKeys(j)));
%    end
%    fprintf(fID,'\n');
% end
