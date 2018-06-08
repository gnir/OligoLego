function AppendMS = AppMS(MSPath,StreetsPath,PTablePath,MaxAvoid,SavePath,varargin)
%% AppendingMS
% Load intersected mainstreet as a text file.
% Text file should be in the following format: chromosome (chrN),
% start, end, ID.
% Program will index different IDs at different files.
%% Load intersected
Main = readtextfile(MSPath);
Streets = readtextfile(StreetsPath);
PairsMatrix = readtextfile(PTablePath);
PairsMat=NaN(size(PairsMatrix,1),size(PairsMatrix,1));
for i=1:size(PairsMatrix,1) % Convert PenaltyMat to mat-var
    PairsMat(i,:)=str2num(PairsMatrix(i,:));
end % for i=1:size(PairsMatrix,1)
StreetsLength=size(Streets,2);
SOLiDFlag=0; % Flag to use SOLiD Barcoding
if ~isempty(varargin)
    Nvarargin=length(varargin);
    for i=1:Nvarargin
        if strcmp(varargin{i},'SameUniversal')
            Uni=Loadingtxt(varargin{i+1});
            UniR=str2double(Uni{1,3});
            UniF=str2double(Uni{1,1});
        elseif strcmp(varargin{i},'SOLiDStreets')
            Hamming=varargin{i+1};
            SOLiDcode = SOLiDBarcoding(4,Streets);
            SOLiDFlag=1;
            exclude=filterSOLiD(SOLiDcode,Hamming-1); % When inputing Hamming-1, function will filter with Hamming value.
            [Streets, ~, PairsMat, SOLiDcode]  = ReducePool(exclude,'Streets',Streets,'PTable',PairsMat,'SOLiDCode',SOLiDcode);
        end % if strcmp(varargin{i},'SameUniversal')
    end % for i=1:nargin
end % if ~isempty(varargin)
%% Arrange Mainstreet list

h = waitbar(0,'Organzing Mainstreet list, please wait');
for i=1:size(Main,1)
    k=1; t=1;
    for j=1:size(Main,2)
        if ~strcmp(char(00),Main(i,j))
            if ~isspace(Main(i,j))
                MainCell{i,t}(k)=Main(i,j);
                k=k+1;
            else
                k=1; t=t+1;
            end % if ~isspace(Main(i,j))
        else % strcmp(char(00),Main(i,j))
            break
        end %  if ~strcmp(char(00),Main(i,j))
    end % for j=1:size(Main,2)
    waitbar(i/size(Main,1))
end % for i=1:size(Main,1)
close(h)

clear temp
j=1;
for i=1:size(MainCell,1)
    if i~=size(MainCell,1)
        if ~strcmp(MainCell{i,8},MainCell{i+1,8}) &&...
                str2double(MainCell{i,2})<=str2double(MainCell{i,6}) &&...
                str2double(MainCell{i,3})>=str2double(MainCell{i,7})
            for k=1:size(MainCell,2)
                temp{j,k}=MainCell{i,k};
            end
            j=j+1;
        end % if ~strcmp(MainCell{i,8},MainCell{i+1,8}) &&...
    end % if i~=size(MainCell,1)
end % for i=1:size(MainCell,1)
clear MainCell
MainCell=temp;
clear temp
%% Indexing (adding the 10th column)
MainCell{1,end+1}=1; idxMain(1)=1; idxBack=1;
PosMain(1,1)=str2double(MainCell{1,2}); PosMain(1,2)=str2double(MainCell{1,3});
maxMID=MainCell{1,end};
for i=1:size(MainCell,1)-1
    flag=0;
    if strcmp(MainCell{i,4},MainCell{i+1,4})
        MainCell{i+1,end}=MainCell{i,end};
        if maxMID<MainCell{i+1,end}
            maxMID=MainCell{i+1,end};
        end % maxMID=MainCell{i+1,end};
    else % ~strcmp(MainCell{i,4},MainCell{i+1,4})
        for j=i:-1:1 % check if ID exists already
            if strcmp(MainCell{i+1,4},MainCell{j,4})
                MainCell{i+1,end}=MainCell{j,end};
                flag=1;
                break
            end % if strcmp(MainCell{i,4},MainCell{j,4})
        end % for j=i:-1:1 % check if ID exists already
        if flag==0
            MainCell{i+1,end}=maxMID+1;
            maxMID=MainCell{i+1,end};
            PosMain(end+1,1)=str2double(MainCell{i+1,2});
            PosMain(end,2)=str2double(MainCell{i+1,3});
            idxMain(end+1)=i+1;
        end % if flag==0
    end % if strcmp(MainCell{i,4},MainCell{j,4})
