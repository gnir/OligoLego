function AppToMSBS(MSPath,BSPath,StreetsPath,PTablePath,ToesPath,MaxAvoid,SavePath,varargin)
%% AppendingToesMSBS
% load intersected backstreet and mainstreet as 2 different text files.
% Each text file should be in the following format: chromosome (chrN),
% start, end, ID.
% Program will index different IDs at different files. Mainstreets will be
% indexed first with lower indices, and then backstreet.
%% Load intersected
Main = readtextfile(MSPath);
Back = readtextfile(BSPath);
Streets = readtextfile(StreetsPath);
PairsMatrix = readtextfile(PTablePath);
PairsMat=NaN(size(PairsMatrix,1),size(PairsMatrix,1));
for i=1:size(PairsMatrix,1) % Convert PenaltyMat to mat-var
    PairsMat(i,:)=str2num(PairsMatrix(i,:));
end % for i=1:size(PairsMatrix,1)
Toes = readtextfile(ToesPath);
if ~isempty(varargin)
    Nvarargin=length(varargin);
    for i=1:Nvarargin
        if strcmp(varargin{i},'SameUniversal')
            Uni=Loadingtxt(varargin{i+1});
            UniR=str2double(Uni{1,3});
            UniF=str2double(Uni{1,1});
        elseif strcmp(varargin{i},'SOLiDStreets')
            SOLiDcode = SOLiDBarcoding(4,Streets,'RC');
            Hamming=varargin{i+1};
            exclude=filterSOLiD(SOLiDcode,Hamming-1); % When inputing Hamming-1, function will filter with Hamming value.
            [Streets, PairsMat] = ReducePool(exclude,'Streets',Streets,'PTable',PairsMat);
        elseif strcmp(varargin{i},'SOLiDToes')
            Hamming= varargin{i+1};
            SOLiDcode = SOLiDBarcoding(4,Toes,'RC');
            exclude=filterSOLiD(SOLiDcode,Hamming-1); % When inputing Hamming-1, function will filter with Hamming value.
            [Streets, Toes, PairsMat, SOLiDcode]  = ReducePool(exclude,'Streets',Streets,'Toes',Toes,'PTable',PairsMat,'SOLiDCode',SOLiDcode);
        end % if strcmp(varargin{i},'SameUniversal')
    end % for i=1:nargin
end % if ~isempty(varargin)
%% Arrange Backstreet and Mainstreet lists
h = waitbar(0,'organzing backstreet list, please wait');
for i=1:size(Back,1)
    k=1; t=1;
    for j=1:size(Back,2)
        if ~strcmp(char(00),Back(i,j))
            if ~isspace(Back(i,j))
                BackCell{i,t}(k)=Back(i,j);
                k=k+1;
            else
                k=1; t=t+1;
            end % if ~isspace(Back(i,j))
        else % strcmp(char(00),Back(i,j))
            break
        end %  if ~strcmp(char(00),Back(i,j))
    end % for j=1:size(Back,2)
    waitbar(i/size(Back,1))
end % for i=1:size(Back,1)
close(h)


h = waitbar(0,'organzing Mainstreet list, please wait');
for i=1:size(Main,1)
    k=1; t=1;
    for j=1:size(Main,2)
        if ~strcmp(char(00),Main(i,j))
            if ~isspace(Main(i,j))
                MainCell{i,t}(k)=Main(i,j);
                k=k+1;
            else
                k=1; t=t+1;
            end % if ~isspace(Back(i,j))
        else % strcmp(char(00),Back(i,j))
            break
        end %  if ~strcmp(char(00),Back(i,j))
    end % for j=1:size(Back,2)
    waitbar(i/size(Main,1))
end % for i=1:size(Back,1)
close(h)

if exist('temp','var')
    clear temp
end
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
    else % if i==size(MainCell,1)
        if ~strcmp(MainCell{i,8},MainCell{i-1,8}) &&...
                str2double(MainCell{i,2})<=str2double(MainCell{i,6}) &&...
                str2double(MainCell{i,3})>=str2double(MainCell{i,7})
            for k=1:size(MainCell,2)
                temp{j,k}=MainCell{i,k};
            end % for k=1:size(MainCell,2)
            j=j+1;
        end % if ~strcmp(MainCell{i,8},MainCell{i-1,8})       
    end % if i~=size(MainCell,1)
end % for i=1:size(MainCell,1)
clear MainCell
MainCell=temp;

clear temp
j=1;
for i=1:size(BackCell,1)
    if i~=size(BackCell,1)
        if ~strcmp(BackCell{i,8},BackCell{i+1,8}) &&...
                str2double(BackCell{i,2})<=str2double(BackCell{i,6}) &&...
                str2double(BackCell{i,3})>=str2double(BackCell{i,7})
            for k=1:size(BackCell,2)
                temp{j,k}=BackCell{i,k};
            end % for k=1:size(BackCell,2)
            j=j+1;
        end % if ~strcmp(BackCell{i,8},BackCell{i+1,8})
    else % if i==size(BackCell,1)
        if ~strcmp(BackCell{i,8},BackCell{i-1,8}) &&...
                str2double(BackCell{i,2})<=str2double(BackCell{i,6}) &&...
                str2double(BackCell{i,3})>=str2double(BackCell{i,7})
            for k=1:size(BackCell,2)
                temp{j,k}=BackCell{i,k};
            end % for k=1:size(BackCell,2)
            j=j+1;
        end % if ~strcmp(BackCell{i,8},BackCell{i-1,8})
    end % if i~=size(BackCell,1)
end % for i=1:size(BackCell,1)
clear BackCell
BackCell=temp;

%% Indexing (adding the 10th column)
MainCell{1,end+1}=1; idxMain(1)=1; idxBack=1;
PosMain(1,1)=str2double(MainCell{1,2}); PosMain(1,2)=str2double(MainCell{1,3});
PosBack(1,1)=str2double(BackCell{1,2}); PosBack(1,2)=str2double(BackCell{1,3});
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

