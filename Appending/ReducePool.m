function varargout = ReducePool(exclude,varargin)
% This function excludes unwanted sequences from a pool of sequences.
% input: 1.exclude - a vector containing sequence numbers (the sequence number correspondes to the row
% number in the pool) to exclude.
% Output: Reduced - The pool after excluding.
%% Parse input
nVarargs = length(varargin);
SFlag=0; TFlag=0; PFlag=0; SiFlag=0;
for i=1:2:nVarargs
    if strcmp(varargin{i},'Streets')
        Streets=varargin{i+1};
        SFlag=1;
    elseif strcmp(varargin{i},'Toes')
        Toes=varargin{i+1};
        TFlag=1;
    elseif strcmp(varargin{i},'PTable')
        PTable=varargin{i+1};
        PFlag=1;
    elseif strcmp(varargin{i},'SOLiDCode')
        SOLiDIn=varargin{i+1};
        SiFlag=1;
    end % if strcmp(varargin{i},'Streets')
end % for i=1:2:nVarargs
%% Reduce
if SFlag==1
    Streets(exclude,:)=[];
end % if SFlag==1
if TFlag==1
    Toes(exclude,:)=[];
end % if TFlag==1
if PFlag==1
    for i=1:length(exclude)
        PTable(exclude(i)-(i-1),:)=[];
        PTable(:,exclude(i)-(i-1))=[];
    end % for i=1:length(exclude)
end % if PTable==1
if SiFlag==1
    SOLiDIn(exclude,:)=[];
end % if SiFlag==1
%% Output
if SFlag==1
    varargout{1}=Streets;
else
    varargout{1}=NaN(1);
end % if SFlag==1
if TFlag==1
    varargout{2}=Toes;
else
    varargout{2}=NaN(1);
end % if TFlag==1
if PFlag==1
    varargout{3}=PTable;
else
    varargout{3}=NaN(1);
end % if PFlag==1
if SiFlag==1
    varargout{4}=SOLiDIn;
else
    varargout{4}=NaN(1);
end % if SiFlag==1