end % for i=1:size(MainCell,1)-1

maxMID=MainCell{end,10};
for i=1:size(MainCell,1) % find number of distinguished indices
    MToes(i)=(MainCell{i,10});
end
MToes=unique(MToes,'stable');
MToes_Len=length(MToes);
%% Find max ID
maxMC=0;
for i=1:size(MainCell,1)
    if MainCell{i,10}>maxMC
        maxMC=MainCell{i,10};
    end
end
%% Assign streets
% if isempty(varargin)
    PrR=MaxAvoid+1;
% end % if isempty(varargin)
    
MFlag=1; PrF=MaxAvoid+2; p=1; 
IFlag=0; fflag=0;

h = waitbar(0,'Assigning Streets');
for i=1:size(MainCell,1)
    if max(PrR(:))>=max(PrF(:))
        StartToe=max(PrR(:));
    else
        StartToe=max(PrF(:));
    end % if max(PrR(:))>=max(PrF(:))
    if MFlag==0
        OligoPaints{i,:}=strcat(ReverseComplement(Streets(PrF(end),:),1),MainCell{i,8},ReverseComplement(Streets(PrR(end),:),1));
        OPCords(i,1)=str2double(MainCell{i,6});
        OPCords(i,2)=str2double(MainCell{i,7});
    elseif MFlag==1
        flag=0;
        if IFlag==1 && fflag==0
            for j=StartToe+1:size(PairsMat,1)
                if PairsMat(j,PrR(end))<=3 && flag==0
                    OligoPaints{i,:}=strcat(ReverseComplement(Streets(j,:),1),MainCell{i,8},ReverseComplement(Streets(PrR(end),:),1));
                    OPCords(i,1)=str2double(MainCell{i,6});
                    OPCords(i,2)=str2double(MainCell{i,7});
                    flag=1;
                    PrF(end+1)=j;
                    p=size(PrF,2)+1;
                    break
                end % if PairsMat(j,repR_idx)<=3 && flag==0
            end % for j=StartToe+1:size(PairsMat,1)
        elseif IFlag==0
            for j=StartToe+1:size(PairsMat,1)
                if PairsMat(PrR(end),j)<=3 && flag==0
                    PrF(p)=j;
                    p=size(PrF,2)+1;
                    flag=1;
                    break
                end % if PairsMat(j,k)<=3 && flag==0
            end % for j=StartToe+1:size(PairsMat,1)
            OligoPaints{i,:}=strcat(ReverseComplement(Streets(PrF(end),:),1),MainCell{i,8},ReverseComplement(Streets(PrR(end),:),1));
            OPCords(i,1)=str2double(MainCell{i,6});
            OPCords(i,2)=str2double(MainCell{i,7});
        end % if IFlag==1 && rflag==1
    end % if BFlag==0 && MFlag==0
    if i~=size(MainCell,1)
        if MainCell{i,10}~=MainCell{i+1,10}
            MFlag=1;  IFlag=0;
            for t=i:-1:1
                if MainCell{i+1,10}==MainCell{t,10} && IFlag==0
                    for l=1:StartToe
                        if strcmp(OligoPaints{t,1}(1:StreetsLength),ReverseComplement(Streets(l,:),1))
                            PrF(end+1)=l;
                            p=size(PrF,2)+1;
                            IFlag=1;
                            break
                        end % if strcmp(OligoPaints{t,1}(1:StreetsLength),Toes(l,:))
                    end % for l=1:size(Toes,1)
                end % if MainCell{i+1,10}==MainCell{t,10} && IFlag==0
            end % for t=i:-1:1
        elseif MainCell{i,10}==MainCell{i+1,10}
            MFlag=0;
        end % if MainCell{i,10}~=MainCell{i+1,10}
        waitbar(i/(size(MainCell,1)))
    end % if I~=size(MainCell,1)