BackCell{1,end+1}=maxMID+1;
maxBID=BackCell{1,end};
for i=1:size(BackCell,1)-1
    flag=0;
    if strcmp(BackCell{i,4},BackCell{i+1,4})
        BackCell{i+1,end}=BackCell{i,end};
        if maxBID<BackCell{i+1,end}
            maxBID=BackCell{i+1,end};
        end % maxBID=BackCell{i+1,end};
    else % ~strcmp(BackCell{i,4},BackCell{i+1,4})
        for j=i:-1:1 % check if ID exists already
            if strcmp(BackCell{i+1,4},BackCell{j,4})
                BackCell{i+1,end}=BackCell{j,end};
                flag=1;
                break
            end % if strcmp(BackCell{i,4},BackCell{j,4})
        end % for j=i:-1:1 % check if ID exists already
        if flag==0
            BackCell{i+1,end}=maxBID+1;
            maxBID=BackCell{i+1,end};
            PosBack(end+1,1)=str2double(BackCell{i+1,2});
            PosBack(end,2)=str2double(BackCell{i+1,3});
            idxBack(end+1)=i+1;
        end % if flag==0
    end % if strcmp(BackCell{i,4},BackCell{i+1,4})
end % for i=1:size(BackCell,1)-1
%% Matching indices (adding the 11th column)
t=1;s=1;
h = waitbar(0,'Matching back and main indices');
for i=1:size(PosMain,1)
    if i<size(PosMain,1)
        for j=1:size(BackCell,1)
            if str2double(BackCell{j,6})>PosMain(i,1)...
                    && str2double(BackCell{j,6})<PosMain(i+1,1)...
                    && str2double(BackCell{j,6})<PosMain(i,2)
                flag=0;
                for k=1:size(MainCell,1)
                    if strcmp(MainCell{k,8},BackCell{j,8})
                        MatchPair(t,1)=k; MatchPair(t,2)=j;
                        BackCell{j,11}=MainCell{k,10};
                        MainCell{k,11}=BackCell{j,10};
                        t=t+1;
                        flag=1;
                        break
                    end % if strcmp(MainCell{k,8},BackCell{j,8})
                end % for k=1:size(MainCell,1)
                if flag==0
                    unMatched(s)=j;
                    s=s+1;
                end % if flag==1
            end % if str2double(BackCell{j,6})>PosMain(i,1)...
        end % for j=1:size(BackCell,1)
    else %  i>size(PosMain,1)
        for j=1:size(BackCell,1)
            if str2double(BackCell{j,6})>PosMain(i,1)...
                    && str2double(BackCell{j,6})<PosMain(i,2)
                flag=0;
                for k=1:size(MainCell,1)
                    if strcmp(MainCell{k,8},BackCell{j,8})
                        MatchPair(t,1)=k; MatchPair(t,2)=j;
                        BackCell{j,11}=MainCell{k,10};
                        MainCell{k,11}=BackCell{j,10};
                        t=t+1;
                        flag=1;
                        break
                    end % if strcmp(MainCell{k,8},BackCell{j,8})
                end % for k=1:size(MainCell,1)
                if flag==0
                    unMatched(s)=j;
                    s=s+1;
                end % if flag==1
            end % if str2double(BackCell{j,6})>PosMain(i,1)...
        end % for j=1:size(BackCell,1)
    end % if i<size(PosMain,1)
    waitbar(i/size(PosMain,1))
end % for i=1:size(PosMain,1)
close(h)
%% Fix boundaries
h = waitbar(0,'Please wait, fixing MainStreet boundaries indices');
for i=1:size(MainCell,1)
    flag=0;
    if isempty(MainCell{i,11})
        for j=1:size(BackCell,1)
            if str2double(MainCell{i,6})>=str2double(BackCell{j,2}) &&...
                    str2double(MainCell{i,7})<=str2double(BackCell{j,3}) && flag==0
                MainCell{i,11}=BackCell{j,10};
                flag=1;
            end % if str2double(MainCell{i,6})>=str2double(BackCell{j,2}) &&...
        end % for j=1:size(BackCell,1)
        if flag==0 && i~=1
            if MainCell{i,10}==MainCell{i-1,10}
                MainCell{i,11}=MainCell{i-1,11};
            else % if MainCell{i,10}~=MainCell{i-1,10}
                flag2=0;
                for t=i-1:-1:1
                    if strcmp(MainCell{t,4},MainCell{i,4}) && flag2==0
                        MainCell{i,11}=MainCell{t,11};
                        flag2=1;
                        break 
                    end % if MainCell{t,4}==MainCell{i,4} && flag2==0
                end % for t=i-1:-1:1
                if flag2==0
                MainCell{i,11}=maxBID+1;
                maxBID=maxBID+1;
                end % if flag2==0
            end % if MainCell{i,10}==MainCell{i-1,10}
        elseif i==1 && flag==0
            MainCell{i,11}=maxBID+1;
            maxBID=maxBID+1;
        end % if flag==0
    end % if isempty(MainCell{i,11})
    waitbar(i/size(MainCell,1))
end % for i=1:size(MainCell,1)
close(h)

maxMID=MainCell{end,10};
h = waitbar(0,'Please wait, fixing BackStreet boundaries indices');
for i=1:size(BackCell,1)
    flag=0;
    if isempty(BackCell{i,11})
        for j=1:size(MainCell,1)
            if str2double(BackCell{i,6})>=str2double(MainCell{j,2}) &&...
                    str2double(BackCell{i,7})<=str2double(MainCell{j,3}) && flag==0
                BackCell{i,11}=MainCell{j,10};
                flag=1;
            end % if str2double(MainCell{i,6})>=str2double(BackCell{j,2}) &&...
        end % for j=1:size(BackCell,1)
        if flag==0 && i~=1
            if BackCell{i,10}==BackCell{i-1,10}
                BackCell{i,11}=BackCell{i-1,11};
            else % if BackCell{i,10}~=BackCell{i-1,10}
                flag2=0;
                for t=i-1:-1:1
                    if strcmp(BackCell{t,4},BackCell{i,4}) && flag2==0
                        BackCell{i,11}=BackCell{t,11};
                        flag2=1;
                        break 
                    end % if MainCell{t,4}==MainCell{i,4} && flag2==0
                end % for t=i-1:-1:1
                if flag2==0
                BackCell{i,11}=maxBID+1;
                maxBID=maxBID+1;
                end % if flag2==0
            end % if MainCell{i,10}==MainCell{i-1,10}
        elseif i==1 && flag==0
            BackCell{i,11}=maxBID+1;
            maxBID=maxBID+1;
        end % if flag==0
    end % if isempty(MainCell{i,11})
    waitbar(i/size(BackCell,1))
end % for i=1:size(MainCell,1)
close(h)

for i=1:size(MainCell,1) % find number of distinguished indices
    MToes(i)=(MainCell{i,10});
    BToes(i)=(MainCell{i,11});
end

for i=1:size(BackCell,1) % find number of distinguished indices
    MToes(end+1)=(BackCell{i,11});
    BToes(end+1)=(BackCell{i,10});
end

