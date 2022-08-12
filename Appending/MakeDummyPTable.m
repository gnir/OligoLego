function PTablePath = MakeDummyPTable(N_Streets,SavePath)
% Function creates a dummy penalty table with the size defined by
% N_Streets.
% Input - N_Streets, an integer which should be the number of streets the
% user has. SavePath - A path to save the table.
% Output - a Penaltytable with values of '1' that will allow any
% combination.
penaltyMat=ones(N_Streets);
v(1,1:N_Streets)=nan;
v=diag(v);
penaltyMat=v+penaltyMat; % Add nan to the diagonal
prefixT=strcat('DummyPenaltyTable','.txt');
SaveName=strcat(SavePath,prefixT);
fileID=fopen(SaveName,'w');
for i=1:size(penaltyMat,1)
    flag=0;
    for j=1:size(penaltyMat,2)
        if j==size(penaltyMat,2)
            flag=1;
        end % if j==size(penaltyMat,2)
        if isnan(penaltyMat(i,j)) && flag~=1
            fprintf(fileID,'%s\t',penaltyMat(i,j));
        elseif isnan(penaltyMat(i,j)) && flag==1
            fprintf(fileID,'%s\n',penaltyMat(i,j));
        elseif ~isnan(penaltyMat(i,j)) && flag~=1
            fprintf(fileID,'%d\t',penaltyMat(i,j));
        elseif ~isnan(penaltyMat(i,j)) && flag==1
            fprintf(fileID,'%d\n',penaltyMat(i,j));
        end % if isnan(penaltyMat(i,j)) && flag~=1
    end % for j=1:size(penaltyMat,2)
end % for i=1:size(penaltyMat,1)
fclose(fileID);
PTablePath=SaveName;