end % for i=1:size(MainCell,1)-1
close(h)
%% Add universal to mainstreet

if maxMC~=1 || exist('UniF','var') % will only add a mainstreet universal if there is more than 1 region, or when given 'SameUniversal'
    if exist('UniF','var')
        PrF(end+1)=UniF;
    else
        if max(PrR(:))>=max(PrF(:))
            StartToe=max(PrR(:));
        else
            StartToe=max(PrF(:));
        end % if max(PrR(:))>=max(PrF(:))
        flag=0;
        while flag==0
            for j=StartToe+1:size(PairsMat,1)
                if PairsMat(PrR(end),j)<=3 && flag==0
                    PrF(end+1)=j;
                    flag=1;
                end % if PairsMat(j,PrR(end))<=3 && flag==0
                if flag==0 && j==size(PairsMat,1)
                    if StartToe==size(PairsMat,1)-1
                        PrF(end+1)=j;
                        flag=1;
                        prefix='Warning.txt';
                        outputError=strcat(SavePath,prefix);
                        fileID=fopen(outputError,'w');
                        fprintf(fileID,'Not enough streets, universals may dimer, check ptable\n');
                        fclose(fileID);
                    end % if StartToe==size(PairsMat,1)-1
                    if flag==0
                        PrR(end)=StartToe+1;
                        StartToe=StartToe+2;
                    end % if flag==0
                end % if flag==0 && j==size(PairsMat,1)
            end % for j=PrF+1:size(PairsMat,1)-1
        end % while flag==0
    end % if exist('UniF','var')
    for i=1:size(OligoPaints,1)
        %OligoPaints{i,:}=strcat(Streets(PrF(end),:),OligoPaints{i,:},ReverseComplement(Streets(PrR(end),:),1));
        OligoPaints{i,:}=strcat(Streets(PrF(end),:),OligoPaints{i,:},1);
    end % for i=1:size(OligoPaints,1)
end % if maxMC~=1 || exist('UniF','var')
UniversalMS=Streets(PrF(end),:); % Forward Primer sequence
U_MS_N=PrF;
UniversalBS=Streets(PrR(end),:); % Reverse Primer sequence
U_BS_N=PrR;
%% Find Streets chosen
k=1; s=1; t=1; l=1;
h = waitbar(0,'Finding Streets chosen');
if maxMC==1 && ~exist('UniF','var')
    for i=1:size(OligoPaints,1)
        for j=1:size(Streets,1)
            if strcmp(OligoPaints{i,1}(1:2*StreetsLength),ReverseComplement(Streets(j,:),1))
                ToeMain(k)=j;
                k=k+1;
                if ~exist('OligoMain','var')
                    OligoMain(t)=i;
                    OligoSeqMain(t,:)=OligoPaints{i,1}(1:2*StreetsLength);
                    t=t+1;
                elseif ~strcmp(OligoPaints{i,1}(1:2*StreetsLength),OligoSeqMain(t-1,:))
                    OligoMain(t)=i;
                    OligoSeqMain(t,:)=OligoPaints{i,1}(1:2*StreetsLength);
                    t=t+1;
                end % if ~exist('OligoMain','var')
            end % if strcmp(OligoPaints{i,1}(StreetsLength+1:2*StreetsLength),ReverseComplement(Streets(j,:),1))
            if strcmp(OligoPaints{i,1}(end-2*StreetsLength+1:end-StreetsLength),ReverseComplement(Streets(j,:),1))
                ToeBack(s)=j;
                s=s+1;
                if ~exist('OligoBack','var')
                    OligoBack(l)=i;
                    OligoSeqBack(l,:)=OligoPaints{i,1}(end:end-StreetsLength+1);
                    l=l+1;
                elseif ~strcmp(OligoPaints{i,1}(end:end-StreetsLength+1),OligoSeqBack(l-1,:))
                    OligoBack(l)=i;
                    OligoSeqBack(l,:)=OligoPaints{i,1}(end:end-StreetsLength+1);
                    l=l+1;
                end % if ~exist('OligoBack','var')
            end % if strcmp(OligoPaints{i,1}(end-2*StreetsLength+1:end-StreetsLength),ReverseComplement(Streets(j,:),1))
        end % for j=1:size(Streets,1)
        waitbar(i/size(OligoPaints,1))
    end % for i=1:size(OligoPaints,1)
    close(h)      
