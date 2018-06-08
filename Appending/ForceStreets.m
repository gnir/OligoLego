function ForceStreets(MainStepSeqPath,BackStepSeqPath,MSPath,BSPath,StreetsPath,ToesPath,PTablePath,MaxAvoid,SavePath)
%% Parse input

MainStepSequence=Loadingtxt(MainStepSeqPath);
BackStepSequence=Loadingtxt(BackStepSeqPath);
MainToeID=zeros(size(MainStepSequence,1),1);
for i=1:size(MainStepSequence,1)
    MainToeID(i)=str2double(MainStepSequence{i,3});
end % for i=1:size(mainStepSequence,1)
BackToeID=zeros(size(BackStepSequence,1),1);
for i=1:size(BackStepSequence,1)
    BackToeID(i)=str2double(BackStepSequence{i,3});
end % for i=1:size(BackStepSequence,1)
Main = readtextfile(MSPath);
Back = readtextfile(BSPath);
Toes = readtextfile(ToesPath);
Streets = readtextfile(StreetsPath);
PairsMatrix = readtextfile(PTablePath);
PairsMat=NaN(size(PairsMatrix,1),size(PairsMatrix,1));
for i=1:size(PairsMatrix,1) % Convert PenaltyMat to mat-var
    PairsMat(i,:)=str2num(PairsMatrix(i,:));
end % for i=1:size(PairsMatrix,1)
%% Arrange Backstreet and Mainstreet lists
h = waitbar(0,'Organzing Backstreet list, please wait');
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
            end % for k=1:size(MainCell,2)
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
%% Assign streets - user-selected streets
i=1;
for j=1:size(MainStepSequence,1)
    if i>size(MainCell,1)
        break
    end % if i>size(MainCell,1)
    Oligopaints{i,:}=strcat(ReverseComplement(Toes(str2double(MainStepSequence{j,3}),:),1),MainCell{i,8}); % input first
    i=i+1;
    while MainCell{i,10}==MainCell{i-1,10}
        Oligopaints{i,:}=strcat(ReverseComplement(Toes(str2double(MainStepSequence{j,3}),:),1),MainCell{i,8});
        i=i+1;
        if i>size(MainCell,1)
            break
        end % if i>size(MainCell,1)
    end % while MainCell{i,10}==MainCell{i-1,10}
end % for j=1:size(MainStepSequence,1)

i=1;
for j=1:size(BackStepSequence,1)
    if i>size(BackCell,1)
        break
    end % for j=1:size(BackStepSequence,1)
    Oligopaints{i,:}=strcat(Oligopaints{i,:},ReverseComplement(Toes(str2double(BackStepSequence{j,3}),:),1)); % input first
    i=i+1;
    while BackCell{i,10}==BackCell{i-1,10}
        Oligopaints{i,:}=strcat(Oligopaints{i,:},ReverseComplement(Toes(str2double(BackStepSequence{j,3}),:),1));
        i=i+1;
        if i>size(BackCell,1)
            break
        end % if i>size(BackCell,1)
    end % while MainCell{i,10}==MainCell{i-1,10}
end % for j=1:size(MainStepSequence,1)
%% Add universal
if exist('UniF','var')
    for i=1:size(Oligopaints,1)
        Oligopaints{i,:}=strcat(Streets(UniF,:),Oligopaints{i,:},ReverseComplement(Streets(UniR,:),1));
    end % for i=1:size(OligoPaints,1)
    UniversalMS=Streets(UniF,:);
    U_MS_N=cat(2,PrF,UniF);
    UniversalBS=Streets(UniR,:);
    U_BS_N=cat(2,PrR,UniR);
else
    PrR=MaxAvoid;
    PrF=PrR;
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
    for i=1:size(Oligopaints,1)
        Oligopaints{i,:}=strcat(Streets(PrF(end),:),Oligopaints{i,:},ReverseComplement(Streets(PrR(end),:),1));
    end % for i=1:size(OligoPaints,1)
    UniversalMS=Streets(PrF(end),:); % Forward primer sequence
    U_MS_N=PrF;
    UniversalBS=Streets(PrR(end),:); % Reverse primer sequence
    U_BS_N=PrR;
end % if exists('UniF','var')
%% Output

prefix='Oligopaints.txt'; % print order text file
outputPaints=strcat(SavePath,prefix);
fileID=fopen(outputPaints,'w');
for i=1:size(Oligopaints,1)
    fprintf(fileID,'%s\n',Oligopaints{i,1});
end
fclose(fileID);

prefix='Universal.txt';
outputUniversal=strcat(SavePath,prefix);
fileID=fopen(outputUniversal,'w');
fprintf(fileID,'UniMainNum\tUniMainSequence\tUniBackiNum\tUniBackRCSequence\n');
fprintf(fileID,'%d\t%s\t%d\t%s\n',U_MS_N(end),UniversalMS,U_BS_N(end),UniversalBS);
fclose(fileID);
SaveName='data.mat';
save(strcat(SavePath,SaveName));