BToes=unique(BToes,'stable');
MToes=unique(MToes,'stable');
BToes_Len=length(BToes);
MToes_Len=length(MToes);
%% Find max ID
maxBC=0;
for i=1:size(BackCell,1)
    if BackCell{i,10}>maxBC
        maxBC=BackCell{i,10};
    end
end

maxMC=0;
for i=1:size(MainCell,1)
    if MainCell{i,10}>maxMC
        maxMC=MainCell{i,10};
    end
end
%% Assign streets
BFlag=1; MFlag=1; PrF=MaxAvoid; PrR=MaxAvoid; p=1; q=1;
IFlag=0; rflag=0; fflag=0;

h = waitbar(0,'Assigning Streets');
for i=1:size(MainCell,1)
    if max(PrR(:))>=max(PrF(:))
        StartToe=max(PrR(:));
    else
        StartToe=max(PrF(:));
    end
    if BFlag==0 && MFlag==0
        OligoPaints{i,:}=strcat(ReverseComplement(Toes(PrF(end),:),1),MainCell{i,8},ReverseComplement(Toes(PrR(end),:),1));
        OPCords(i,1)=str2double(MainCell{i,6});
        OPCords(i,2)=str2double(MainCell{i,7});
    elseif BFlag==0 && MFlag==1
        if fflag==0
            flag=0;
            for j=StartToe+1:size(PairsMat,1)
                if PairsMat(PrR(end),j)<=3 && flag==0
                    OligoPaints{i,:}=strcat(ReverseComplement(Toes(j,:),1),MainCell{i,8},ReverseComplement(Toes(PrR(end),:),1));
                    OPCords(i,1)=str2double(MainCell{i,6});
                    OPCords(i,2)=str2double(MainCell{i,7});
                    PrF(p)=j;
                    p=p+1;
                    flag=1;
                    break
                end % if PairsMat(PrR(end),j)<=3 && flag==0
            end % for j=StartToe+1:size(PairsMat,1)
        else % fflag==1
            OligoPaints{i,:}=strcat(ReverseComplement(Toes(PrF(end),:),1),MainCell{i,8},ReverseComplement(Toes(PrR(end),:),1));
            OPCords(i,1)=str2double(MainCell{i,6});
            OPCords(i,2)=str2double(MainCell{i,7});
        end % if fflag==0
    elseif BFlag==1 && MFlag==0
        flag=0;
        if IFlag==1 && rflag==1
            OligoPaints{i,:}=strcat(ReverseComplement(Toes(PrF(end),:),1),MainCell{i,8},ReverseComplement(Toes(PrR(end),:),1));
            OPCords(i,1)=str2double(MainCell{i,6});
            OPCords(i,2)=str2double(MainCell{i,7});
            flag=1;
        else % IFlag==0
            for k=StartToe+1:size(PairsMat,1)
                if PairsMat(PrF(end),k)<=3 && flag==0
                    OligoPaints{i,:}=strcat(ReverseComplement(Toes(PrF(end),:),1),MainCell{i,8},ReverseComplement(Toes(k,:),1));
                    OPCords(i,1)=str2double(MainCell{i,6});
                    OPCords(i,2)=str2double(MainCell{i,7});
                    PrR(end+1)=k;
                    q=size(PrR,2)+1;
                    flag=1;
                end
            end
        end % if IFlag==1
    elseif BFlag==1 && MFlag==1
        flag=0;
        if IFlag==1 && rflag==1 && fflag==1
            OligoPaints{i,:}=strcat(ReverseComplement(Toes(PrF(end),:),1),MainCell{i,8},ReverseComplement(Toes(PrR(end),:),1));
            OPCords(i,1)=str2double(MainCell{i,6});
            OPCords(i,2)=str2double(MainCell{i,7});
        elseif IFlag==1 && rflag==0 && fflag==1
            for j=StartToe+1:size(PairsMat,1)
                if PairsMat(PrF(end),j)<=3 && flag==0
                    OligoPaints{i,:}=strcat(ReverseComplement(Toes(PrF(end),:),1),MainCell{i,8},ReverseComplement(Toes(j,:),1));
                    OPCords(i,1)=str2double(MainCell{i,6});
                    OPCords(i,2)=str2double(MainCell{i,7});
                    PrR(end+1)=j;
                    q=size(PrR,2)+1;
                    flag=1;
                    break
                end % if PairsMat(j,repR_idx)<=3 && flag==0
            end % for j=StartToe+1:size(PairsMat,1)
        elseif IFlag==1 && rflag==1 && fflag==0
            for j=StartToe+1:size(PairsMat,1)
                if PairsMat(j,PrR(end))<=3 && flag==0
                    OligoPaints{i,:}=strcat(ReverseComplement(Toes(j,:),1),MainCell{i,8},ReverseComplement(Toes(PrR(end),:),1));
                    OPCords(i,1)=str2double(MainCell{i,6});
                    OPCords(i,2)=str2double(MainCell{i,7});
                    flag=1;
                    PrF(end+1)=j;
                    p=size(PrF,2)+1;
                    break
                end % if PairsMat(j,repR_idx)<=3 && flag==0
            end % for j=StartToe+1:size(PairsMat,1)
            if flag==0
                for j=StartToe+1:size(PairsMat,1)
                    if PairsMat(PrR(end),j)<=3 && flag==0
                        OligoPaints{i,:}=strcat(ReverseComplement(Toes(j,:),1),MainCell{i,8},ReverseComplement(Toes(PrR(end),:),1));
                        OPCords(i,1)=str2double(MainCell{i,6});
                        OPCords(i,2)=str2double(MainCell{i,7});
                        flag=1;
                        PrF(end+1)=j;
                        p=size(PrF,2)+1;
                        break
                    end % if PairsMat(j,repR_idx)<=3 && flag==0
                end % for j=StartToe+1:size(PairsMat,1)
            end % if flag==0
        elseif IFlag==0
            for j=StartToe+1:size(PairsMat,1)-1
                for k=StartToe+2:size(PairsMat,1)
                    if PairsMat(j,k)<=3 && flag==0
                        PrF(p)=j; PrR(q)=k;
                        p=size(PrF,2)+1; q=size(PrR,2)+1;
                        flag=1;
                        break
                    end % if PairsMat(j,k)<=3 && flag==0
                end % for k=StartToe+2:size(PairsMat,1)
            end % for j=StartToe+1:size(PairsMat,1)-1
            OligoPaints{i,:}=strcat(ReverseComplement(Toes(PrF(end),:),1),MainCell{i,8},ReverseComplement(Toes(PrR(end),:),1));
            OPCords(i,1)=str2double(MainCell{i,6});
            OPCords(i,2)=str2double(MainCell{i,7});
        end % if IFlag==1 && rflag==1
    end % if BFlag==0 && MFlag==0
    if i~=size(MainCell,1)
        if MainCell{i,10}~=MainCell{i+1,10} && MainCell{i,11}==MainCell{i+1,11}
            MFlag=1; BFlag=0; IFlag=0; fflag=0; rflag=0;
            for t=i:-1:1
                if MainCell{i+1,10}==MainCell{t,10} && fflag==0
                    for l=1:StartToe
                        if strcmp(OligoPaints{t,1}(1:27),ReverseComplement(Toes(l,:),1))
                            PrF(end+1)=l;
                            p=size(PrF,2)+1;
                            IFlag=1; fflag=1;
                            break
                        end % if strcmp(OligoPaints{t,1}(1:27),Toes(l,:))
                    end % for l=1:size(Toes,1)
                end % tflag==0
            end % for t=i:-1:1
        elseif MainCell{i,10}==MainCell{i+1,10} && MainCell{i,11}~=MainCell{i+1,11}
            BFlag=1; MFlag=0; rflag=0; fflag=0;
            for t=i:-1:1
                if MainCell{i+1,11}==MainCell{t,11} && rflag==0
                    for l=1:StartToe
                        if strcmp(OligoPaints{t,1}(end-26:end),ReverseComplement(Toes(l,:),1))
                            IFlag=1; rflag=1;
                            PrR(end+1)=l;
                            q=size(PrR,2)+1;
                            break
                        end % if strcmp(OligoPaints{t,1}(end-46:end-20),Toes(l,:))
                    end % for l=1:size(PairsMat,1)
                end % if MainCell{i+1,11}==MainCell{t,11} && tflag==0
            end % for t=i:-1:1
        elseif MainCell{i,10}~=MainCell{i+1,10} && MainCell{i,11}~=MainCell{i+1,11}
            MFlag=1; BFlag=1; fflag=0; rflag=0; IFlag=0;
            for t=i:-1:1
                if MainCell{i+1,11}==MainCell{t,11} && rflag==0
                    for l=1:StartToe
                        if strcmp(OligoPaints{t,1}(end-26:end),ReverseComplement(Toes(l,:),1))
                            IFlag=1; rflag=1;
                            PrR(end+1)=l;
                            q=size(PrR,2)+1;
                            break
                        end % if strcmp(OligoPaints{t,1}(end-46:end-20),Toes(l,:))
                    end % for l=1:StartToe
                end % if MainCell{i+1,11}==MainCell{t,11} && rflag==0
                if MainCell{i+1,10}==MainCell{t,10} && fflag==0
                    for l=1:StartToe
                        if strcmp(OligoPaints{t,1}(1:27),ReverseComplement(Toes(l,:),1))
                            IFlag=1; fflag=1;
                            PrF(end+1)=l;
                            p=size(PrF,2)+1;
                            break
                        end % if strcmp(OligoPaints{t,1}(1:27),ReverseComplement(Toes(l,:),1))
                    end % for l=1:StartToe
                end % if MainCell{i+1,10}==MainCell{t,10} && fflag==0
            end % for t=i:-1:1
        elseif MainCell{i,10}==MainCell{i+1,10} && MainCell{i,11}==MainCell{i+1,11}
            BFlag=0; MFlag=0; IFlag=0; rflag=0; fflag=0;
        end % if MainCell{i,10}~=MainCell{i+1,10} && MainCell{i,11}==MainCell{i+1,11}
        waitbar(i/(size(MainCell,1)-1))
    end % if I~=size(MainCell,1)