else % if maxMC==1 && ~exist('UniF','var')
    for i=1:size(OligoPaints,1)
        for j=1:size(Streets,1)
            if strcmp(OligoPaints{i,1}(StreetsLength+1:2*StreetsLength),ReverseComplement(Streets(j,:),1))
                ToeMain(k)=j;
                k=k+1;
                if ~exist('OligoMain','var')
                    OligoMain(t)=i;
                    OligoSeqMain(t,:)=OligoPaints{i,1}(StreetsLength+1:2*StreetsLength);
                    t=t+1;
                elseif ~strcmp(OligoPaints{i,1}(StreetsLength+1:2*StreetsLength),OligoSeqMain(t-1,:))
                    OligoMain(t)=i;
                    OligoSeqMain(t,:)=OligoPaints{i,1}(StreetsLength+1:2*StreetsLength);
                    t=t+1;
                end
            end % if strcmp(OligoPaints{i,1}(StreetsLength+1:2*StreetsLength),ReverseComplement(Streets(j,:),1))
            if strcmp(OligoPaints{i,1}(end-2*StreetsLength+1:end-StreetsLength),ReverseComplement(Streets(j,:),1))
                ToeBack(s)=j;
                s=s+1;
                if ~exist('OligoBack','var')
                    OligoBack(l)=i;
                    OligoSeqBack(l,:)=OligoPaints{i,1}(end-2*StreetsLength+1:end-StreetsLength);
                    l=l+1;
                elseif ~strcmp(OligoPaints{i,1}(end-2*StreetsLength+1:end-StreetsLength),OligoSeqBack(l-1,:))
                    OligoBack(l)=i;
                    OligoSeqBack(l,:)=OligoPaints{i,1}(end-2*StreetsLength+1:end-StreetsLength);
                    l=l+1;
                end % if ~exist('OligoBack','var')
            end % if strcmp(OligoPaints{i,1}(end-2*StreetsLength+1:end-StreetsLength),ReverseComplement(Streets(j,:),1))
        end % for j=1:size(Streets,1)
        waitbar(i/size(OligoPaints,1))
    end % for i=1:size(OligoPaints,1)
    close(h)
end % if maxMC==1 && ~exist('UniF','var')
ToeMain=unique(ToeMain,'stable');
if exist('ToeBack','var')
    ToeBack=unique(ToeBack,'stable');
    ToeBackFlag=1;
else
    ToeBackFlag=0;
end % if exist('ToeBack','var')
%% Check that Streets are at least 2nt different
if ToeBackFlag==1
    ToeChosen=cat(2,ToeMain,ToeBack,PrF(end));
else
    ToeChosen=cat(2,ToeMain,PrF(end));
end % if ToeBackFlag==1
k=1;
for i=1:size(ToeChosen,2)-1
    for j=i+1:size(ToeChosen,2)
        if sum(Streets(ToeChosen(i),:)==Streets(ToeChosen(j),:))>StreetsLength-2
            ToeSame(k,:)=Streets(i,:);
            idx(k,1)=i; idx(k,2)=j;
            k=k+1;
        end
    end
end
if k>1
    errordlg(['You have ',num2str(k),' streets with 2 or less nt difference'])
end % if k>1
%% Find density of probes
Mcounts=zeros(1,maxMC);
McountsID=zeros(2,maxMC);
McountsID(1,1:maxMC)=str2double(MainCell{end,3});
t=1;
for i=1:size(MainCell,1)
    Mcounts(MainCell{i,10})=Mcounts(MainCell{i,10})+1;
    if McountsID(1,MainCell{i,10})>str2double(MainCell{i,2})
        McountsID(1,MainCell{i,10})=str2double(MainCell{i,2});
    end
    if McountsID(2,MainCell{i,10})<str2double(MainCell{i,3})
        McountsID(2,MainCell{i,10})=str2double(MainCell{i,3});
        flag=0;
        if t>1
            for s=size(MSReg,1):-1:1
                if strcmp(MSReg{s,1},MainCell{i,4})
                    flag=1;
                end % if strcmp(MSReg{t,1},MainCell{i,4})
            end % for t=i-1:-1:1
        end % if t>1
        if flag==0
            MSReg{t,1}=MainCell{i,4};
            t=t+1;
        end % if flag==0
    end % if McountsID(2,MainCell{i,10})<str2double(MainCell{i,3})
