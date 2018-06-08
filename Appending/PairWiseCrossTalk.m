%% Load Streets
Streets=readtextfile('/Users/guynir/Documents/MATLAB/Streets/Streets_hg38.txt');
%% NUPACK dimer interactions
[statusNu,Spath]=unix('echo $NUPACKHOME');
DupStab=size(Streets,1);
Unstable_pair=[];
Dup_Stability=0; Dup_Stability1=0; Dup_Stability2=0; Dup_Stability3=0;
NumOfStarnds=2;
FCon=1e-6; % i sequence concentration in M
RCon=1e-6; % j sequence concentration in M
if FCon~=RCon
    errordlg('Error: The code is not valid when using different primer concentrations. Contact Guy to fix this error');
end
prefix='NuDimer';
FullPath=strcat(Spath,'/Scratch/',prefix,'.in');
ConPath=strcat(Spath,'/Scratch/',prefix,'.con');
NUPACKInputPath=strcat(Spath,'/Scratch/',prefix);
fileID=fopen(ConPath,'w');
fprintf(fileID,'%e\n%e\n',FCon,RCon);
fclose(fileID);
%Complexes=['complexes -T 58 -material dna -sodium 0.05 -magnesium 0.0015 ', NUPACKInputPath];
ComplexesHybe=['complexes -T 37 -material dna -sodium 0.39 -magnesium 0 ', NUPACKInputPath];
% 37c = 23 + 30% Formamide
Concentrations=['concentrations ',NUPACKInputPath];
flag=0;
h=waitbar(0,'Checking primer-primer dimers, please wait');
steps=size(Streets,1);
for i=1:size(Streets,1)
    for j=i:size(Streets,1)
        fileID=fopen(FullPath,'w');
        fprintf(fileID,'%d\n',NumOfStarnds);
        fprintf(fileID,'%s\n',ReverseComplement(Streets(i,:),1));
        fprintf(fileID,'%s\n',Streets(j,:));
        fprintf(fileID,'%d\n',NumOfStarnds);
        fclose(fileID);
        [statusCompRC,CompRC] = unix(ComplexesHybe);
        [statusConcRC,ConcRC] = unix(Concentrations);
        Eq_ConRC=load([NUPACKInputPath,'.eq']);
        
        fileID=fopen(FullPath,'w');
        fprintf(fileID,'%d\n',NumOfStarnds);
        fprintf(fileID,'%s\n',Streets(i,:));
        fprintf(fileID,'%s\n',ReverseComplement(Streets(j,:),1));
        fprintf(fileID,'%d\n',NumOfStarnds);
        fclose(fileID);
        [statusCompRC2,CompRC2] = unix(ComplexesHybe);
        [statusConcRC2,ConcRC2] = unix(Concentrations);
        Eq_ConRC2=load([NUPACKInputPath,'.eq']);
        
        fileID=fopen(FullPath,'w');
        fprintf(fileID,'%d\n',NumOfStarnds);
        fprintf(fileID,'%s\n',ReverseComplement(Streets(i,:),1));
        fprintf(fileID,'%s\n',ReverseComplement(Streets(j,:),1));
        fprintf(fileID,'%d\n',NumOfStarnds);
        fclose(fileID);
        [statusCompRCRC,CompRCRC] = unix(ComplexesHybe);
        [statusConcRCRC,ConcRCRC] = unix(Concentrations);
        Eq_ConRCRC=load([NUPACKInputPath,'.eq']);
        
        Eqsize=[size(Eq_ConRC,1),size(Eq_ConRC2,1),size(Eq_ConRCRC,1)];
        MaxEqSize=max(Eqsize);
        if Eq_ConRC<MaxEqSize
            ZerosVec=zeros(MaxEqSize-size(Eq_ConRC,1),size(Eq_ConRC,2));
            Eq_ConRC(end+1:MaxEqSize,:)=ZerosVec;
        end % if Eq_ConRC<MaxEqSize
       if Eq_ConRC2<MaxEqSize
            ZerosVec=zeros(MaxEqSize-size(Eq_ConRC2,1),size(Eq_ConRC2,2));
            Eq_ConRC2(end+1:MaxEqSize,:)=ZerosVec;
       end % if Eq_ConRC2<MaxEqSize
       if Eq_ConRCRC<MaxEqSize
            ZerosVec=zeros(MaxEqSize-size(Eq_ConRCRC,1),size(Eq_ConRCRC,2));
            Eq_ConRCRC(end+1:MaxEqSize,:)=ZerosVec;
       end % if Eq_ConRC2<MaxEqSize

        for k=1:size(Eq_ConRC,1)
            % Find duplex coefficients.
                if (Eq_ConRC(k,2)==1 && Eq_ConRC(k,3)==1) || (Eq_ConRC(k,2)==2 && Eq_ConRC(k,3)==0)...
                        || (Eq_ConRC(k,2)==0 && Eq_ConRC(k,3)==2)
                    Dup_Stability1=Eq_ConRC(k,5)/FCon;
                end % if (Eq_ConRC(k,2)==1 && Eq_ConRC(k,3)==1) || (Eq_ConRC(k,2)==2 && Eq_ConRC(k,3)==0)...
               if (Eq_ConRC2(k,2)==1 && Eq_ConRC2(k,3)==1) || (Eq_ConRC2(k,2)==2 && Eq_ConRC2(k,3)==0)...
                        || (Eq_ConRC2(k,2)==0 && Eq_ConRC2(k,3)==2)
                    Dup_Stability2=Eq_ConRC(k,5)/RCon;
               end % if (Eq_ConRC2(k,2)==1 && Eq_ConRC2(k,3)==1) || (Eq_ConRC2(k,2)==2 && Eq_ConRC2(k,3)==0)...
                if (Eq_ConRCRC(k,2)==1 && Eq_ConRCRC(k,3)==1) || (Eq_ConRCRC(k,2)==2 && Eq_ConRCRC(k,3)==0)...
                        || (Eq_ConRCRC(k,2)==0 && Eq_ConRCRC(k,3)==2)
                    Dup_Stability3=Eq_ConRCRC(k,5)/FCon; % Here I assume that FCON=RCon.
                end % if (Eq_Con(k,2)==1 && Eq_Con(k,3)==1) || (Eq_Con(k,2)==2 && Eq_Con(k,3)==0)...
                DupArray=[Dup_Stability1,Dup_Stability2,Dup_Stability3];
                Dup_Stability=max(DupArray);
        end % for k=1:size(Eq_Con,1)
        DupStab(i,j)=Dup_Stability;
        Dup_Stability=0;
    end % for j=i+1:size(Streets,1)
    waitbar(i/steps);
end % for i=1:size(Streets,1)
close(h);