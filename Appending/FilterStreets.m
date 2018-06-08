function FilterStr = FilterStreets(oligo)
%% Documantation
% This function filters oligos acoording to GC content, MeltingTemp, and GC clamp.
% input: vector containing numbers 1 to 4, where 1='A', 2='C', 3='G', 4='T'
% It outputs 1 if the oligo passes the filters and 0 if not.
%% Filtering

if ischar(oligo)
    oligo=SequenceToNumbers(oligo);
end % if ischar(oligo)

FilterStr=0;
GC=0;
for j=1:length(oligo)
    if oligo(j)==2 || oligo(j)==3
        GC=GC+1;
    end % if oligo(j)==2 || oligo(j)==3
end % for j=1:length(oligo)
% Oligos that fullfill one of these following conditions will be filtered
% out.
if (GC<6 || GC>14) || (MeltingTemp(oligo)<57 || MeltingTemp(oligo)>59) || (GC_Clamp(oligo)==1)...
        || (PolydT(oligo,5)==1) || (PrimerMaxSelfAny(oligo)>=8) || (GC_3End(oligo)==1)
    oligo=[];
    FilterStr=0;
else
    FilterStr=1;
end % if GC<4 || GC>6