end % for i=1:size(MainCell,1)
Mcounts=Mcounts(MainCell{1,10}:end);
McountsID=McountsID(:,MainCell{1,10}:end);
McountsID(3,:)=(McountsID(2,:)-McountsID(1,:))./1000;
MProbesPerKb=Mcounts./McountsID(3,:);

%% Add 'T' to small regions with varying probe length (<200 fluorophores)
if maxMC~=1 || exist('UniF','var')
    MinNFluor=200;
    OPLength=nan(size(Mcounts,2),1); AfterSize=OPLength; BeforeSize=OPLength;
    h=waitbar(0,'Add T to small regions with varying probe length (<200 fluorophores)');
    for i=1:size(Mcounts,2)
        t=1;
        if Mcounts(i)<MinNFluor
            flag=0;
            for k=1:size(MainCell,1)
                if str2double(MainCell{k,6})>=McountsID(1,i) && str2double(MainCell{k,7})<=McountsID(2,i) && flag==0
                    for j=1:size(OligoPaints,1)
                        if strcmp(OligoPaints{j,1}(2*StreetsLength+1:end-2*StreetsLength),MainCell{k,8})
                            OPLength(i,t)=length(MainCell{k,8});
                            extendIdx(i,t)=j;
                            t=t+1;
                            flag=1;
                            break
                        end % if strcmp(OligoPaints{j,1}(2*StreetsLength+1:end-2*StreetsLength),MainCell{k,8})
                    end % for j=1:size(OligoPaints,1)
                elseif str2double(MainCell{k,7})>McountsID(2,i)
                    break
                end % if str2double(MainCell{k,6})>=McountsID(i,1) && str2double(MainCell{k,7})<=McountsID(i,1)
            end % for k=1:size(MainCell,1)
            MaxOP=max(OPLength(i,:));
            for t=1:size(OPLength,2)
                LenDiff=MaxOP-OPLength(i,t);
                if LenDiff>0 && OPLength(i,t)~=0 && ~isnan(OPLength(i,t))
                    BeforeSize(i,t)=size(OligoPaints{extendIdx(i,t),1},2);
                    for k=1:LenDiff
                        OligoPaints{extendIdx(i,t),1}=strcat(OligoPaints{extendIdx(i,t),1}(1:StreetsLength),'T',OligoPaints{extendIdx(i,t),1}(StreetsLength+1:end));
                    end % for k=1:LenDiff
                    AfterSize(i,t)=size(OligoPaints{extendIdx(i,t),1},2);
                end % if LenDiff>0
            end % for t=1:length(OPLength)
        end % if Bcounts(i)<MinNFluor
        if exist('AfterSize','var')
            if sum(AfterSize(i,:))>0
                AS=AfterSize(i,:); AS=AS(AS~=0);
                BS=BeforeSize(i,:); BS=BS(BS~=0);
                %figure(); hist(BS,7);
                %figure(); hist(AS,3);
            end
        end
        waitbar(i/size(Mcounts,2))
    end % for i=1:size(Mcounts,2)
    close(h)
end % if maxMC~=1 || exist('UniF','var')
%% Length distribution
OligoSize=zeros(size(OligoPaints,1),1);
for i=1:size(OligoPaints,1)
    OligoSize(i)=length(OligoPaints{i,1});
