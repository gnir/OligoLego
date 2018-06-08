function GCC = GC_3End(oligo)
%% This function reports if the last nucleotides in an oligo is either 'A' and 'T'
% input: vector containing numbers 1 to 4, where 1='A', 2='C', 3='G', 4='T'
% output: '1' if there are more than 3 G/C at the 3-end, '0' if not
%% Finding GC
if ischar(oligo)
    oligo=SequenceToNumbers(oligo);
end % if ischar(oligo)
Last=oligo(end); OneBefore=oligo(end-1); TwoBefore=oligo(end-2); ThreeBefore=oligo(end-3);
if (Last == 2 || Last == 3)  && (OneBefore == 2 || OneBefore == 3)  && (TwoBefore == 2 || TwoBefore == 3)...
        && (ThreeBefore == 2 || ThreeBefore == 3) 
    GCC=1;
else
    GCC=0;
end