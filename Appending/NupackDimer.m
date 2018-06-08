function UnstablePair =  NupackDimer(Streets_seq,Spath,FullSavePath)
%% NUPACK dimer interactions
UnstablePair=zeros(size(Streets_seq,2),size(Streets_seq,2));
NumOfStarnds=2;
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
Complexes=['complexes -T 58 -material dna -sodium 0.05 -magnesium 0.0015 ', NUPACKInputPath];
ComplexesHybe=['complexes -T 47 -material dna -sodium 0.39 -magnesium 0 ', NUPACKInputPath];
%ComplexesHybe=['complexes -T 47 -material dna -sodium 0.1256 -magnesium 0 ', NUPACKInputPath];
% 37c = 23 + 30% Formamide 47c = 23 + 40% Formamide
% sodium .125 = 0.8X PBS
Concentrations=['concentrations ',NUPACKInputPath];
StabThr=0.2;
flag=0;
h=waitbar(0,'Checking primer-primer dimers, please wait');
steps=size(Streets_seq,2);
F=steps; N=0; MaxAttempts=1;
while F>0.1*size(Streets_seq,2) & N<=MaxAttempts % while frequency of repeating value is bigger than 10% of the size of the sequences array
    for i=1:size(Streets_seq,2)-1
        Unstable_pair=zeros(1,size(Streets_seq,2));
        for j=i+1:size(Streets_seq,2)
            fileID=fopen(FullPath,'w');
            fprintf(fileID,'%d\n',NumOfStarnds);
            fprintf(fileID,'%s\n',Streets_seq{1,i});
            fprintf(fileID,'%s\n',Streets_seq{1,j});
            fprintf(fileID,'%d\n',NumOfStarnds);
            fclose(fileID);
            [statusComp,Comp] = unix(Complexes);
            [statusConc,Conc] = unix(Concentrations);
            Eq_Con=load([NUPACKInputPath,'.eq']);
            
            fileID=fopen(FullPath,'w');
            fprintf(fileID,'%d\n',NumOfStarnds);
            fprintf(fileID,'%s\n',ReverseComplement(Streets_seq{1,i},1));
            fprintf(fileID,'%s\n',Streets_seq{1,j});
            fprintf(fileID,'%d\n',NumOfStarnds);
            fclose(fileID);
            [statusCompRC,CompRC] = unix(ComplexesHybe);
            [statusConcRC,ConcRC] = unix(Concentrations);
            Eq_ConRC=load([NUPACKInputPath,'.eq']);
            
            fileID=fopen(FullPath,'w');
            fprintf(fileID,'%d\n',NumOfStarnds);
            fprintf(fileID,'%s\n',Streets_seq{1,i});
            fprintf(fileID,'%s\n',ReverseComplement(Streets_seq{1,j},1));
            fprintf(fileID,'%d\n',NumOfStarnds);
            fclose(fileID);
            [statusCompRC2,CompRC2] = unix(ComplexesHybe);
            [statusConcRC2,ConcRC2] = unix(Concentrations);
            Eq_ConRC2=load([NUPACKInputPath,'.eq']);
            
            fileID=fopen(FullPath,'w');
            fprintf(fileID,'%d\n',NumOfStarnds);
            fprintf(fileID,'%s\n',ReverseComplement(Streets_seq{1,i},1));
            fprintf(fileID,'%s\n',ReverseComplement(Streets_seq{1,j},1));
            fprintf(fileID,'%d\n',NumOfStarnds);
            fclose(fileID);
            [statusCompRCRC,CompRCRC] = unix(ComplexesHybe);
            [statusConcRCRC,ConcRCRC] = unix(Concentrations);
            Eq_ConRCRC=load([NUPACKInputPath,'.eq']);
            
            Eqsize=[size(Eq_Con,1),size(Eq_ConRC,1),size(Eq_ConRC2,1),size(Eq_ConRCRC,1)];
            MaxEqSize=max(Eqsize);
            if Eq_Con<MaxEqSize
                ZerosVec=zeros(MaxEqSize-size(Eq_Con,1),size(Eq_Con,2));
                Eq_Con(end+1:MaxEqSize,:)=ZerosVec;
            end % if Eq_Con<MaxEqSize
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
            
            flag=0; Dup_Stability=0; Dup_Stability1=0; Dup_Stability2=0; Dup_Stability3=0;
            for k=1:size(Eq_Con,1)
                % Find duplex coefficients.
                if flag==0
                    if (Eq_Con(k,2)==1 && Eq_Con(k,3)==1) || (Eq_Con(k,2)==2 && Eq_Con(k,3)==0)...
                            ||(Eq_Con(k,2)==0 && Eq_Con(k,3)==2)
                        Dup_Stability=Eq_Con(k,5)/FCon; % Here I assume that FCON=RCon.
                    end % if (Eq_Con(k,2)==1 && Eq_Con(k,3)==1) || (Eq_Con(k,2)==2 && Eq_Con(k,3)==0)...
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
                    end % if (Eq_ConRCRC(k,2)==1 && Eq_ConRCRC(k,3)==1) || (Eq_ConRCRC(k,2)==2 && Eq_ConRCRC(k,3)==0)...
                    DupArray=[Dup_Stability,Dup_Stability1,Dup_Stability2,Dup_Stability3];
                    Dup_Stability=max(DupArray);
                    if Dup_Stability >= StabThr
                       % Unstable_pair(p,1)=i;
                        Unstable_pair(j)=1;
                        flag=1;
                        Dup_Stability=0;
                    end % if Dup_Stability >= StabThr
                end % if flag==0
            end % for k=1:size(Eq_Con,1)
        end % for j=i+1:size(Streets_seq,2)
        UnstablePair(i,:)=Unstable_pair;
        waitbar(i/steps);
    end % for i=1:size(Streets_seq,2)-1
    if sum(UnstablePair)>0
        SumUnPr=sum(UnstablePair,2);
        RepValMax=find(SumUnPr==max(SumUnPr));
        N=N+1;
        temp=[];
        if F~=0
            Streets_seq{1,RepValMax}=nan;
            if N<MaxAttempts & F>0.1*size(Streets_seq,2)
                UnstablePair=zeros(size(Streets_seq,1),size(Streets_seq,2));
            end % if N<MaxAttempts & F>0.1*size(Streets_seq,2)
            j=1;
            for t=1:steps
                if ~isnan(Streets_seq{1,t})
                    temp{1,j}=Streets_seq{1,t};
                    j=j+1;
                end % if ~isnan(Streets_seq{1,t})
            end % for t=1:steps
            clear Streets_seq
            Streets_seq=temp;
            steps=size(Streets_seq,2);
        end % if F~=0
    else
        F=0;
    end % if sum(Unstable_pair)>0
end % while F>0.1*steps
close(h);
save(FullSavePath);