end % for i=1:size(MainCell,1)-1
close(h)
%% Assign BackStrees with no MainStreet ID - finding doubles
k=1; t=1;
h = waitbar(0,'Finding doubles');
for i=1:size(BackCell,1)
    for j=1:size(MainCell,1)
        if strcmp(BackCell{i,8},MainCell{j,8})
            BisM(k)=i;
            MisB(t)=j;
            k=k+1;
            t=t+1;
        end
    end
    waitbar(i/size(BackCell,1))
end
close(h)
for i=1:size(MainCell,1)
    mainUnique(i)=MainCell{i,10};
    BackinMain(i)=MainCell{i,11};
end
mainUnique=unique(mainUnique,'stable');
BackinMain=unique(BackinMain,'stable');

%% Assign BackStrees with no MainStreet ID
h = waitbar(0,'Assigning Streets with no MainStreet ID');
BFlag=1; MFlag=1;
for i=1:size(BackCell,1)
    if i~=BisM % to avoid duplicates
        if ~exist('iIDX','var')
            iIDX=i;
        end % if ~exist('iIDX','var')
        if sum(i-1==BisM)>0
            if i~=size(BackCell,1)
                if BackCell{i,10}==BackCell{iIDX,10} && BackCell{i,11}==BackCell{iIDX,11}
                    BFlag=0; MFlag=0;
                elseif BackCell{i,10}~=BackCell{iIDX,10} && BackCell{i,11}==BackCell{iIDX,11}
                    BFlag=1; MFlag=0;
                elseif BackCell{i,10}==BackCell{iIDX,10} && BackCell{i,11}~=BackCell{iIDX,11}
                    BFlag=0; MFlag=1;
                elseif BackCell{i,10}~=BackCell{iIDX,10} && BackCell{i,11}~=BackCell{iIDX,11}
                    BFlag=1; MFlag=1;
                end % if BackCell{i,10}~=BackCell{i+1,10} && BackCell{i,11}==BackCell{i+1,11}
            end % if i~=size(BackCell,1)
        end % if sum(i-1==BisM)>0
        if max(PrR(:))>=max(PrF(:))
            StartToe=max(PrR(:));
        else
            StartToe=max(PrF(:));
        end % if max(PrR(:))>=max(PrF(:))
        if isempty(BackCell(BackCell{i,11}==mainUnique))
            if BFlag==1 && MFlag==1
                flag=0;
                for j=1:size(MainCell,1)
                    if BackCell{i,10}==MainCell{j,11} && flag==0 % Does backstreet ID exist
                        [r,c]=find(BackinMain==MainCell{j,11},1); % find unique index of ID to find it's PrR position
                        PrRunique=unique(PrR,'stable');
                        PrR(end+1)=PrRunique(c);
                        flag=1;
                        break
                    end % if BackCell{i,10}==MainCell{j,11} && flag==0 % Does backstreet ID exist
                end % for j=1:size(MainCell,1)
                if flag==1
                    flag2=0;
                    for j=StartToe+1:size(PairsMat,1)
                        if PairsMat(PrR(end),j)<=3 && flag2==0
                            PrF(end+1)=j;
                            flag2=1;
                            break
                        end % if PairsMat(PrR(end),k)<=3 && flag2==0
                    end % for j=StartToe+1:size(PairsMat,1)
                elseif flag==0
                    for j=StartToe+1:size(PairsMat,1)-1
                        for k=StartToe+2:size(PairsMat,1)
                            if PairsMat(j,k)<=3 && flag==0
                                PrF(end+1)=j; PrR(end+1)=k;
                                flag=1;
                                break
                            end % if PairsMat(j,k)<=3 && flag==0
                        end % for k=StartToe+2:size(PairsMat,1)
                    end % for j=StartToe+1:size(PairsMat,1)-1
                end % if flag==0
                OligoPaints{end+1,:}=strcat(ReverseComplement(Toes(PrF(end),:),1),BackCell{i,8},ReverseComplement(Toes(PrR(end),:),1));
                OPCords(end+1,1)=str2double(BackCell{i,6});
                OPCords(end,2)=str2double(BackCell{i,7});
            else % BFlag~=1 && MFlag~=1
                OligoPaints{end+1,:}=strcat(ReverseComplement(Toes(PrF(end),:),1),BackCell{i,8},ReverseComplement(Toes(PrR(end),:),1));
                OPCords(end+1,1)=str2double(BackCell{i,6});
                OPCords(end,2)=str2double(BackCell{i,7});
            end % if BFlag==1 && MFlag==1
            if i~=size(BackCell,1)
                if BackCell{i+1,10}==BackCell{i,10} && BackCell{i+1,11}==BackCell{i,11}
                    MFlag=0; BFlag=0;
                elseif BackCell{i+1,10}==BackCell{i,10} && BackCell{i+1,11}~=BackCell{i,11}
                    MFlag=1; BFlag=0;
                    for t=i:-1:1
                        if BackCell{i+1,11}==BackCell{t,11} && fflag==0
                            for l=1:StartToe
                                if strcmp(OligoPaints{t,1}(1:27),ReverseComplement(Toes(l,:),1))
                                    PrF(end+1)=l;
                                    p=size(PrF,2)+1;
                                    fflag=1;
                                    break
                                end % if strcmp(OligoPaints{t,1}(1:27),Toes(l,:))
                            end % for l=1:size(Toes,1)
                        end % if BackCell{i+1,11}==BackCell{t,11} && fflag==0
                    end % for t=i:-1:1
                elseif BackCell{i+1,10}~=BackCell{i,10} && BackCell{i+1,11}==BackCell{i,11}
                    MFlag=0; BFlag=1;
                    flag=0;
                    for j=1:size(MainCell,1)
                        if BackCell{i,10}==MainCell{j,11} && flag==0 % Does backstreet ID exist
                            [r,c]=find(BackinMain==MainCell{j,11},1); % find unique index of ID to find it's PrR position
                            PrRunique=unique(PrR,'stable');
                            PrR(end+1)=PrRunique(c);
                            flag=1;
                            break
                        end % if BackCell{i,10}==MainCell{j,11} && flag==0 % Does backstreet ID exist
                    end % for j=1:size(MainCell,1)
                elseif BackCell{i+1,10}~=BackCell{i,10} && BackCell{i+1,11}~=BackCell{i,11}
                    BFlag=1; MFlag=1;
                end % if BackCell{i+1,10}==BackCell{i,10} && BackCell{i+1,11}==BackCell{i,11}
            end % if i~=size(BackCell,1)
        else % ~isempty(BackCell(BackCell{i,11}==mainUnique)) % MainStreet already exists
            if BFlag==1 && MFlag==1
                [r,c]=find(mainUnique==BackCell{i,11},1);
                PrFunique=unique(PrF,'stable');
                PrF(end+1)=PrFunique(c);
                flag=0;
                for j=1:size(MainCell,1)
                    if BackCell{i,10}==MainCell{j,11} && flag==0 % Does backstreet ID exist
                        [r,c]=find(BackinMain==MainCell{j,11},1); % find unique index of ID to find it's PrR position
                        PrRunique=unique(PrR,'stable');
                        PrR(end+1)=PrRunique(c);
                        flag=1;
                        break
                    end % if BackCell{i,10}==MainCell{j,11} && flag==0 % Does backstreet ID exist
                end % for j=1:size(MainCell,1)
                if flag==0
                    for k=StartToe+1:size(PairsMat,1)
                        if PairsMat(PrF(end),k)<=3 && flag==0
                            PrR(end+1)=k;
                            flag=1;
                            break
                        end % if PairsMat(j,k)<=3 && flag==0
                    end % for k=StartToe+2:size(PairsMat,1)
                end % if flag==0
            elseif BFlag==0 && MFlag==1
                [r,c]=find(mainUnique==BackCell{i,11},1);
                PrFunique=unique(PrF,'stable');
                PrF(end+1)=PrFunique(c);
            elseif BFlag==1 && MFlag==0
                for j=1:size(MainCell,1)
                    if BackCell{i,10}==MainCell{j,11} && flag==0 % Does backstreet ID exist
                        [r,c]=find(BackinMain==MainCell{j,11},1); % find unique index of ID to find it's PrR position
                        PrRunique=unique(PrR,'stable');
                        PrR(end+1)=PrRunique(c);
                        flag=1;
                        break
                    end % if BackCell{i,10}==MainCell{j,11} && flag==0 % Does backstreet ID exist
                end % for j=1:size(MainCell,1)
                if flag==0
                    for k=StartToe+1:size(PairsMat,1)
                        if PairsMat(PrF(end),k)<=3 && flag==0
                            PrR(end+1)=k;
                            flag=1;
                            break
                        end % if PairsMat(j,k)<=3 && flag==0
                    end % for k=StartToe+2:size(PairsMat,1)
                end % if flag==0
            end % if BFlag==1 && MFlag==1
            OligoPaints{end+1,:}=strcat(ReverseComplement(Toes(PrF(end),:),1),BackCell{i,8},ReverseComplement(Toes(PrR(end),:),1));
            OPCords(end+1,1)=str2double(BackCell{i,6});
            OPCords(end,2)=str2double(BackCell{i,7});
            if i~=size(BackCell,1)
                if BackCell{i,10}==BackCell{i+1,10} && BackCell{i,11}==BackCell{i+1,11}
                    BFlag=0; MFlag=0;
                elseif BackCell{i,10}~=BackCell{i+1,10} && BackCell{i,11}==BackCell{i+1,11}
                    BFlag=1; MFlag=0;
                elseif BackCell{i,10}==BackCell{i+1,10} && BackCell{i,11}~=BackCell{i+1,11}
                    BFlag=0; MFlag=1;
                elseif BackCell{i,10}~=BackCell{i+1,10} && BackCell{i,11}~=BackCell{i+1,11}
                    BFlag=1; MFlag=1;
                end % if BackCell{i,10}~=BackCell{i+1,10} && BackCell{i,11}==BackCell{i+1,11}
            end % if i~=size(BackCell,1)
        end % if isempty(BackCell(BackCell{i,11}==mainUnique)) % check if there is no mainstreet
    iIDX=i;
    end % if i~=BisM % to avoid duplicates
    waitbar(i/size(BackCell,1))
