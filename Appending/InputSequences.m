%% Load sequences
SeqPath='/Users/guynir/Dropbox/Ting_Wu_Lab/StreetsBrian/101_streets_bcs.txt';
SeqInput=Loadingtxt(SeqPath);
for i=1:size(SeqInput,1)
    Streets(i,:)=cell2str(SeqInput{i,3});
end % for i=1:size(SeqInput,1)
for i=1:size(Streets,1)
    temp(i,:)=Streets(i,3:end-3);
end % for i=1:size(Streets,1)
Streets=temp; clear temp;
%% Check toeholds
[statusNu,Spath]=unix('echo $NUPACKHOME');
prefix='Toehold';
FullPath=strcat(Spath,'/Scratch/',prefix,'.fold');
StreetsLength=20;
toesLength=size(Streets,2);
steps=size(Streets,1);
Toes=strings(size(Streets,1),1);
h = waitbar(0,'Designing toeholds');
for i=1:steps
    Toes(i,:)=DesignToehold(FullPath,'seq');
    waitbar(i/steps);
end % for i=1:size(Streets,1)
close(h)
Streets=strings(size(Toes,1),StreetsLength);
for i=1:steps
    Streets(i,1)=Toes{i,1}(toesLength-StreetsLength+1:end);
end % for i=1:steps