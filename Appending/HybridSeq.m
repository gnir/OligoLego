function [flag,Ratio] = HybridSeq(UniversalMS,BridgeMS)
% This function checks that the hybrid sequence stability with a bridge is
% at least 10 times lower than the bridge with its RC.
% Output. flag -  '1' if Bridge with its RC stabilty is at least 10 times higher,
% '0' otherwise. Ratio - the ratio between the stabilties
BridgeRC=ReverseComplement(BridgeMS,1);
%oligo=strcat(UniversalMS,BridgeRC(1:end-5));
HSeqMS=strcat(ReverseComplement(UniversalMS,1),BridgeMS(1:end-5));
[statusNu,Spath]=unix('echo $NUPACKHOME');
prefix='Test';
FullPath=strcat(Spath,'/Scratch/',prefix,'.fold');
NUPACKInputPath=FullPath(1:end-5);
ConPath=strcat(NUPACKInputPath,'.con');
StrandCon=1e-6;
fileID=fopen(ConPath,'w');
fprintf(fileID,'%d\n%d\n%d\n',StrandCon,StrandCon,StrandCon);
fclose(fileID);
inPath=strcat(NUPACKInputPath,'.in');
fileID=fopen(inPath,'w');
fprintf(fileID,'3\n%s\n%s\n%s\n2\n',HSeqMS,BridgeMS,BridgeRC);
fclose(fileID);
complexesCmd=sprintf('complexes -T 42 -material dna -sodium 0.39 -magnesium 0 %s', NUPACKInputPath);
concCmd=sprintf('concentrations %s', NUPACKInputPath);
[statusComp,Compout] = unix(complexesCmd);
[statusConc,Concout] = unix(concCmd);
ToeEq=load(strcat(NUPACKInputPath,'.eq'));
for i=1:size(ToeEq,1)
    if ToeEq(i,2)==0 && ToeEq(i,3)==1 && ToeEq(i,4)==1
        Bridge_BridgeRC_Stab=ToeEq(i,6)/StrandCon;
    elseif ToeEq(i,2)==1 && ToeEq(i,3)==1 && ToeEq(i,4)==0
        Bridge_HybSeq_Stab=ToeEq(i,6)/StrandCon;
    end % if ToeEq(i,2)==0 && ToeEq(i,3)==1 && ToeEq(i,4)==1
end % for i=1:size(ToeEq,1)
Ratio=Bridge_BridgeRC_Stab/Bridge_HybSeq_Stab;
if Ratio>=10
    flag=1;
else
    flag=0;
end % if Ratio>=10
