function RC = ReverseComplement(oligo,translate)
% This function returns the reverse complement of an oligo
%Input:  A vector containing DNA sequence or 'translated' sequence, where
% 'A'=1; 'C'=2; 'G'=3; 'T'=4; If you want the function to translate the
% numbers back to a sequence, a second input is required, this input could
% be the number 1.
if ischar(oligo)
    oligo=SequenceToNumbers(oligo);
end % if ischar(oligo)
RC=flip(oligo);
for i=1:size(oligo,2)
    if RC(i)==1
        RC(i)=4;
    elseif RC(i)==2
        RC(i)=3;
    elseif RC(i)==3
        RC(i)=2;
    elseif RC(i)==4
        RC(i)=1;
    end % if RC(i)==1
end % for i=1:size(oligo,2)
switch nargin
    case 1
    case 2
        oligo=RC;
        RC=blanks(size(oligo,2));
        for i=1:size(oligo,2)
            if oligo(i)==1
                RC(i)='A';
            elseif oligo(i)==2
                RC(i)='C';
            elseif oligo(i)==3
                RC(i)='G';
            elseif oligo(i)==4
                RC(i)='T';
            end % if oligo(i)==1
        end % for i=1:size(oligo,2)
end % switch nargin

