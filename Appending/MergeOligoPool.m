function varargout = MergeOligoPool(OldPool,Streets,Hamming,varargin)

% For Streets and Toes: [newSt,newToe] = MergeOligoPool(OldPool,Streets,Hamming,'NewToes',Toes,'OldToes',OldToes);

k=1;
nvarargin=numel(varargin);
if nvarargin==0
    OPool=zeros(size(OldPool,1),size(OldPool{1,1}{1,1},2));
    for i=1:size(OldPool,1)
        OPool(i,:)=SequenceToNumbers(OldPool{i,1}{1,1});
    end % for i=1:size(OldPool,1)
    OLength=size(OPool,2);
    temp=[OPool; Streets];
    for i=size(temp,1):-1:2
        tempDiff=abs(temp(i,:)-temp(1:i-1,:));
        TempZero=zeros(size(tempDiff,1),size(tempDiff,2));
        TempZero(tempDiff==0)=1;
        tempSum=sum(TempZero,2);
        RemStreet=(OLength-tempSum)<Hamming;
        if max(RemStreet)==0
            NewPool(k,:)=temp(i,:);
            k=k+1;
        else
            NewPool=[];
        end % if max(RemStreet)>0
    end % for i=size(temp,1):-1:1
    varargout{1}=NewPool;
elseif nvarargin==4
    for i=1:2:nvarargin
        if strcmp(varargin(i),'NewToes')
            NewToes=varargin(i+1);
        elseif strcmp(varargin(i),'OldToes')
            OldToes=varargin(i+1);
        end % if strcmp(varargin(i),'NewToes')
    end % for i=1:2:nvarargin
    OPool=zeros(size(OldPool,1),size(OldPool{1,1}{1,1},2));
    TPool=zeros(size(OldPool,1),size(OldToes{1,1}{1,1}{1,1},2));
    NewToesNum=zeros(size(NewToes{1,1},1),size(NewToes{1,1},2));
    for i=1:size(OldPool,1)
        OPool(i,:)=SequenceToNumbers(OldPool{i,1}{1,1});
        TPool(i,:)=SequenceToNumbers(OldToes{1,1}{i,1}{1,1});
    end % for i=1:size(OldPool,1)
    for i=1:size(NewToes{1,1},1)
        NewToesNum(i,:)=SequenceToNumbers(NewToes{1,1}(i,:));
    end % for i=1:size(NewToes{1,1},1)
    OLength=size(OPool,2);
    OPool=flip(OPool);
    temp=[Streets; OPool];
    TPool=flip(TPool);
    tempToe=[NewToesNum; TPool];
    for i=1:size(temp,1)-1
        tempDiff=abs(temp(i,:)-temp(i+1:end,:));
        TempZero=zeros(size(tempDiff,1),size(tempDiff,2));
        TempZero(tempDiff==0)=1;
        tempSum=sum(TempZero,2);
        RemStreet=(OLength-tempSum)<Hamming;
        if max(RemStreet)==0
            NewPool(k,:)=temp(i,:);
            NewToePool(k,:)=tempToe(i,:);
            k=k+1;
        else
            NewPool=[];
            NewToePool=[];
        end % if max(RemStreet)>0
        NewPool(k,:)=temp(end,:);
        NewToePool(k,:)=tempToe(end,:);
    end % for i=size(temp,1):-1:1
    varargout{1}=flip(NewPool);
    varargout{2}=flip(NewToePool);
end % if nvarargin==0
