function SelfAny = PrimerMaxSelfAny(oligo,oligo2)
% PRIMER_MAX_SELF_ANY describes the tendency of a primer to bind to itself
% (interfering with target sequence binding). It will score ANY binding occurring within the entire primer sequence.
% It is the maximum allowable local alignment score when testing a single primer for (local) self-complementarity
% and the maximum allowable local alignment score when testing for complementarity between left and right primers.
% Local self-complementarity is taken to predict the tendency of primers to anneal to each other without necessarily
% causing self-priming in the PCR.
% The scoring system gives 1.00 for complementary bases, -0.25 for a match
% of any base (or N) with an N, -1.00 for a mismatch, and -2.00 for a gap.
% Only single-base-pair gaps are allowed. For example, the alignment
%   5'ATCGNA 3'
%     || | |
%   3'TA-CGT 5'
% is allowed (and yields a score of 1.75), but the alignment
%   5' ATCCGNA 3'
%      ||  | |
%   3' TA--CGT 5'
% is not considered. Scores are non-negative, and a score of 0.00 indicates
% that there is no reasonable local alignment between two oligos.
% Adapted from primer3 manual, here I only consider a mismatch (-1), or
% complementary bases (1). Gaps (-2) are considered for 2 different oligos
% (e.g. forward and reverse).
% Input:  (1) A vector containing DNA sequence or 'translted' sequence, where
% 'A'=1; 'C'=2; 'G'=3; 'T'=4;  A second input is needed when checking for
% binding of a primer pair.
% Output: Score. A score of 8 is recomended for filtering (8 and above
% should be filtered out).
%%
switch nargin
    case 1
        
        if ischar(oligo)
            oligo=SequenceToNumbers(oligo);
        end % if ischar(oligo)
        
        FlipOligo=flip(oligo);
        CompOligo=zeros(size(oligo,1),size(oligo,2));
        for i=1:length(oligo)
            if (oligo(i)==1 && FlipOligo(i)==4) || (oligo(i)==4 && FlipOligo(i)==1)...
                    || (oligo(i)==2 && FlipOligo(i)==3) || (oligo(i)==3 && FlipOligo(i)==2)
                CompOligo(i)=1;
            else
                CompOligo(i)=-1;
            end % if (oligo(i)==1 && FlipOligo(i)==4) || (oligo(i)==4 && FlipOligo(i)==1)...
        end % for i=1:length(oligo)
        SelfAny=sum(CompOligo);
    case 2
        if ischar(oligo)
            oligo=SequenceToNumbers(oligo);
        end % if ischar(oligo)
        if ischar(oligo2)
            oligo2=SequenceToNumbers(oligo2);
        end % if ischar(oligo2)
        if length(oligo)>length(oligo2)
            LongestOligoLength=length(oligo);
            OligoRow=size(oligo,1);
            oligo2(end+1:length(oligo))=0;
        else
            LongestOligoLength=length(oligo2);
            OligoRow=size(oligo2,1);
            if length(oligo2)>length(oligo)
                oligo(end+1:length(oligo2))=0;
            end % if length(oligo2)>length(oligo)
        end % if length(oligo)>length(oligo2)
        CompOligo=zeros(OligoRow,LongestOligoLength);
        for i=1:LongestOligoLength
            if (oligo(i)==1 && oligo2(i)==4) || (oligo(i)==4 && oligo2(i)==1)...
                    || (oligo(i)==2 && oligo2(i)==3) || (oligo(i)==3 && oligo2(i)==2)
                CompOligo(i)=1;
            elseif oligo(i)==0 || oligo2(i)==0
                CompOligo(i)=-2;
            else
                CompOligo(i)=-1;
            end % if (oligo(i)==1 && oligo2(i)==4) || (oligo(i)==4 && oligo2(i)==1)...
        end % for i=1:length(oligo)
        SelfAny=sum(CompOligo);
end % switch nargin