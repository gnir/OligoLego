function printOPs(OligoPaints,SavePath)
prefix='OligopaintsMerged.txt'; % print order text file
outputPaints=strcat(SavePath,prefix);
fileID=fopen(outputPaints,'w');
for i=1:size(OligoPaints,1)
    fprintf(fileID,'%s\n',OligoPaints{i,1});
end
fclose(fileID);