function SOLiDcode = SOLiDBarcoding(NColors,OligoPool,varargin)
% Input: NColors = Number of colors to use. SOLiD uses 4. 
% OligoPool = Pool of streets. Each row is a different street.
% ColorCode{1,1:4}=FAM; ColorCode{2,1:4}=Cy3; ColorCode{3,1:4}=TXR; ColorCode{4,1:4}=Cy5;
% Streets should be at the same length. Read size is 2 nucleotides.
% Output - A code map. Each row is a different oligo. Columns are the
% coding 5' to 3'.
%% Color code
ColorCode=strings(4,NColors);
ColorCode{1,1}='AA';
ColorCode{1,2}='CC';
ColorCode{1,3}='GG';
ColorCode{1,4}='TT';
ColorCode{2,1}='AC';
ColorCode{2,2}='CA';
ColorCode{2,3}='GT';
ColorCode{2,4}='TG';
ColorCode{3,1}='AG';
ColorCode{3,2}='GA';
ColorCode{3,3}='CT';
ColorCode{3,4}='TC';
ColorCode{4,1}='AT';
ColorCode{4,2}='TA';
ColorCode{4,3}='CG';
ColorCode{4,4}='GC';
%% Coding
CodeSize=2; % 2 nucleotide code
SkipSize=3; % 3 nucleotide skip
ReadSize=CodeSize+SkipSize; 
poolSize=size(OligoPool,1);

OligoLength=size(OligoPool,2);
if mod(OligoLength,2)~=0
    OligoLength=OligoLength-1;
end % if mod(OligoLength,2)==0
SOLiDcode=zeros(poolSize,floor(OligoLength/ReadSize));
SOLiDcodeRC=SOLiDcode;
if mod(OligoLength,ReadSize)==0
    LastRead=OligoLength-ReadSize+1;
else
    LastRead=OligoLength-ReadSize;
end % if mod(OligoLength/ReadSize)==0
for i=1:poolSize
    RC=ReverseComplement(OligoPool(i,:));
    RC=Numbers2Sequnces(RC);
    p=0;
    for j=1:ReadSize:LastRead
            p=p+1;
        for k=1:size(ColorCode,1)
            for t=1:size(ColorCode,2)
                if strcmp(OligoPool(i,j:j+1),ColorCode{k,t})
                    SOLiDcode(i,p)=k;
                end % if strcmp(OligoPool{i,j:j+1),ColorCode{k,t}
                if strcmp(RC(j:j+1),ColorCode{k,t})
                    SOLiDcodeRC(i,p)=k;
                end % if strcmp(RC,ColorCode{k,t})
            end % for t=1:size(ColorCode,2)
        end % for k=1:size(ColorCode,1)
    end % for j=Position:ReadSize
end % for i=1:size(OligoPool,1)
%% output RC code if needed
Nvarargin=numel(varargin);
for i=1:Nvarargin
    if strcmp(varargin{i},'RC')
       SOLiDcode=SOLiDcodeRC;
    end % if strcmp(varargin{i},'RC')
end % for i=1:Nvarargin