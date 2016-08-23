clear all;

text = fileread('features.txt');

lines = strsplit(text,'\n');

for i = 1:length(lines)
   items = strsplit(cell2mat(lines(i)),'\t');
   ops(i).opName = cell2mat(items(1));
   ops(i).ID = str2num(cell2mat(items(2)));
end

save('alexs_features.mat','ops');
