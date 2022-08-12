function MakeStreets(varargin)
%% Documentation
% This script first asks if you would like to append docking sequences. If
% so, you will have to specify the the docking sequences input file once
% the script opens a dialouge box. The script uses the function
% FilterStreets to filter the streets that should be good primers as well.
% For troubleshooting contact Guy - guy_nir@hms.harvard.edu
%% Arranging input
GenerateToeholds=0;
AppendDocking=0;

for i=1:2:nargin-1
    if strcmp(varargin{i},'Toes')
        GenerateToeholds=1;
    elseif strcmp(varargin{i},'Docking')
        AppendDocking=1;
        DockingPath=str2double(varargin{i+1});
    elseif strcmp(varargin{i},'SavePath')
        SavePath=varargin{i+1};
    end % if strcmp(varargin{i},'Toes')
end % for i=1:2:nargin-1
%% Generate random sequences and append to docking sequences
Streets=[];
k=1;

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
end

% Construct a questdlg with two options and default
choice = questdlg('Would you like to append docking sequences?', ...
    'Streets Design', ...
    'Yes','No','No');
% Handle response
switch choice
    case 'Yes'
        AppendDocking = 1;
    case 'No'
        AppendDocking = 0;
end % switch choice
if AppendDocking == 1 && GenerateToeholds == 0
    Docking=LoadDocking;
    for i=1:length(Docking)
        flag=0;
        while flag == 0
            r=randi([1 4],1,10);
            if i==1
                temp(1:5)=r(1:5); temp(6:15)=Docking(i,:); temp(16:20)=r(6:10);
            elseif i~=8 && i~=2 && i~=6 && i~=14
                temp=cat(2,r,Docking(i,:)); % '5-random-docking-3'
            else
                temp=cat(2,Docking(i,:),r); % '5-docking-random-3'
            end % if i==1
            if FilterStreets(temp)==1 % filter streets
                flag=FilterStreets(ReverseComplement(temp));
            end % if FilterStreets(temp)==1 % filter streets
        end % while flag == 0
        Streets(i,:)=temp;
    end % for i=1:length(Docking)
elseif  AppendDocking == 0 && GenerateToeholds == 0
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
elseif  AppendDocking == 0 && GenerateToeholds == 1
    prompt = {'How many streets would you like (each oligo will be 20 nt + 7nt overhang = 27 nt in total)?'};
    dlg_title = 'Streets Input';
    num_lines = 1;
    defalutans = {'50'};
    answer = inputdlg(prompt,dlg_title,num_lines,defalutans);
    %Struct='.......((((((((((((((((((((+))))))))))))))))))))'; % 27 nt toehold, containing 7nt overhang at its 5'
    %Seq='SNNNNNNNNNNNWNNNNNNNNNNNNNN';
    %fileID=fopen(FullPath,'w');
    %fprintf(fileID,'%s\n%s\n',Struct,Seq);
    %fclose(fileID);
    h = waitbar(0,'Designing toeholds');
    for i=1:str2double(answer{1,1})
        Toes(i,:)=DesignToehold(FullPath,'seq');
        waitbar(i/str2double(answer{1,1}));
    end % for i=1:str2double(answer{1,1})
    close(h)
    Streets=SequenceToNumbers(Toes(:,8:end));
else % AppendDocking==1 && GenerateToeholds==1
    Docking=ReverseComplement(LoadDocking);
    h = waitbar(0,'Designing toeholds');
    for i=1:size(Docking,1)
        flag=0;
        while flag == 0
            temp=cat(2,randi([2 3],1,1),randi([1 4],1,6),randi([2 3],1,2),randi([1 4],1,4),...
                randi([2 3],1,2),Docking(i,:),randi([2 3],1,2));
            if FilterStreets(temp(8:end))==1 % filter streets
                flag=FilterStreets(ReverseComplement(temp(8:end)));
            end
        end % while flag == 0
        Seq(i,:)=Numbers2Sequnces(temp);
        Dock(i,:)=DesignToehold(FullPath,Seq(i,:));
        waitbar(i/size(Docking,1));
    end % for i=1:size Docking,1)
    close(h)
