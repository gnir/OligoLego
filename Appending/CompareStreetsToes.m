Streets=Loadingtxt;
Streets=cellfun(@char,Streets,'UniformOutput',false);
Toes=Loadingtxt;
Toes=cellfun(@char,Toes,'UniformOutput',false);
%%
clear NumStreets
t=1;
for i=1:size(Streets,1)-1
    for j=i+1:size(Streets,1)
        if strcmp(Streets{i,1},Streets{j,1})
            NumStreets(t,1)=i;
            NumStreets(t,2)=j;
            t=t+1;
        end % if strcmp(Streets{i,1},Toes{j,1}(8:end))
    end % for j=1:size(Toes,1)
end % for i=1:size(Streets,1)
%%
for i=1:NumStreets(1,2)-1
    TempStreets{i,1}=Streets{i,1};
    TempToes{i,1}=Toes{i,1};
end %
Streets=[];
Toes=[];
Streets=TempStreets;
Toes=TempToes;
%%
clear NumStreets
t=1;
for i=1:size(Streets,1)
    for j=1:size(Toes,1)
        if strcmp(Streets{i,1},Toes{j,1}(8:end))
            NumStreets(t,1)=i;
            NumStreets(t,2)=j;
            t=t+1;
        end % if strcmp(Streets{i,1},Toes{j,1}(8:end))
    end % for j=1:size(Toes,1)
end % for i=1:size(Streets,1)
%%
clear StreetsTemp
clear ToesTemp
for i=1:size(NumStreets,1)
    StreetsTemp(i,:)=Streets{NumStreets(i,1)};
    ToesTemp(i,:)=Toes{NumStreets(i,2)};
end % for i=1:size(NumStreets,1)
Streets=[];
Toes=[];
Streets=StreetsTemp;
Toes=ToesTemp;
%%
clear Streets_seq
for i=1:size(Streets,1)
    Streets_seq{1,i}=Streets(i,:);
end % for i=1:size(Streets,1)
%%
t=1;
MergedStreets=[Streets_seq,Streets_seq_a];
MergedToes=cat(1,Toes3,Toes3_a);
for i=1:size(MergedStreets,2)-1
    for j=i+1:size(MergedStreets,2)
       if strcmp(MergedStreets{1,i},MergedStreets{1,j})
           Match(t,1)=i;
           Match(t,2)=j;
           t=t+1;
       end % if strcmp(MergedStreets{1,i},MergedStreets{1,j})
    end % for j=i+1:size(MergedStreets,2)
end % for i=1:size(MergedStreets,2)-1
%%
t=1;
for i=1:size(Match,1)
    MergedStreets{1,Match(i,2)}=[];
    MergedToes(Match(i,2),:)=[];
end % for i=1:size(Match,1)
 for i=1:size(MergedStreets,2)   
     if ~isempty(MergedStreets{1,i})
         Streets_seq{1,t}=MergedStreets{1,i};
         t=t+1;
     end % if ~isempty(MergedStreets{1,i})
 end %  for i=1:size(MergedStreets,2)   