end
close(h)
%% Add universal
if exist('UniF','var')
    for i=1:size(OligoPaints,1)
        OligoPaints{i,:}=strcat(Streets(UniF,:),OligoPaints{i,:},ReverseComplement(Streets(UniR,:),1));
    end % for i=1:size(OligoPaints,1)
    UniversalMS=Streets(UniF,:);
    U_MS_N=cat(2,PrF,UniF);
    UniversalBS=Streets(UniR,:);
    U_BS_N=cat(2,PrR,UniR);
else
    if max(PrR(:))>=max(PrF(:))
        StartToe=max(PrR(:));
    else
        StartToe=max(PrF(:));
    end % if max(PrR(:))>=max(PrF(:))
    flag=0;
    while flag==0
        for j=StartToe+1:size(PairsMat,1)-1
            for k=StartToe+2:size(PairsMat,1)
                if PairsMat(j,k)<=3 && flag==0
                    PrF(end+1)=j; PrR(end+1)=k;
                    flag=1;
                end % if PairsMat(j,k)<=3 && flag==0
            end % for k=PrR+1:size(PairsMat,1)
        end % for j=PrF+1:size(PairsMat,1)-1
    end % while
    for i=1:size(OligoPaints,1)
        OligoPaints{i,:}=strcat(Streets(PrF(end),:),OligoPaints{i,:},ReverseComplement(Streets(PrR(end),:),1));
    end % for i=1:size(OligoPaints,1)
    UniversalMS=Streets(PrF(end),:); % Forward primer sequence
    U_MS_N=PrF;
    UniversalBS=Streets(PrR(end),:); % Reverse primer sequence
    U_BS_N=PrR;