end %  % if AppendDocking == 1
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
Hybe47=['prob -T 37 -material dna -sodium 0.1256 -magnesium 0 ',NUPACKInputPath]; % For hybe in 37c with 1X PBS, or 30% formamide in RT
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
    ToesNum=SequenceToNumbers(Toes(:,8:end));
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
            end
        end
    end
end % if GenerateToeholds ==1
SavePath='/Users/guynir/Documents/MATLAB/Scratch/';
save([SavePath,'Streetsdata_040317.mat']);
%% NUPACK dimer interactions
Unstable_pair=[];
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
Complexes=['complexes -T 58 -material dna -sodium 0.05 -magnesium 0.0015 ', NUPACKInputPath];
%ComplexesHybe=['complexes -T 47 -material dna -sodium 0.39 -magnesium 0 ', NUPACKInputPath];
ComplexesHybe=['complexes -T 37 -material dna -sodium 0.1256 -magnesium 0 ', NUPACKInputPath];
% 37c = 23 + 30% Formamide 47c = 23 + 40% Formamide
% sodium .125 = 0.8X PBS
Concentrations=['concentrations ',NUPACKInputPath];
StabThr=0.2;
flag=0;
h=waitbar(0,'Checking primer-primer dimers, please wait');
steps=size(Streets_seq,2);
F=steps; N=0; MaxAttempts=1;
while F>0.1*size(Streets_seq,2) & N<=MaxAttempts % while frequency of repeating value is bigger than 10% of the size of the sequences array
    p=1;
    for i=1:size(Streets_seq,2)-1
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
                        Unstable_pair(p,1)=i;
                        Unstable_pair(p,2)=j;
                        p=p+1;
                        flag=1;
                        Dup_Stability=0;
                    end % if Dup_Stability >= StabThr
                end % if flag==0
            end % for k=1:size(Eq_Con,1)
        end % for j=i+1:size(Streets_seq,2)
        waitbar(i/steps);
    end % for i=1:size(Streets_seq,2)-1
    if exist('Unstable_pair','var')
        [RepVal, F] = mode(Unstable_pair);
        RepValMax=RepVal(F==max(F,[],2));
        RepValMax=RepValMax(1);
        N=N+1;
        temp=[];
        if F~=0
            Streets_seq{1,RepValMax}=nan;
            if N<MaxAttempts & F>0.1*size(Streets_seq,2)
                Unstable_pair=[];
            end % if N<5
            j=1;
            for t=1:steps
                if ~isnan(Streets_seq{1,t})
                    temp{1,j}=Streets_seq{1,t};
                    j=j+1;
                end % if ~isnan(Streets_seq{1,i})
            end % for t=1:steps
            clear Streets_seq
            Streets_seq=temp;
            steps=size(Streets_seq,2);
        end % if F~=0
    else
        F=0;
    end % if exist('Unstable_pair','var')
end % while F>0.1*steps
close(h);
%% Filter unstable pairs
temp=[];
if exist('Unstable_pair','var')
    if ~isempty(Unstable_pair)
        for i=1:size(Unstable_pair,1)
            Streets_seq{1,Unstable_pair(i,1)}=nan;
        end
        j=1;
        for i=1:steps
            if ~isnan(Streets_seq{1,i})
                temp{1,j}=Streets_seq{1,i};
                j=j+1;
            end % if ~isnan(Streets_seq{1,i})
        end % for i=1:steps
        Streets_seq=[];
        Streets_seq=temp;
    end % if ~isempty(Unstable_pair)
end % if exist('Unstable_pair','var')
%% Ensuring stable oligo-RC complex for hybe
StabThr=0.01;
p=1; flag=0;
h=waitbar(0,'Checking oligo-RC duplex hybe stabilization, please wait');
steps=size(Streets_seq,2);
for i=1:size(Streets_seq,2)
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
                Unstable_RcO(p,1)=i;
                p=p+1;
                flag=1;
            end % if Dup_Stability >= StabThr
        end % if (Eq_Con(i,2)==1 && Eq_Con(i,3)==1) || (Eq_Con(i,2)==2 && Eq_Con(i,3)==0)...
    end % for k=1:size(Eq_Con,1)
    waitbar(i/steps);
