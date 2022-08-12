function AppToMSBS_V2(MSPath,BSPath,StreetsPath,PTablePath,ToesPath,MaxAvoid,SavePath,varargin)
%% AppendingToesMSBS_V2
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
        elseif strcmp(varargin{i},'MultipleUniversals')
            numUni=varargin{i+1};
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
    end % if MainCell{i,10}>maxMC
end % for i=1:size(MainCell,1)
%% Assign streets
MainCellTbl=cell2table(MainCell);
[MSId,MSPos]=unique(MainCellTbl(:,10)); % find how many barcodes and where for MS
[BSId,BSPos]=unique(MainCellTbl(:,11)); % find how many barcodes and where for BS
LastColumn=size(MainCellTbl,2);
N_MSTargets=size(MSId,1);
N_BSTargets=size(BSId,1);
k=MaxAvoid+1; % Avoids preselected streets
f = waitbar(0,'1','Name','Assigning MainStreets','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(f,'canceling',0);
Tbl=cell(size(MainCellTbl,1),N_MS);
for i=1:N_MSTargets
    for j=1:N_MS
        A=convertCharsToStrings(Toes(k,:));
        if i<size(MSPos,1)
            B=repmat(A,MSPos(i+1)-MSPos(i),1);
            B=cellstr(B);
            %MainCellTbl(MSPos(i):MSPos(i+1)-1,LastColumn+j)=B;
            Tbl(MSPos(i):MSPos(i+1)-1,j)=B;
        else
            B=repmat(A,size(MainCellTbl,1)-MSPos(i)+1,1);
            B=cellstr(B);
            %MainCellTbl(MSPos(i):end,LastColumn+j)=B;
            Tbl(MSPos(i):end,j)=B;
        end % if i<size(MSPos,1)
        k=k+1;
    end % for j=1:N_MS
    % Check for clicked Cancel button
    if getappdata(f,'canceling')
        break
    end % if getappdata(f,'canceling')   
    % Update waitbar and message
    waitbar(i/N_MSTargets,f,sprintf('%12.2f%s',i/N_MSTargets*100,'%'))
end % for i=1:N_MSTargets
delete(f)
MainCellTbl(:,LastColumn+1:LastColumn+j)=Tbl;
LastColumn=size(MainCellTbl,2);
Tbl=cell(size(MainCellTbl,1),N_BS);
f = waitbar(0,'1','Name','Assigning BackStreets','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(f,'canceling',0);
for i=1:N_BSTargets
    for j=1:N_BS
        A=convertCharsToStrings(Toes(k,:));
        if i<size(BSPos,1)
            B=repmat(A,BSPos(i+1)-BSPos(i),1);
            B=cellstr(B);
            Tbl(BSPos(i):BSPos(i+1)-1,j)=B;
            %MainCellTbl(BSPos(i):BSPos(i+1)-1,LastColumn+j)=B;
        else
            B=repmat(A,size(MainCellTbl,1)-BSPos(i)+1,1);
            B=cellstr(B);
            Tbl(BSPos(i):end,j)=B;
            %MainCellTbl(BSPos(i):end,LastColumn+j)=B;
        end % if i<size(MSPos,1)
        k=k+1;
    end % for j=1:N_BS
    % Check for clicked Cancel button
    if getappdata(f,'canceling')
        break
    end % if getappdata(f,'canceling')
    % Update waitbar and message
    waitbar(i/N_BSTargets,f,sprintf('%12.2f%s',i/N_BSTargets*100,'%'))    
end % for i=1:N_BSTargets
MainCellTbl(:,LastColumn+1:LastColumn+j)=Tbl;
delete(f)
%% Assign BackStrees with no MainStreet ID