end % if exists('UniF','var')
%% Sort Oligopaints probes by starting coordinate (min to max)
%{
h=waitbar(0,'Sorting Oligopaints probes by starting coordinate, min to max, please wait');
for i=1:size(OligoPaints,1)
    find(min(OPCords(:,1),[],2),1);
end
%}
%% Find Toes chosen
k=1; s=1; t=1; l=1;
h = waitbar(0,'Finding Toes chosen');
for i=1:size(OligoPaints,1)
    for j=1:size(Toes,1)
        if strcmp(OligoPaints{i,1}(21:47),ReverseComplement(Toes(j,:),1))
            ToeMain(k)=j;
            k=k+1;
            if ~exist('OligoMain','var')
                OligoMain(t)=i;
                OligoSeqMain(t,:)=OligoPaints{i,1}(21:47);
                t=t+1;
            elseif ~strcmp(OligoPaints{i,1}(21:47),OligoSeqMain(t-1,:))
                OligoMain(t)=i;
                OligoSeqMain(t,:)=OligoPaints{i,1}(21:47);
                t=t+1;
            end
        end
        if strcmp(OligoPaints{i,1}(end-46:end-20),ReverseComplement(Toes(j,:),1))
            ToeBack(s)=j;
            s=s+1;
            if ~exist('OligoBack','var')
                OligoBack(l)=i;
                OligoSeqBack(l,:)=OligoPaints{i,1}(end-46:end-20);
                l=l+1;
            elseif ~strcmp(OligoPaints{i,1}(end-46:end-20),OligoSeqBack(l-1,:))
                OligoBack(l)=i;
                OligoSeqBack(l,:)=OligoPaints{i,1}(end-46:end-20);
                l=l+1;
            end
        end
    end
    waitbar(i/size(OligoPaints,1))
end
close(h)
ToeMain=unique(ToeMain,'stable');
ToeBack=unique(ToeBack,'stable');
%% Check that Toes are at least 2nt different
ToeChosen=[];
if ~exist('UniF','var')
    ToeChosen=cat(2,ToeMain,ToeBack,PrF(end),PrR(end));
else
    ToeChosen=cat(2,ToeMain,ToeBack,UniF,UniR);
end % if ~exist('UniF','var')
k=1;
for i=1:size(ToeChosen,2)-1
    for j=i+1:size(ToeChosen,2)
        if sum(Toes(ToeChosen(i),:)==Toes(ToeChosen(j),:))>25
            ToeSame(k,:)=Toes(i,:);
            idx(k,1)=i; idx(k,2)=j;
            k=k+1;
        end
    end
end
if k>1
    errordlg(['You have ',num2str(k),' toes with 2 or less nt difference'])
end % if k>1
%% Find density of probes
Bcounts=zeros(1,maxBC);
BcountsID=zeros(2,maxBC);
BcountsID(1,1:maxBC)=str2double(BackCell{end,3});
t=1;
for i=1:size(BackCell,1)
    Bcounts(BackCell{i,10})=Bcounts(BackCell{i,10})+1;
    if BcountsID(1,BackCell{i,10})>str2double(BackCell{i,2})
        BcountsID(1,BackCell{i,10})=str2double(BackCell{i,2});
    end
    if BcountsID(2,BackCell{i,10})<str2double(BackCell{i,3})
        BcountsID(2,BackCell{i,10})=str2double(BackCell{i,3});
        flag=0;
        if t>1
            for s=size(BSReg,1):-1:1
                if strcmp(BSReg{s,1},BackCell{i,4})
                    flag=1;
                end % if strcmp(MSReg{t,1},MainCell{i,4})
            end % for t=i-1:-1:1
        end % if t>1
        if flag==0
            BSReg{t,1}=BackCell{i,4};
            t=t+1;
        end % if flag==0
    end % if BcountsID(2,BackCell{i,10})<str2double(BackCell{i,3})
