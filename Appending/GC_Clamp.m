function GC_clamp = GC_Clamp(oligo)
%% This function reports if the last nucleotides in an oligo is either 'A' and 'T'
% input: vector containing numbers 1 to 4, where 1='A', 2='C', 3='G', 4='T'
% output: '0' for yes and '1' for No GC.
%% Finding GC
if ischar(oligo)
    oligo=SequenceToNumbers(oligo);
end % if ischar(oligo)
Last=oligo(end); 
if (Last == 2 || Last == 3) % && (OneBefore == 2 || OneBefore == 3)  && (TwoBefore == 2 || TwoBefore == 3)
    GC_clamp=0;
else
    GC_clamp=1;
end