end % for i=1:size(Streets_seq,2)
close(h);
%% Filter unstable pairs of oligo-RC
temp=[];
if exist('Unstable_RcO','var')
    for i=1:size(Unstable_RcO,1)
        Streets_seq{1,Unstable_RcO(i,1)}=nan;
    end
    j=1;
    for i=1:steps
        if ~isnan(Streets_seq{1,i})
            temp{1,j}=Streets_seq{1,i};
            j=j+1;
        end % if ~isnan(Streets_seq{1,i})
    end % for i=1:steps
    Streets_seq=[];
    Streets_seq=temp;
end % if exist('Unstable_pair','var')
save([SavePath,'Streetsdata_091016.mat']);
%% Bowtie2 - Streets Alignment
BowScratchPath='/Users/guynir/bowtie2-2.2.9/Scratch/';
BowBuildPath='/Users/guynir/bowtie2-2.2.9/builds/';
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

Streets_Aligned = readtextfile('/Users/guynir/bowtie2-2.2.9/Scratch/Streets_aligned.txt');
%% Filter Streets which align with genome
temp=[]; k=1;
for i=1:size(Streets_Aligned,1)
    if strcmp('*',Streets_Aligned(i,13))
        temp{1,k}=Streets_seq{1,i};
        k=k+1;
    end % if strcmp('*',Streets_Aligned(i,13))
end % for i=1:size(Streets_Aligned,1)
Streets_seq=[];
Streets_seq=temp;
%% Bowtie2 - Toes Alignment
if GenerateToeholds ==1
    clear tempSeq
    k=1;
    for i=1:size(Streets_seq,2)
        for j=1:size(Toes2,1)
            if strcmp(Toes2(j,8:end),Streets_seq{1,i})
                Toes3(k,:)=Toes2(j,:);
                k=k+1;
                break
            end % if ToesNum(j,:)==Streets(i,:)
        end % for j=1:size(ToesNum,1)
    end % for i=1:size(Streets,1)
    
    BowScratchPath='/Users/guynir/bowtie2-2.2.9/Scratch/';
    BowBuildPath='/Users/guynir/bowtie2-2.2.9/builds/';
    prompt = {'Enter genome to align to, e.g. mm10, hg38'};
    dlg_title = 'Input';
    num_lines = 1;
    defaultans = {'hg38'};
    GenomeAlign = inputdlg(prompt,dlg_title,num_lines,defaultans);
    genomePath=strcat(GenomeAlign{1,1},'/',GenomeAlign{1,1});
    outputPath=strcat(BowScratchPath,'Toes_aligned.txt');
    BowFName=strcat(BowScratchPath,'Toes.fastq');
    fastTilda(1,1:size(Toes3,2))=sprintf('%s','~');
    fileID=fopen(BowFName,'w');
    formatspec='@chr1:1-%d\n%s\n+\n%s\n';
    for i=1:size(Toes3,1)
        fprintf(fileID,formatspec,size(Toes3,2),Toes3(i,:),fastTilda);
    end
    fclose(fileID);
    BowCommand=['bowtie2 -x ', BowBuildPath, genomePath,' --very-sensitive-local -k 1 -t --no-hd -S ',outputPath,' -U ',BowFName];
    [bowStatus,bowOutput]=unix(BowCommand);
    
    Toes_Aligned = readtextfile('/Users/guynir/bowtie2-2.2.9/Scratch/Toes_aligned.txt');
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
            if strcmp(Toes3(j,8:end),Streets_seq{1,i})
                Streets_seq2{1,k}=Toes3(j,8:end);
                k=k+1;
                break
            end % if ToesNum(j,:)==Streets(i,:)
        end % for j=1:size(ToesNum,1)
    end % for i=1:size(Streets,1)
    clear Streets_seq
    Streets_seq=Streets_seq2;
    clear Streets_seq2
end
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
SavePath='/Users/guynir/Documents/MATLAB/Scratch/';

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
save([SavePath,'Streetsdata_091417.mat']);