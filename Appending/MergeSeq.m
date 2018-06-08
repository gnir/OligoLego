function MergedSequenace = MergeSeq(OligoPool,MSSize,BSSize,varargin)
%% Documentation
% This function merges sequences
% input - Oligopool: a pool of sequences to append other sequences to.
% 'MS' - flag to append to Mainstreet. 'BS' - flag to append to Backstreet.
% Flag should be followed up by the position to insert the sequence, either
% from the most 5' for MS, or the most 3' for BS.
% MSSize - size of your mainstreet. BSSize - size of your backstreet.
% MergedSequenace = MergeSeq(OligoPool,47,47,'MS','48','MSSeq','T','BS','48','BSSeq','T')
% output - appended sequences.
%% Parse input
OPool=Loadingtxt(OligoPool);
if ~isempty(varargin)
    Nvarargin=length(varargin);
    for i=1:2:Nvarargin-1
        if strcmp(varargin(i),'MS')
            MSFlag=1;
            PosMS=str2double(varargin{i+1});
        elseif strcmp(varargin(i),'BS')
            BSFlag=1;
            PosBS=str2double(varargin{i+1});
        elseif strcmp(varargin(i),'MSSeq')
            SeqMS=cell2str(varargin(i+1));
            SeqMS=SeqMS(isletter(SeqMS));
        elseif strcmp(varargin(i),'BSSeq')
            SeqBS=cell2str(varargin(i+1));
            SeqBS=SeqBS(isletter(SeqBS));
        end % if strcmp(varargin(i),'MS')
    end % for i=1:2:Nvarargin-1
else
    errordlg('Please indicate MS or BS')
end % if ~isempty(varargin)
%% Merge
if MSFlag==1 && BSFlag==1
    for i=1:size(OPool,1)
        oligo=cell2str(OPool{i,1});
        oligo=oligo(3:end-3);
        OligoSize=size(oligo,2);
        MergedSequenace{i,1}=strcat(oligo(1:PosMS-1),SeqMS,oligo(PosMS:OligoSize-BSSize),SeqBS,oligo(OligoSize-BSSize+1:end));
    end % for i=1:size(OPool,1)
end % if MSFlag==1 && BSFlag==1
