WorkingFolder = '/Volumes/HDD/ChurchLab/Bobby/OimyakonProbes';
listing=dir(WorkingFolder);
j=1;
h=waitbar(0,'Please wait');
for i=1:size(listing,1)
    if strcmp('O',listing(i,1).name(1))
        command = ['bedtools intersect -wa -wb -a ',WorkingFolder,'/ROIChr',num2str(j),...
            '.bed',' -b ',WorkingFolder,'/OimyakonChromosome',num2str(j),...
            '_b_k18_5.bed -sorted >',WorkingFolder,'/OimyakonChromosome',num2str(j),'_b_k18_5_Isected.txt'];
            [status,cmdout] = unix(command);
            j=j+1;
    end % if strcmp('O',listing(i,1).name(1))
    waitbar(i/size(listing,1))
end % for i=1:size(listing,1)
close(h)