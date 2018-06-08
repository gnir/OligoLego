function Seq2Num = Numbers2Sequnces(oligo)
%% Documentation
% This function translates an array of numbers between 1-4 to sequences.
for i=1:size(oligo,1)
    for j=1:size(oligo,2)
        switch oligo(i,j)
            case 1
                Seq2Num(i,j)='A';
            case 2
                Seq2Num(i,j)='C';
            case 3
               Seq2Num(i,j)='G'; 
            case 4
                Seq2Num(i,j)='T';
        end % switch oligo (i,j)
    end % for j=1:size(oligo,2)
end % for i=1:size(oligo,1)