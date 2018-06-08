function Penalty = MaxSelfEnd(oligo,oligo2)
%PRIMER_MAX_SELF_END tries to bind the 3'-END to a identical primer and scores the best binding it can find.
%This is critical for primer quality because it allows primers use itself as a target and amplify a short piece
%(forming a primer-dimer). These primers are then unable to bind and amplify the target sequence.
%PRIMER_MAX_SELF_END is the maximum allowable 3'-anchored global alignment score when
%testing a single primer for self-complementarity.
%The 3'-anchored global alignment score is taken to predict the likelihood of PCR-priming primer-dimers, for example
%
%   5' ATGCCCTAGCTTCCGGATG 3'
%                ||| |||||
%             3' AAGTCCTACATTTAGCCTAGT 5'
% or
%   5` AGGCTATGGGCCTCGCGA 3'
%                 ||||||
%              3' AGCGCTCCGGGTATCGGA 5'
%The scoring system is as for the Maximum Complementarity argument.
%In the examples above the scores are 7.00 and 6.00 respectively. Scores are non-negative,
%and a score of 0.00 indicates that there is no reasonable 3'-anchored global alignment between two oligos.
%In order to estimate 3'-anchored global alignments for candidate primers,
%Primer3 assumes that the sequence from which to choose primers is presented 5'->3'.
%It is nonsensical to provide a larger value for this parameter than for the Maximum (local)
%Complementarity parameter (PRIMER_MAX_SELF_ANY) because the score
%of a local alignment will always be at least as great as the score of a global alignment.
% Adapted from primer3 manual.
% Input:  A vector containing DNA sequence or 'translted' sequence, where
% 'A'=1; 'C'=2; 'G'=3; 'T'=4;  A second input is needed when checking for
% binding of a primer pair.
% Output: Score. A score of 3 is recomended for filtering (above 3
% should be filtered out).
%%
switch nargin
    case 1
        if ischar(oligo)
            oligo=SequenceToNumbers(oligo);
        end % if ischar(oligo)
        Penalty=0;
        for j=1:size(oligo,2)
            CompOligo=zeros(size(oligo,1),size(oligo,2));
            flag=0; k=j;
            while flag==0
                for i=size(oligo,2):-1:1
                    if (oligo(i)==1 && oligo(k)==4) || (oligo(i)==4 && oligo(k)==1)...
                            || (oligo(i)==2 && oligo(k)==3) || (oligo(i)==3 && oligo(k)==2)
                        CompOligo(i)=1;
                    end
                    if (i < size(oligo,2) && CompOligo(i)==0 && CompOligo(i+1)==0 && CompOligo(end)==1) ...
                          || (i < size(oligo,2)-1 && CompOligo(i)==0 && CompOligo(i+2)==0 && CompOligo(end)==1)
                        flag=1;
                        if sum(CompOligo) > Penalty
                            Penalty=sum(CompOligo);
                        end % if sum(CompOligo) > Penalty
                        break
                    end % if i < size(oligo,2) && CompOligo(i)==0 && CompOligo(i+1)==0
                    k=k+1;
                    if k>size(oligo,2)
                        flag=1;
                        break
                    end
                end % for i=size(oligo,2):-1:1
                if i==1
                    flag=1;
                end % if i==j
            end % while flag==0
        end %  for j=1:size(oligo,2)
    case 2
        if ischar(oligo)
            oligo=SequenceToNumbers(oligo);
        end % if ischar(oligo)
        if ischar(oligo2)
            oligo2=SequenceToNumbers(oligo2);
        end % if ischar(oligo)
        Penalty=0;
        for j=1:size(oligo2,2)
            CompOligo=zeros(size(oligo,1),size(oligo,2));
            flag=0;
            k=j;
            while flag==0
                for i=size(oligo,2):-1:1
                    if (oligo(i)==1 && oligo2(k)==4) || (oligo(i)==4 && oligo2(k)==1)...
                            || (oligo(i)==2 && oligo2(k)==3) || (oligo(i)==3 && oligo2(k)==2)
                        CompOligo(i)=1;
                    end
                    if (i < size(oligo2,2) && CompOligo(i)==0 && CompOligo(i+1)==0 && CompOligo(end)==1) ...
                          || (i < size(oligo2,2)-1 && CompOligo(i)==0 && CompOligo(i+2)==0 && CompOligo(end)==1)
                        flag=1;
                        if sum(CompOligo) > Penalty
                            Penalty=sum(CompOligo);
                        end % if sum(CompOligo) > Penalty
                        break
                    end % if i < size(oligo,2) && CompOligo(i)==0 && CompOligo(i+1)==0
                    k=k+1;
                    if k>size(oligo2,2)
                        flag=1;
                        break
                    end
                end % for i=size(oligo,2):-1:1
                if i==1
                    flag=1;
                end % if i==j
            end % while flag==0
        end %  for j=1:size(oligo2,2)
        for j=1:size(oligo,2)
            CompOligo=zeros(size(oligo2,1),size(oligo2,2));
            flag=0; k=j;
            while flag==0
                for i=size(oligo2,2):-1:1
                    if (oligo2(i)==1 && oligo(k)==4) || (oligo2(i)==4 && oligo(k)==1)...
                            || (oligo2(i)==2 && oligo(k)==3) || (oligo2(i)==3 && oligo(k)==2)
                        CompOligo(i)=1;
                    end
                    if (i < size(oligo2,2) && CompOligo(i)==0 && CompOligo(i+1)==0 && CompOligo(end)==1) ...
                          || (i < size(oligo2,2)-1 && CompOligo(i)==0 && CompOligo(i+2)==0 && CompOligo(end)==1)
                        flag=1;
                        if sum(CompOligo) > Penalty
                            Penalty=sum(CompOligo);
                        end % if sum(CompOligo) > Penalty
                        break
                    end % if i < size(oligo2,2) && CompOligo(i)==0 && CompOligo(i+1)==0
                    k=k+1;
                    if k>size(oligo,2)
                        flag=1;
                        break
                    end
                end % for i=size(oligo2,2):-1:1
                if i==1
                    flag=1;
                end % if i==j
            end % while flag==0
        end %  for j=1:size(oligo,2)
end