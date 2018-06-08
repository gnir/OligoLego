UnNum=MainCell{1,10};
UnIdx=1;
for i=2:size(MainCell,1)
    if UnNum(end)~=MainCell{i,10}
        UnNum(end+1)=MainCell{i,10};
        UnIdx(end+1)=i;
    end % if UnNum(end)~=MainCell{i,10}
end % for i=2:size(MainCell,1)
NumOligos=zeros(size(UnIdx,1),size(UnIdx,2));
NumOligos(1:end-1)=UnIdx(2:end)-UnIdx(1:end-1);
NumOligos(end)=size(MainCell,1)-UnIdx(end);
StepSize=str2double(MainCell(UnIdx,3))-str2double(MainCell(UnIdx,2));
DensityOligos=NumOligos'./(StepSize/1000);
    