end % for i=1:size(BackCell,1)
Bcounts=Bcounts(BackCell{1,10}:end);
BcountsID=BcountsID(:,BackCell{1,10}:end);
BcountsID(3,:)=(BcountsID(2,:)-BcountsID(1,:))./1000;
BProbesPerKb=Bcounts./BcountsID(3,:);

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
MinNFluor=200;
OPLength=nan(size(Bcounts,2),1); AfterSize=OPLength; BeforeSize=OPLength;
h=waitbar(0,'Add T to small regions with varying probe length (<200 fluorophores)');
for i=1:size(Bcounts,2)
    t=1;
    if Bcounts(i)<MinNFluor
        flag=0;
        for k=1:size(MainCell,1)
            if str2double(MainCell{k,6})>=BcountsID(1,i) && str2double(MainCell{k,7})<=BcountsID(2,i)
                for j=1:size(OligoPaints,1)
                    if strcmp(OligoPaints{j,1}(48:end-47),MainCell{k,8}) && flag==0
                        OPLength(i,t)=length(MainCell{k,8});
                        extendIdx(i,t)=j;
                        t=t+1;
                        flag=1;
                        break
                    end % if strcmp(OligoPaints{j,1}(48:end-47),MainCell{k,8})
                end % for j=1:size(OligoPaints,1)
            elseif str2double(MainCell{k,7})>BcountsID(2,i)
                break
            end % if str2double(MainCell{k,6})>=BcountsID(i,1) && str2double(MainCell{k,7})<=BcountsID(i,1)
        end % for k=1:size(MainCell,1)
        MaxOP=max(OPLength(i,:));
        for t=1:size(OPLength,2)
            LenDiff=MaxOP-OPLength(i,t);
            if LenDiff>0 && OPLength(i,t)~=0 && ~isnan(OPLength(i,t))
                BeforeSize(i,t)=size(OligoPaints{extendIdx(i,t),1},2);
                for k=1:2:LenDiff
                    OligoPaints{extendIdx(i,t),1}=strcat(OligoPaints{extendIdx(i,t),1}(1:20),'T',OligoPaints{extendIdx(i,t),1}(21:end));
                    if k+1<=LenDiff
                        OligoPaints{extendIdx(i,t),1}=strcat(OligoPaints{extendIdx(i,t),1}(1:end-20),'T',OligoPaints{extendIdx(i,t),1}(end-19:end));
                    else
                        break
                    end % if k+1<=LenDiff
                end % for k=1:2:LenDiff
                AfterSize(i,t)=size(OligoPaints{extendIdx(i,t),1},2);
            end % if LenDiff>0
        end % for t=1:length(OPLength)
    end % if Bcounts(i)<MinNFluor
    if exist('AfterSize','var')
        if sum(AfterSize(i,:))>0
            AS=AfterSize(i,:); AS=AS(AS~=0);
            BS=BeforeSize(i,:); BS=BS(BS~=0);
            figure(); hist(BS,7);
            figure(); hist(AS,3);
        end
    end
    waitbar(i/size(Bcounts,2))
end % for i=1:size(Bcounts,2)
close(h)
%% Length distribution
OligoSize=zeros(size(OligoPaints,1),1);
for i=1:size(OligoPaints,1)
    OligoSize(i)=length(OligoPaints{i,1});
end
figure(); hist(OligoSize,7)
saveas(gcf,[SavePath,'LibraryLengthHistogram.png'])
[counts,bins]=hist(OligoSize,7);
%% Check probes per Toe
CountToeBack=zeros(size(ToeBack,1),size(ToeBack,2));
h=waitbar(0,'Counting probes per BackToe');
for i=1:size(ToeBack,2)
    for j=1:size(OligoPaints,1)
        if strcmp(OligoPaints{j,1}(end-46:end-20),ReverseComplement(Toes(ToeBack(i),:),1))
            CountToeBack(i)=CountToeBack(i)+1; % the order of CountToeBack will be first backstreets from maincell and then from backcell
        end % if strcmp(OligoPaints{j,1}(end-46:end-20),ReverseComplement(Toes(ToeBack(i),:),1))
    end % for j=1:size(OligoPaints,1)
    waitbar(i/size(ToeBack,1))
end % for i=1:size(ToeBack,2)
close(h)

CountToeMain=zeros(size(ToeMain,1),size(ToeMain,2));
h=waitbar(0,'Counting probes per MainToe');
for i=1:size(ToeMain,2)
    for j=1:size(OligoPaints,1)
        if strcmp(OligoPaints{j,1}(21:47),ReverseComplement(Toes(ToeMain(i),:),1))
            CountToeMain(i)=CountToeMain(i)+1;
        end % if strcmp(OligoPaints{j,1}(end-46:end-20),ReverseComplement(Toes(ToeBack(i),:),1))
    end % for j=1:size(OligoPaints,1)
    waitbar(i/size(ToeMain,1))
end % for i=1:size(ToeBack,2)
close(h)
%% Print to file
BIDList(1)=MainCell{1,11};
k=1;
for i=1:size(MToes,2)
    flag=0;
    for j=1:size(MainCell,1)
        if MainCell{j,10}==MToes(i) && flag==0
            uniqueMIDs{k,1}=MainCell{j,4};
            MToeMain(k)=MToes(i);
            k=k+1;
            flag=1;
            if i~=size(MainCell,1)
                if MainCell{i,11}~=MainCell{i+1,11}
                    BIDList(s)=MainCell{i+1,11};
                    s=s+1;
                end % if MainCell{i,11}~=MainCell{i+1,11}
            end % if i~=size(MainCell,1)
            break
        end % if MainCell{j,10}==MToes(i) && flag==0
    end % for j=1:size(MainCell,1)
end % for i=1:size(MToes,2)

if size(uniqueMIDs,1)<length(MToes)
    temp=cell(size(MToes,2),size(MToes,1));
    NumMToesNotInMCell=length(MToes)-size(uniqueMIDs,1);
    for i=1:length(MToes)
        if MToes(i)~=MToeMain
            flag=0;
            for j=1:size(BackCell,1)
                if BackCell{j,11}==MToes(i) && flag==0
                    temp{i,1}=BackCell{j,4};
                    flag=1;
                    break
                end % if BackCell{j,11}==MToes(i) && flag==0
            end % for j=1:size(BackCell,1)
        end % if MToes(i)~=MToeMain
    end % for i=1:length(MToes)
    k=1;
    for i=1:size(temp,1)
        if isempty(temp{i,1})
            temp{i,1}=uniqueMIDs{k,1};
            k=k+1;
        end % if isempty(temp{i,1})
    end % for i=1:size(temp,1)
    clear uniqueMIDs 
    uniqueMIDs=temp;
    clear temp 
