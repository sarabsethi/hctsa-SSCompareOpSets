clear all;

load('HCTSA_N.mat');

% Load in operation set files - only important data is operation names
fName1 = 'alexs_features.mat';
fName2 = 'auto_chosen_ops_26_new.mat';
opFile1 = load(fName1);
opFile2 = load(fName2);

fullSetNames1 = {opFile1.ops.Name};
fullSetNames2 = {opFile2.autoChosenOps.Name};
allOpNames = {Operations.Name};

% Match the operations to those calculated in the data matrix
opIdxs1 = find(ismember(allOpNames, fullSetNames1));
opIdxs2 = find(ismember(allOpNames, fullSetNames2));

% Create reduced data matrices using operation sets to be compared
redMat1 = TS_DataMat(:,opIdxs1);
redMat2 = TS_DataMat(:,opIdxs2);

% Create labels from the operation names
opNames1 = {Operations(opIdxs1).Name};
opNames2 = {Operations(opIdxs2).Name};
opLabels1 = strcat('',opNames1,'\it A');
opLabels2 = strcat('',opNames2,'\it S');
allLabels = {opLabels1{:} , opLabels2{:}};
allLabels = strrep(allLabels,'_','\_');

% Calculate pairwise distances for the union of reduced sets of operations
fullRedMat = [redMat1 , redMat2];
D = pdist(fullRedMat','correlation');
D = 1 - abs(1 - D);

% Cluster similar operations below a correlation distance threshold
[D_clust,clusters,ord] = BF_ClusterDown(D,'whatDistance',...
    'general','clusterThreshold',0.2,'linkageMeth','average');
colors = BF_getcmap('dark2',9);

% Color groups of operations which are highly correlated
for i = 1:length(clusters)
    mems = cell2mat(clusters(i));
    if length(mems) > 1
    color = colors(mod(i,length(colors)-1)+1,:);
    colorStr = ['\color[rgb]{',num2str(color(1)),' ',num2str(color(2)),' ',num2str(color(3)),'}'];
    
    for j = 1:length(mems)
        newStr = strcat('\bf ',colorStr,allLabels(mems(j)));
        allLabels(mems(j)) = newStr;
    end
    end
end
orderedNames = allLabels(ord);
set(gca,'Ytick',1:length(allLabels),'YtickLabel',orderedNames);

fID = fopen('comparedOpCorrelations.txt','w');

% Extract the rows from set 1 and columns from set 2 to compare how each
% operation in one set correlates to each operation in the other
sqrD = squareform(D);
D_red = sqrD(1:length(opIdxs1),length(opIdxs1)+1:size(sqrD,2));

opKeys1 = {Operations(opIdxs1).Keywords};
opKeys2 = {Operations(opIdxs2).Keywords};

fprintf(fID,'Comparing 2 sets of operations\nSet1 (n = %i): %s \n\nSet2 (n = %i): %s\n\n',...
    length(opNames1),strjoin(opNames1,','),length(opNames2),strjoin(opNames2,','));
for i = 1:size(D_red,1)
   % Pick a row - corresponds to an operation from set 1
   D_row = D_red(i,:);
   fprintf(fID,'Op %i : %s (%s)\n',i,cell2mat(opNames1(i)),cell2mat(opKeys1(i)));
   
   % Order operations from set 2 in descending correlation order
   [sortedD,sortIdx] = sort(D_row);
   sortedNames = opNames2(sortIdx);
   sortedKeys = opKeys2(sortIdx);
   
   % Print best correlated operations from set2
   for j = 1:min(length(sortedD),5)
      fprintf(fID,'%.3f - %s (%s)\n',sortedD(j),cell2mat(sortedNames(j)),cell2mat(sortedKeys(j)));
   end
   fprintf(fID,'\n');
end
