%% Documentation
% The script uses the function FilterStreets to filter the streets that should be good primers as well.
% For troubleshooting contact Guy - guy_nir@hms.harvard.edu
%% Define save path
SavePath='/Users/guynir/Documents/MATLAB/Scratch/'; % the folder where the street files will be saved
d=date;
Prefix=strcat('StreetsData_',d);
FullSavePath=strcat(SavePath,Prefix);
%% Define bowtie2 path
BowScratchPath='/Users/guynir/bowtie2-2.2.9/Scratch/'; % make a sctratch path in bowtie where you will save temp files
BowBuildPath='/Users/guynir/bowtie2-2.2.9/builds/'; % path to bowtie builds
%% Generate random sequences
Streets=[];
k=1;
Existing = questdlg('Would you like to filter an existing pool of streets or make a new one?',...
    'New or Existing', 'Make new', 'Load existing', 'Make new');
% Handle response
switch Existing
    case 'Make new'
        % Construct a questdlg with two options and default
        choice = questdlg('Would you like to generate toeholds?', ...
            'Streets Design', ...
            'Yes','No','No');
        % Handle response
        switch choice
            case 'Yes'
                GenerateToeholds = 1;
                [statusNu,Spath]=unix('echo $NUPACKHOME');
                prefix='Toehold';
                FullPath=strcat(Spath,'/Scratch/',prefix,'.fold');
            case 'No'
                GenerateToeholds = 0;
        end % switch choice
        
        
        if  GenerateToeholds == 0 
            prompt = {'How many streets would you like?', 'How many nucleotides should each street be?'};
            dlg_title = 'Streets Input';
            num_lines = 1;
            defalutans = {'50','20'};
            answer = inputdlg(prompt,dlg_title,num_lines,defalutans);
            for i=1:str2num(answer{1,1})
                flag=0;
                while flag == 0
                    temp=randi([1 4],1,str2num(answer{2,1}));
                    flag=FilterStreets(temp);
                end % while flag==0
                Streets(i,:)=temp;
                flag=0;
            end % for i=1:length(Docking)           
        elseif GenerateToeholds == 1 
            prompt = {'How many streets would you like (each oligo will be 20 nt + X nt overhang)?','How long would you like the toe to be?'};
            dlg_title = 'Streets Input';
            num_lines = 1;
            defalutans = {'50','7'};
            answer = inputdlg(prompt,dlg_title,num_lines,defalutans);
            toeLength=str2double(answer{2,1});
            Hamming=2;
            ToesSize=0;
            k=1;
            h = waitbar(0,'1','Name','Designing toeholds','CretaeCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
            setappdata(h,'canceling',0)
            while ToesSize<str2double(answer{1,1})
                for i=ToesSize+1:str2double(answer{1,1})
                    Toes(k,:)=DesignToehold(FullPath,'TLength',toeLength,'seq');
                    k=k+1;
                    if k>str2double(answer{1,1})
                        break
                    end % if k>str2double(answer{1,1})
                    % Check for Cancel button press
                    if getappdata(h,'canceling')
                        break
                    end % if getappdata(h,'canceling')
                    Precentage=k/str2double(answer{1,1})*100;
                    waitbar(k/str2double(answer{1,1}),h,sprintf('%i.2',Precentage));
                end % for i=ToesSize+1:str2double(answer{1,1})
                ToesSize=size(Toes,1);
            end % while size(Toes,1)<answer{1,1}
            close(h)
            Streets=SequenceToNumbers(Toes(:,toeLength+1:end));
        end %  if  GenerateToeholds == 0 && GenerateSOLiD == 0
    case 'Load existing'
        ExistingPool = Loadingtxt;
        [statusNu,Spath]=unix('echo $NUPACKHOME');
        prefix='Toehold';
        FullPath=strcat(Spath,'/Scratch/',prefix,'.fold');
        Toes = FilterToehold(FullPath,ExistingPool);
        toeLength=7;
        Streets=SequenceToNumbers(Toes(:,toeLength+1:end));
end % switch Existing
save(FullSavePath);
%% Check for primer-primer binding
h = waitbar(0,'Checking primer-primer binding, please wait');
steps=size(Streets,1);
for i=1:size(Streets,1)-1
    flag=0;
    while Streets(i,:)~=0 & flag==0
        for j=i+1:size(Streets,1)
            if (PrimerMaxSelfAny(Streets(i,:),Streets(j,:))>8)...
                    || (PrimerMaxSelfAny(Streets(i,:))>8)...
                    || (PrimerMaxSelfAny(ReverseComplement(Streets(i,:)),Streets(j,:))>8)...
                    || (PrimerMaxSelfAny(Streets(i,:),ReverseComplement(Streets(j,:)))>8)...
                    || (PrimerMaxSelfAny(ReverseComplement(Streets(i,:)),ReverseComplement(Streets(j,:)))>8)
                if ~ischar(Streets(i,:))
                    Streets(i,:)=0;
                else
                    Streets(i,:)='$';
                end % if ~ischar(Streets(i,:))
            end % if PrimerMaxSelfAny(Streets(i,:),Streets(j,:))>8
        end % for j=i+1:size(Streets,1)-1
        flag=1;
    end % while Streets(i,:)~=0
    waitbar(i/steps);
end % for i=1:size(Streets,1)
close(h);
if ~ischar(Streets(1,:))
    temp=zeros(size(Streets,1),size(Streets,2));
else
    temp=strings(size(Streets,1),size(Streets,2));
end % if ~ischar(temp)
k=1;
for i=1:size(Streets,1)
    if ~ischar(Streets(i,:))
        if Streets(i,:)~=0
            temp(k,:)=Streets(i,:);
            k=k+1;
        end % if Streets(i,:)~=0
    else
        if ~strcmp('$',Streets(i,1))
            temp(k,:)=Streets(i,:);
            k=k+1;
        end % if Streets(i,:)~=0
    end % if ~ischar(Streets(i,:))
end % for i=1:size(Streets,1)
Streets=[];
Streets=temp;
%% Check for primer self end
temp=[];
h = waitbar(0,'Checking 3 end binding, please wait');
steps=size(Streets,1);
k=1;
for i=1:size(Streets,1)
    if MaxSelfEnd(Streets(i,:))<=3 && MaxSelfEnd(ReverseComplement(Streets(i,:)))<=3
        temp(k,:)=Streets(i,:);
        k=k+1;
        waitbar(i/steps);
    end % for i=1:size(Streets,1)
end
close(h);
Streets=[];
Streets=temp;
%% Translate into sequence
Streets_seq=[];
for i=1:size(Streets,1)
    for j=1:size(Streets,2)
        switch Streets(i,j)
            case 1
                Streets_seq{i}(j)='A';
            case 2
                Streets_seq{i}(j)='C';
            case 3
                Streets_seq{i}(j)='G';
            case 4
                Streets_seq{i}(j)='T';
        end % switch Streets(i,j)
    end % for j=1:length(Streets)
end % for i=1:length(Streets)
%% NUPACK secondary structure
thrSec=0.001;
LinStruct=[];
StreetsSize=length(Streets_seq{1,1});
prob=zeros(2,size(Streets_seq,2));
prefix='NuStruc';
[statusNu,Spath]=unix('echo $NUPACKHOME');
FullPath=strcat(Spath,'/Scratch/',prefix,'.in');
NUPACKInputPath=strcat(Spath,'/Scratch/',prefix);
PCR58=['prob -T 58 -material dna -sodium 0.05 -magnesium 0.0015 ',NUPACKInputPath]; % For PCR with 58c for annelaing
Hybe47=['prob -T 47 -material dna -sodium 0.39 -magnesium 0 ',NUPACKInputPath]; % For hybe in 47c with 2X SSC, or 30% formamide in RT
k=1; j=1;
for i=1:size(Streets_seq,2)
    fileID=fopen(FullPath,'w');
    LinStruct(1,1:StreetsSize)=sprintf('%s','.');
    fprintf(fileID,'%s\n',Streets_seq{1,i});
    fprintf(fileID,'%s\n',LinStruct);
    fclose(fileID);
    [status,cmdout] = unix(PCR58);
    prob(1,i)=str2double(cmdout(1,410:end)); % Probability of the linear structure from 0 to 1
    [statusHybe,hybe]=unix(Hybe47);
    prob(2,i)=str2double(hybe(1,410:end)); % Probability of the linear structure from 0 to 1
    if prob(1,i) <= thrSec || prob(2,i) <= thrSec
        badidx(k)=i;
        k=k+1;
    else
        tempSeq{1,j}=Streets_seq{1,i};
        j=j+1;
    end % if probe(1,i) <= thrSec || probe(2,i) <= thrSec
end % for i=1:size(Streets_seq,2)
Streets_seq=[];
Streets_seq=tempSeq;
%% NUPACK Toehold secondary structure
if GenerateToeholds ==1
    clear tempSeq
    ToesNum=SequenceToNumbers(Toes(:,toeLength+1:end));
    k=1;
    for i=1:size(Streets,1)
        for j=1:size(ToesNum,1)
            if ToesNum(j,:)==Streets(i,:)
                Toes2(k,:)=Toes(j,:);
                k=k+1;
                break
            end % if ToesNum(j,:)==Streets(i,:)
        end % for j=1:size(ToesNum,1)
    end % for i=1:size(Streets,1)
    k=1; t=1;
    for i=1:size(Toes2,1)
        fileID=fopen(FullPath,'w');
        LinStruct(1,1:size(Toes2,2))=sprintf('%s','.');
        fprintf(fileID,'%s\n',Toes2(i,:));
        fprintf(fileID,'%s\n',LinStruct);
        fclose(fileID);
        [statusHybe,hybe]=unix(Hybe47);
        probToe(i)=str2double(hybe(1,421:end)); % Probability of the linear structure from 0 to 1
        if probToe(i) <= thrSec
            badidxToe(k)=i;
            k=k+1;
        else
            tempSeq(t,:)=Toes2(i,:);
            t=t+1;
        end % if probe(1,i) <= thrSec || probe(2,i) <= thrSec
    end % for i=1:size(Streets_seq,2)
    clear Toes2
    Toes2=tempSeq;
    k=1;
    if exist('badidxToe','var')
        for i=1:size(Streets_seq,2)
            if i~=badidxToe
                StSeqtemp{1,k}=Streets_seq{1,i};
                k=k+1;
            end % if i~=badidxToe
        end % for i=1:size(Streets_seq,2)
    end % if exist('badidxToe','var')
    Streets_seq=StSeqtemp;
end % if GenerateToeholds ==1
save(FullSavePath);
%% NUPACK dimer interactions
NPackDmerSave=[FullSavePath,'NPackDmr'];
UnstablePair =  NupackDimer(Streets_seq,Spath,NPackDmerSave);
%% Filter unstable pairs
temp=[]; Toes2Temp=[];

for i=1:size(UnstablePair,1)
    UnstablePair(i,1:i)=UnstablePair(1:i,i);
end % for i=1:size(UnstablePair,1)

SumUPair=sum(UnstablePair,2);
pd=fitdist(SumUPair,'Normal');
ci = paramci(pd,'Alpha',.01);

k=1; 
if ci(2,1)>0 % upper bound (alpha)
    for i=1:size(Streets_seq,2)
        if SumUPair(i)<ci(2,1)
            temp{k}=Streets_seq{i};
            Toes2Temp(k,:)=Toes2(i,:);
            k=k+1;
        end % if SumUPair(i)<ci(2,1)
    end % for i=1:size(Streets_seq,2)
end % if ci(2,1)>0

Streets_seq=temp;
Toes2=Toes2Temp;
clear temp Toes2Temp
save(FullSavePath);
%% Ensuring stable oligo-RC complex for hybe
Unstable_RcO = OligoRCHybe(Streets_seq,NumOfStarnds,Spath,[SavePath,'ORC.mat']);
%% Filter unstable pairs of oligo-RC
if sum(Unstable_RcO)>0
    k=1;
    StrTemp=cell(size(Unstable_RcO==0,1),size(Unstable_RcO==0,2));
    ToesTemp=zeros(size(Unstable_RcO==0,1),size(Unstable_RcO==0,2));
    for i=1:size(Streets_seq,2)
        if Unstable_RcO(i)==0
            StrTemp{k}=Streets_seq{1,i};
            ToesTemp(k,:)=Toes2(k,:);
            k=k+1;
        end % if Unstable_RcO(i)==0
    end % for i=1:size(Streets_seq,2)
    Toes2=ToesTemp;
    Streets_seq=StrTemp;
    clear ToesTemp StrTemp
end % if sum(Unstable_RcO)>0
save(FullSavePath);
%% Bowtie2 - Streets Alignment
prompt = {'Enter genome to align to, e.g. mm10, hg38'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'hg38'};
GenomeAlign = inputdlg(prompt,dlg_title,num_lines,defaultans);
genomePath=strcat(GenomeAlign{1,1},'/',GenomeAlign{1,1});
outputPath=strcat(BowScratchPath,'Streets_aligned.txt');
BowFName=strcat(BowScratchPath,'Streets.fastq');
fastTilda(1,1:StreetsSize)=sprintf('%s','~');
fileID=fopen(BowFName,'w');
formatspec='@chr1:1-%d\n%s\n+\n%s\n';
for i=1:size(Streets_seq,2)
    fprintf(fileID,formatspec,StreetsSize,Streets_seq{1,i},fastTilda);
end
fclose(fileID);
BowCommand=['bowtie2 -x ', BowBuildPath, genomePath,' --very-sensitive-local -k 1 -t --no-hd -S ',outputPath,' -U ',BowFName];
[bowStatus,bowOutput]=unix(BowCommand);

Streets_Aligned = readtextfile(outputPath);
%% Filter Streets which align with genome
temp=[]; k=1;
for i=1:size(Streets_Aligned,1)
    if strcmp('*',Streets_Aligned(i,13))
        temp{1,k}=Streets_seq{1,i};
        k=k+1;
    end
end
Streets_seq=[];
Streets_seq=temp;
%% Bowtie2 - Toes Alignment
if GenerateToeholds ==1
    clear tempSeq
    k=1;
    for i=1:size(Streets_seq,2)
        for j=1:size(Toes2,1)
            if strcmp(char(Toes2(j,toeLength+1:end)),Streets_seq{1,i})
                Toes3(k,:)=char(Toes2(j,:));
                k=k+1;
                break
            end % if ToesNum(j,:)==Streets(i,:)
        end % for j=1:size(ToesNum,1)
    end % for i=1:size(Streets,1)
    
    %prompt = {'Enter genome to align to, e.g. mm10, hg38'};
    %dlg_title = 'Input';
    %num_lines = 1;
    %defaultans = {'hg38'};
    %GenomeAlign = inputdlg(prompt,dlg_title,num_lines,defaultans);
    genomePath=strcat(GenomeAlign{1,1},'/',GenomeAlign{1,1});
    outputPath=strcat(BowScratchPath,'Toes_aligned.txt');
    BowFName=strcat(BowScratchPath,'Toes.fastq');
    fastTilda(1,1:size(Toes3,2))=sprintf('%s','~');
    fileID=fopen(BowFName,'w');
    formatspec='@chr1:1-%d\n%s\n+\n%s\n';
    for i=1:size(Toes3,1)
        fprintf(fileID,formatspec,size(Toes3,2),Toes3(i,:),fastTilda);
    end % for i=1:size(Toes3,1)
    fclose(fileID);
    BowCommand=['bowtie2 -x ', BowBuildPath, genomePath,' --very-sensitive-local -k 1 -t --no-hd -S ',outputPath,' -U ',BowFName];
    [bowStatus,bowOutput]=unix(BowCommand);
    
    Toes_Aligned = readtextfile(outputPath);
end % if GenerateToeholds==1
%% Filter Toes which align with genome (and match Toes to Streets)
if GenerateToeholds==1
    clear temp; k=1;
    for i=1:size(Toes3,1)
        if strcmp('*',Toes_Aligned(i,13))
            temp(k,:)=Toes3(i,:);
            k=k+1;
        end
    end
    clear Toes3
    Toes3=temp;
    
    k=1;
    for i=1:size(Streets_seq,2)
        for j=1:size(Toes3,1)
            if strcmp(Toes3(j,toeLength+1:end),Streets_seq{1,i})
                Streets_seq2{1,k}=Toes3(j,toeLength+1:end);
                k=k+1;
                break
            end % if ToesNum(j,:)==Streets(i,:)
        end % for j=1:size(ToesNum,1)
    end % for i=1:size(Streets,1)
    clear Streets_seq
    Streets_seq=Streets_seq2;
    clear Streets_seq2
end % if GenerateToeholds==1
%% Check that streets are at least 2 nt different
Streets=zeros(size(Streets_seq,2),StreetsSize);
for i=1:size(Streets_seq,2)
    Streets(i,:)=SequenceToNumbers(Streets_seq{1,i});
end % for i=1:size(Streets_seq,2)

k=1;
SameStreetIdx=[];
for i=1:size(Streets,1)-1
    for j=i+1:size(Streets,1)
        StreetsDif=abs(Streets(i,:)-Streets(j,:));
        ZeroInd=find(StreetsDif);
        if ZeroInd>StreetsSize-2
            SameStreetIdx(k)=i;
            k=k+1;
        end % if ZeroInd>StreetsSize-2
    end % for j=i+1:size(Streets,1)
end % for i=1:size(Streets,1)-1

if ~isempty(SameStreetIdx)
    Streets=Streets(Streets~=SameStreetIdx,:);
    Toes3=Toes3(Streets~=SameStreetIdx,:);
    StreetsSeqTemp=Numbers2Sequnces(Streets);
   Streets_seq=cell(size(StreetsSeqTemp,1),size(StreetsSeqTemp,2));
    for i=1:size(StreetsSeqTemp,1)
        Streets_seq{1,i}=StreetsSeqTemp(i,:);
    end % for i=1:size(StreetsSeqTemp,1)
end % if ~isempty(SameStreetIdx)
%% Build Penalty Matrix
penaltyMat=NaN(size(Streets_seq,2),size(Streets_seq,2));
h = waitbar(0,'Building penalty mat for 3 end binding of primer-pairs, please wait');
steps=size(Streets_seq,2);
for i=1:size(Streets_seq,2)-1
    for j=i+1:size(Streets_seq,2)
        penaltyMat(i,j)= MaxSelfEnd(Streets_seq{1,i},Streets_seq{1,j}); % Penalty scores for primer pairs
    end % for j=i+1:size(Streets,1)
    waitbar(i/steps);
end % for i=1:size(Streets,1)
close(h);
%% Save to text file

prefix=strcat('Streets_',GenomeAlign{1,1},'.txt');
SaveName=strcat(SavePath,prefix);
fileID=fopen(SaveName,'w');
for i=1:size(Streets_seq,2)
    fprintf(fileID,'%s\n',Streets_seq{1,i});
end
fclose(fileID); % Save streets pool

prefixToe=strcat('Toes_',GenomeAlign{1,1},'.txt');
SaveName=strcat(SavePath,prefixToe);
fileID=fopen(SaveName,'w');
for i=1:size(Toes3,1)
    fprintf(fileID,'%s\n',Toes3(i,:));
end
fclose(fileID);

prefixT=strcat('PenaltyTable_',GenomeAlign{1,1},'.txt');
SaveName=strcat(SavePath,prefixT);
fileID=fopen(SaveName,'w');
for i=1:size(penaltyMat,1)
    flag=0;
    for j=1:size(penaltyMat,2)
        if j==size(penaltyMat,2)
            flag=1;
        end % if j=size(penaltyMat,2)
        if isnan(penaltyMat(i,j)) && flag~=1
            fprintf(fileID,'%s\t',penaltyMat(i,j));
        elseif isnan(penaltyMat(i,j)) && flag==1
            fprintf(fileID,'%s\n',penaltyMat(i,j));
        elseif ~isnan(penaltyMat(i,j)) && flag~=1
            fprintf(fileID,'%d\t',penaltyMat(i,j));
        elseif ~isnan(penaltyMat(i,j)) && flag==1
            fprintf(fileID,'%d\n',penaltyMat(i,j));
        end % if isnan(penaltyMat(i,j)) && flag~=1
    end % for j=1:size(penaltyMat,2)
end % for i=1:size(penaltyMat,1)
fclose(fileID);
save(FullSavePath);