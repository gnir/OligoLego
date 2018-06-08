function Unstable_RcO = OligoRCHybe(Streets_seq,NumOfStarnds,Spath,ORCSavePath)
%% Ensuring stable oligo-RC complex for hybe

FCon=1e-6; % i sequence concentration in M
RCon=1e-6; % j sequence concentration in M
if FCon~=RCon
    errordlg('Error: The code is not valid when using different primer concentrations. Contact Guy to fix this error');
end % if FCon~=RCon

prefix='NuDimer';
FullPath=strcat(Spath,'/Scratch/',prefix,'.in');
ConPath=strcat(Spath,'/Scratch/',prefix,'.con');
NUPACKInputPath=strcat(Spath,'/Scratch/',prefix);
fileID=fopen(ConPath,'w');
fprintf(fileID,'%e\n%e\n',FCon,RCon);
fclose(fileID);
ComplexesHybe=['complexes -T 47 -material dna -sodium 0.39 -magnesium 0 ', NUPACKInputPath];
Concentrations=['concentrations ',NUPACKInputPath];

StabThr=0.01;
flag=0;
Unstable_RcO=zeros(size(Streets_seq,1),size(Streets_seq,2));
h=waitbar(0,'Checking oligo-RC duplex hybe stabilization, please wait');
steps=size(Streets_seq,2);
for i=1:steps
    fileID=fopen(FullPath,'w');
    fprintf(fileID,'%d\n',NumOfStarnds);
    fprintf(fileID,'%s\n',Streets_seq{1,i});
    fprintf(fileID,'%s\n',ReverseComplement(Streets_seq{1,i},1));
    fprintf(fileID,'%d\n',NumOfStarnds);
    fclose(fileID);
    [statusCompRCOligo,CompRC2] = unix(ComplexesHybe);
    [statusConcRCOligo,ConcRC2] = unix(Concentrations);
    Eq_ConRCOligo=load([NUPACKInputPath,'.eq']);
    flag=0;
    for k=1:size(Eq_ConRCOligo,1)
        % Find duplex coefficients.
        if (Eq_ConRCOligo(k,2)==1 && Eq_ConRCOligo(k,3)==1) && flag==0
            Dup_Stability=Eq_ConRCOligo(k,5)/FCon; % Here I assume that FCON=RCon.
            if Dup_Stability < StabThr
                Unstable_RcO(i)=1;
                flag=1;
            end % if Dup_Stability >= StabThr
        end % if (Eq_Con(i,2)==1 && Eq_Con(i,3)==1) || (Eq_Con(i,2)==2 && Eq_Con(i,3)==0)...
    end % for k=1:size(Eq_Con,1)
    waitbar(i/steps);
end % for i=1:size(Streets_seq,2)
close(h);
save(ORCSavePath);