end % if size(uniqueMIDs,1)<length(MToes)

k=1;
BCord=zeros(length(BToes),2);
for i=1:size(BToes,2)
    flag=0;
    for j=1:size(BackCell,1)
        if BackCell{j,10}==BToes(i) && flag==0
            BCord(k,1)=str2double(BackCell{j,6});
            BCord(k,2)=str2double(BackCell{j,7});
            uniqueBIDs{k,1}=BackCell{j,4};
            BToeBack(k)=BToes(i);
            k=k+1;
            flag=1;
            break
        end % if BackCell{j,10}==BToes(i) && flag==0
    end % for j=1:size(BackCell,1)
end % for i=1:size(BToes,2)

if size(uniqueBIDs,1)<length(BToes)
    temp=cell(size(BToes,2),size(BToes,1));
    NumBToesNotInBCell=length(BToes)-size(uniqueBIDs,1);
    for i=1:length(BToes)
        if BToes(i)~=BToeBack
            flag=0;
            for j=1:size(MainCell,1)
                if MainCell{j,11}==BToes(i) && flag==0
                    temp{i,1}=MainCell{j,4};
                    tempBCord(i,1)=str2double(MainCell{j,6});
                    tempBCord(i,2)=str2double(MainCell{j,7});
                    flag=1;
                    break
                end % if MainCell{j,11}==BToes(i) && flag==0
            end % for j=1:size(MainCell,1)
        end % if BToes(i)~=BToeBack
    end % for i=1:length(BToes)
    k=1;
    for i=1:size(temp,1)
        if isempty(temp{i,1})
            temp{i,1}=uniqueBIDs{k,1};
            tempBCord(i,1)=BCord(k,1);
            tempBCord(i,2)=BCord(k,2);
            k=k+1;
        end % if isempty(temp{i,1})
    end % for i=1:size(uniqueBIDs,1)
    clear uniqueBIDs BCord
    uniqueBIDs=temp;
    BCord=tempBCord;
    clear temp tempBCord
end % if size(uniqueBIDs,1)<length(BToes)

prefix='Oligopaints.txt'; % print order text file
outputPaints=strcat(SavePath,prefix);
fileID=fopen(outputPaints,'w');
for i=1:size(OligoPaints,1)
    fprintf(fileID,'%s\n',OligoPaints{i,1});
end
fclose(fileID);

prefix='BS_IDs.txt'; % print backstreets toes number, BS ID, toe seq, bridge seq and Rev primer seq.
outputBIDs=strcat(SavePath,prefix);
fileID=fopen(outputBIDs,'w');
if ~exist('SOLiDcode','var')
    fprintf(fileID,'BSRegionID\tID\tToeNum\tToeSequence\tBridgeSequence\tReversePrimerSeq\n');
    for i=1:size(ToeBack,2)
        Bridge=Toes(ToeBack(i),8:end);
        RPrimer=Toes(ToeBack(i),1:20);
        fprintf(fileID,'%s\t%d\t%d\t%s\t%s\t%s\n',uniqueBIDs{i,1},BToes(i),ToeBack(i),Toes(ToeBack(i),:),Bridge,RPrimer);
    end % for i=1:size(ToeBack,2)
else
    fprintf(fileID,'BSRegionID\tID\tToeNum\tToeSequence\tBridgeSequence\tReversePrimerSeq\tSOLiDCode\n');
    for i=1:size(ToeBack,2)
        Bridge=Toes(ToeBack(i),8:end);
        RPrimer=Toes(ToeBack(i),1:20);
        g=sprintf('%d',SOLiDcode(ToeBack(i),:)-1);
        fprintf(fileID,'%s\t%d\t%d\t%s\t%s\t%s\t%s\n',uniqueBIDs{i,1},BToes(i),ToeBack(i),Toes(ToeBack(i),:),Bridge,RPrimer,g);
    end % for i=1:size(ToeBack,2)
end % if ~exist('SOLiDCode','var')
fclose(fileID);

prefix='MS_IDs.txt'; % print Mainstreets toes number, MS ID, toe seq, bridge seq and Fwd primer seq.
outputMIDs=strcat(SavePath,prefix);
fileID=fopen(outputMIDs,'w');
if ~exist('SOLiDcode','var')
    fprintf(fileID,'MSRegionID\tID\tToeNum\tToeSequence\tBridgeSequence\tForwardPrimerSeq\n');
    for i=1:size(MToes,2)
        Bridge=Toes(ToeMain(i),8:end);
        FPrimer=ReverseComplement(Bridge,1);
        fprintf(fileID,'%s\t%d\t%d\t%s\t%s\t%s\n',uniqueMIDs{i,1},MToes(i),ToeMain(i),Toes(ToeMain(i),:),Bridge,FPrimer);
    end % for i=1:size(MToes,2)
else
    fprintf(fileID,'MSRegionID\tID\tToeNum\tToeSequence\tBridgeSequence\tForwardPrimerSeq\tSOLiDCode\n');
    for i=1:size(MToes,2)
        Bridge=Toes(ToeMain(i),8:end);
        FPrimer=ReverseComplement(Bridge,1);
        g=sprintf('%d',SOLiDcode(ToeMain(i),:)-1);
        fprintf(fileID,'%s\t%d\t%d\t%s\t%s\t%s\t%s\n',uniqueMIDs{i,1},MToes(i),ToeMain(i),Toes(ToeMain(i),:),Bridge,FPrimer,g);
    end % for i=1:size(MToes,2)
end % if ~exist('SOLiDCode','var')
fclose(fileID);

prefix='Universal.txt';
outputUniversal=strcat(SavePath,prefix);
fileID=fopen(outputUniversal,'w');
fprintf(fileID,'UniMainNum\tUniMainSequence\tUniBackiNum\tUniBackRCSequence\n');
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

prefix='BSDensity.txt';
outputBSDensity=strcat(SavePath,prefix);
fileID=fopen(outputBSDensity,'w');
fprintf(fileID,'BS_Region\tStart\tEnd\tSize_(kb)\t#_of_OPs_probes\tDensity_(Probes/kb)\n');
for i=1:size(BSReg,1)
    fprintf(fileID,'%s\t%d\t%d\t%d\t%d\t%d\n',BSReg{i,1},BcountsID(1,i),BcountsID(2,i),BcountsID(3,i),Bcounts(i),BProbesPerKb(i));
end % for i=1:size(MSReg,1)
fclose(fileID);
%% Save
SaveName='data.mat';
save(strcat(SavePath,SaveName));