end
figure(); hist(OligoSize,7)
saveas(gcf,[SavePath,'LibraryLengthHistogram.png'])
[counts,bins]=hist(OligoSize,7);
%% Check probes per Toe
if maxMC~=1 || exist('UniF','var')
    CountToeMain=zeros(size(ToeMain,1),size(ToeMain,2));
    h=waitbar(0,'Counting probes per MainStreet');
    for i=1:size(ToeMain,2)
        for j=1:size(OligoPaints,1)
            if strcmp(OligoPaints{j,1}(StreetsLength+1:2*StreetsLength),ReverseComplement(Streets(ToeMain(i),:),1))
                CountToeMain(i)=CountToeMain(i)+1;
            end % if strcmp(OligoPaints{j,1}(end-46:end-20),ReverseComplement(Toes(ToeBack(i),:),1))
        end % for j=1:size(OligoPaints,1)
        waitbar(i/size(ToeMain,1))
    end % for i=1:size(ToeBack,2)
    close(h)
end % if maxMC~=1 || exist('UniF','var')
%% Print to file
k=1;
for i=1:size(MToes,2)
    flag=0;
    for j=1:size(MainCell,1)
        if MainCell{j,10}==MToes(i) && flag==0
            uniqueMIDs{k,1}=MainCell{j,4};
            MToeMain(k)=MToes(i);
            k=k+1;
            flag=1;
            break
        end % if MainCell{j,10}==MToes(i) && flag==0
    end % for j=1:size(MainCell,1)
end % for i=1:size(MToes,2)

prefix='Oligopaints.txt'; % print order text file
outputPaints=strcat(SavePath,prefix);
fileID=fopen(outputPaints,'w');
for i=1:size(OligoPaints,1)
    fprintf(fileID,'%s\n',OligoPaints{i,1});
end
fclose(fileID);


prefix='MS_IDs.txt'; % print backstreets streets number, MS ID, toe seq, bridge seq and Fwd primer seq.
outputMIDs=strcat(SavePath,prefix);
fileID=fopen(outputMIDs,'w');
if ~exist('SOLiDcode','var')
    fprintf(fileID,'MSRegionID\tID\tStreetNum\tStreetSequence\tBridgeSequence\tForwardPrimerSeq\n');
    for i=1:size(MToes,2)
        Bridge=Streets(ToeMain(i),:);
        FPrimer=ReverseComplement(Bridge,1);
        fprintf(fileID,'%s\t%d\t%d\t%s\t%s\t%s\n',uniqueMIDs{i,1},MToes(i),ToeMain(i),Streets(ToeMain(i),:),Bridge,FPrimer);
    end % for i=1:size(MToes,2)
else
    fprintf(fileID,'MSRegionID\tID\tStreetNum\tStreetSequence\tBridgeSequence\tForwardPrimerSeq\tSOLiDCode\n');
    for i=1:size(MToes,2)
        Bridge=Streets(ToeMain(i),:);
        FPrimer=ReverseComplement(Bridge,1);
        g=sprintf('%d',SOLiDcode(ToeMain(i),:)-1);
        fprintf(fileID,'%s\t%d\t%d\t%s\t%s\t%s\t%s\n',uniqueMIDs{i,1},MToes(i),ToeMain(i),Streets(ToeMain(i),:),Bridge,FPrimer,g);
    end % for i=1:size(MToes,2)
end % if ~exist('SOLiDcode','var')
fclose(fileID);

prefix='Universal.txt';
outputUniversal=strcat(SavePath,prefix);
fileID=fopen(outputUniversal,'w');
fprintf(fileID,'UniUniMainNum\tUniMainSequence\tUniBackiNum\tUniBackRCSequence\n');
fprintf(fileID,'%d\t%s\t%d\t%s\n',U_MS_N(end),UniversalMS,U_BS_N(end),UniversalBS);
fclose(fileID);

prefix='MSDensity.txt';
outputMSDensity=strcat(SavePath,prefix);
fileID=fopen(outputMSDensity,'w');
fprintf(fileID,'MS_Region\tStart\tEnd\tSize_(kb)\t#_of_OPs_probes\tDensity_(Probes/kb)\n');
for i=1:size(MSReg,1)
    fprintf(fileID,'%s\t%d\t%d\t%d\t%d\t%d\n',MSReg{i,1},McountsID(1,i),McountsID(2,i),McountsID(3,i),Mcounts(i),MProbesPerKb(i));
end % for i=1:size(MSReg,1)
fclose(fileID);
%% Save
save(strcat(SavePath,'data.mat'));
