function RemIdx=FilterSimilar(St,Hamming)
% This function returns the indices of sequences (entered in numbers) that
% are equal to or more similar than the Hamming distance.
RemIdx=0;
for i=1:size(St,1)-1
 CompMat=abs(St(i,:)-St(i+1:end,:));
 CompMat(CompMat~=0)=1;
 SumMat=sum(CompMat,2);
 RemoveSt=find(SumMat<=Hamming);
 if ~isempty(RemoveSt)
     RemoveSt=RemoveSt+i;
     RemIdx(end+1)=RemoveSt;
 end % if ~isempty(RemoveSt)
end % for i=1:size(Streets,1)-1
RemIdx=RemIdx(2:end);