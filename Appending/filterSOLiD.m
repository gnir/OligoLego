function SameCode = filterSOLiD(SOLiDcode,N)
% This function returns the oligos that have the same code with N colors.
% If N = 2, it will return those that are differnt  in at least 2
% colors. That means that if the user wants a code where each oligo differs
% in at least 2 colors, then N = 1. In other words, N+1 = Hamming distance.
for i=1:size(SOLiDcode,1)-1
    SubtractMat = abs(SOLiDcode(i,:)-SOLiDcode(i+1:end,:));
    ZeroMat=zeros(size(SubtractMat,1),size(SubtractMat,2));
    ZeroMat(SubtractMat==0)=1;
    SuMat=cumsum(ZeroMat,2);
    SumCol=SuMat(:,end);
    SameCodeMat{i,1}(:)=find((SumCol>=size(SOLiDcode,2)-N))+i; % +i to account for the changing matrix size every loop iteration
    SameCodeMatSize(i,1)=size(SameCodeMat{i,1},2);
end % for i=1:size(SOLiDcode,1)-1
k=1;
for i=1:size(SameCodeMat,1)
    for j=1:size(SameCodeMat{i},2)
    SameCode(k)=SameCodeMat{i}(j);
    k=k+1;
    end % for j=1:size(SameCodeMat{j},2)
end % for i=1:size(SameCodeMat,1)
if exist('SameCode','var')
    SameCode=unique(SameCode);
else
    SameCode=[];
end % if exists('SameCode','var')