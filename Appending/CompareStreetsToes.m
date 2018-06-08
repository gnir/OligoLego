%% Parse input
StreetsPath='/Users/guynir/Documents/MATLAB/Streets/Streets_hg38.txt';
ToesPath='/Users/guynir/Documents/MATLAB/Streets/Toes_hg38.txt';
Streets = readtextfile(StreetsPath);
Toes = readtextfile(ToesPath);
%% Compare streets and Toes
ToesMat=zeros(size(Toes,1));
StreetsMat=zeros(size(Streets,1));
h = waitbar(0,'Comparing streets and toes, please wait');
for i=1:size(Toes,1)-1
    for j=i+1:size(Toes,1)
        if strcmp(Toes(i,:),Toes(j,:))
            ToesMat(i,j)=1;
        end % if strcmp(Toes{i,:},Toes{j,:})
        if strcmp(Streets(i,:),Streets(j,:))
            StreetsMat(i,j)=1;
        end % if strcmp(Streets{i,:},Streets{j,:})
    end % for j=i+1:size(Toes,1)-1
    waitbar(i/size(Toes,1))
end % for i=1:size(Toes,1)
close(h)
[rS, cS]=find(StreetsMat);
[rT, cT]=find(ToesMat);
%% Check for x nt difference
StreetsNum=SequenceToNumbers(Streets);
ToesNum=SequenceToNumbers(Toes);
Hamming=2; % x nt difference
TNumMatSum=zeros(size(ToesNum,1));
SNumMatSum=zeros(size(StreetsNum,1));
h = waitbar(0,'Comparing streets and toes with n nt difference, please wait');
for i=1:size(ToesNum,1)-1
    TNumMat=zeros(size(ToesNum,1),size(ToesNum,2));
    SNumMat=zeros(size(StreetsNum,1),size(StreetsNum,2));
    for j=i+1:size(ToesNum,1)
        TNumMat(j-1,ToesNum(i,:)-ToesNum(j,:)==0)=1;
        SNumMat(j-1,StreetsNum(i,:)-StreetsNum(j,:)==0)=1;
    end % for j=i+1:size(ToesNum,2)
    TNumMatSum(i,:)=sum(TNumMat,2);
    SNumMatSum(i,:)=sum(SNumMat,2);
    waitbar(i/size(ToesNum,1))
end % for i=1:size(ToesNum,1)
close(h)