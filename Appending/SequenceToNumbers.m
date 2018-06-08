function Seq2Num = SequenceToNumbers(oligo)
% This function translates a sequence to numbers.
% 'A' = 1; 'C' = 2; 'G' = 3; 'T' = 4;
Seq2Num=zeros(size(oligo,1),size(oligo,2));
for i=1:size(oligo,1)
    for j=1:size(oligo,2)
        switch oligo(i,j)
            case 'A'
                Seq2Num(i,j)=1;
            case 'C'
                Seq2Num(i,j)=2;
            case 'G'
                Seq2Num(i,j)=3;
            case 'T'
                Seq2Num(i,j)=4;
        end % switch oligo(i,j)
    end % for j=1:size(oligo,2)
end % for i=1:size(oligo,1)