function IDTReady(varargin)

% Input: 
% IDTReady('MS',MS_IDs path,'BS',BS_IDs path,'SaveFolder',Save path). 
% Optional: 
% 1. IDTReady('MS',MS_IDs path,'BS',BS_IDs path,'SaveFolder',Save path,'Toggle', Toggle path).
% Tab-seperated keywords text file. First column keywords, second column sec name. This will match a keyword with a desired secondary. Helpful when there is a desire to image different targets together/separately.
% 2. NumSecondaries - number of secondaries to toggle. Unless specified in Toggle file. Default is 3. 
% 3. Activator - 0 if you don't want a STORM activator oligo, 1 if you do. Default is 1. 
% 4. Format - IDTReady('MS',MS_IDs path,'BS',BS_IDs path,'SaveFolder',Save path,'Format',format). Default is 'Auto'. You can also specify 'Tubes', '96 Plate' or '384 Plate'
% 5. Universal - IDTReady('MS',MS_IDs path,'BS',BS_IDs path,'SaveFolder',Save path,'Universal',Universal path). This is to also print the universal primers.

%% Parse input
delimiter = char(9); % for a tab

TogFlag=0;
UFlag=0;
ToeFlag=1;
Format='Auto';
NumSecondaries=3; % Default number of secondaries to use unless specified otherwise by user.
Activator=1; % Add activator oligo for STORM

for i=1:2:nargin-1
    if strcmp(varargin{i},'BS')
        BSFileName=varargin{i+1};
    elseif strcmp(varargin{i},'MS')
        MSFileName=varargin{i+1};
    elseif strcmp(varargin{i},'Format')
        Format=varargin{i+1}; % Allowed formats are 'Tubes', '96 Plate', '384 Plate'
    elseif strcmp(varargin{i},'Toggle')
        ToggleFileName=varargin{i+1};
        TogFlag=1;
    elseif strcmp(varargin{i},'SaveFolder')
        SaveFolder=varargin{i+1};
    elseif strcmp(varargin{i},'Universal')
        UniversalFileName=varargin{i+1};
        UFlag=1;
    elseif strcmp(varargin{i},'Toe')
        if strcmp(varargin{i},'No')
            ToeFlag=0;
        elseif strcmp(varargin{i+1},'Yes')
            ToeFlag=1;
        end % if strcmp(varargin{i},'No')
    elseif strcmp(varargin{i},'NumSecondaries') && TogFlag==0
        NumSecondaries=varargin{i+1}; 
    elseif strcmp(varargin{i},'Activator')
        Activator=varargin{i+1}; % Do you want an activator?
    end % if strcmp(varargin{i},'BS')
end % for i=1:2:nargin-1


fileID = fopen(MSFileName); % Load MS info
HeaderSpec = '%s';
N=6;
MSHeader = textscan(fileID,HeaderSpec,N,'Delimiter',delimiter);
formatSpec = '%s %d %d %s %s %s';
MS=textscan(fileID,formatSpec,'Delimiter',delimiter,'HeaderLines',1);
fclose(fileID);

fileID = fopen(BSFileName); % Load BS info
HeaderSpec = '%s';
N=6;
BSHeader = textscan(fileID,HeaderSpec,N,'Delimiter',delimiter);
formatSpec = '%s %d %d %s %s %s';
BS=textscan(fileID,formatSpec,'Delimiter',delimiter,'HeaderLines',1);
fclose(fileID);

if UFlag==1 % Universal primers as well
    fileID = fopen(UniversalFileName);
    formatSpec = '%d %s %d %s';
    Universal = textscan(fileID,formatSpec,'Delimiter',delimiter,'HeaderLines',1);
    fclose(fileID);
end % if UFlag==1

if TogFlag==1
    fileID = fopen(ToggleFileName);
    formatSpec = '%s %s';
    Toggle = textscan(fileID,formatSpec,'Delimiter',delimiter);
    fclose(fileID);
end % if TogFlag==1


T7Promoter='TAATACGACTCACTATAGGG';

Sec{1}.ID='Activator';
Sec{2}.ID='Sec6';
Sec{3}.ID='Sec5';
Sec{4}.ID='Sec1';
Sec{5}.ID='Sec2';
Sec{6}.ID='Sec3';
Sec{7}.ID='Sec4';
Sec{1}.BindingSite='GGTCTTACAGCGGCGCAATG';
Sec{2}.BindingSite='CACACGCTCTCCGTCTTGGCCGTGGTCGATCA';
Sec{3}.BindingSite='TAGCGCAGGAGGTCCACGACGTGCAAGGGTGT';
Sec{4}.BindingSite='CACCGACGTCGCATAGAACGGAAGAGCGTGTG';
Sec{5}.BindingSite='CGCAGCTCCACTTGATCTCGCTGGATCGTTCT';
Sec{6}.BindingSite='CGAGCCAGGTCATCCTAGCCCATACGGCAATG';
Sec{7}.BindingSite='GGTGTGGCTCGGTATCGTGCAAGGGTGAATGC';
Spacer='TT';

Scale.Toe = '250nmol';
Scale.Bridge = '1umol';
Scale.Primer = '250nmol';
Purification.Bridge = 'HPLC';
Purification.Toe = 'STD';
Purification.Primer = 'STD';
%% Prepare csv file

NumMSIDs=size(MS{1,1},1);
NumBSIDs=size(BS{1,1},1);
if ToeFlag==1
    SumIDs=(NumMSIDs+NumBSIDs)*3+2; % number of bridges, toes, primers, and universals
else
    SumIDs=(NumMSIDs+NumBSIDs)*2+2; % number of bridges, primers, and universals
end % if ToeFlag==1
    

if strcmp(Format,'Auto')
    if SumIDs<24 % IDT requirements
        Format='Tubes';
    elseif SumIDs>=24 && SumIDs<=96 % IDT requirements
        Format='96 Plate';
    elseif SumIDs>96 && SumIDs<=384 % IDT requirements
        Format='384 Plate';
    end % if SumIDs<=96
end % if strcmp(Format,'Plate')

if strcmp(Format,'96 Plate')
    WellRow=["A","B","C","D","E","F","G","H"];
    WellPos=strings(8,12);
    for i=1:8
        for j=1:12
            WellPos(i,j)=strcat(WellRow(1,i),num2str(j));
        end % for j=1:12
    end % for i=1:8
    WellPos=reshape(WellPos.',[96,1]);
elseif strcmp(Format,'384 Plate')
    WellRow=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P"];
    WellPos=strings(16,24);
    for i=1:16
        for j=1:24
            WellPos(i,j)=strcat(WellRow(1,i),num2str(j));
        end % for j=1:24
    end % for i=1:16
    WellPos=reshape(WellPos.',[384,1]);
end % if strcmp(Format,'96 Plate')

TogID=0;
for i=1:NumMSIDs
    MSOutput.Primers{i,1}=strcat('Forward Primer',{' '},MS{1,1}{i});
    MSOutput.Primers{i,2}=MS{1,6}{i};
    if TogFlag==1
        for j=1:size(Toggle{1,1},1)
            if contains(MS{1,1}{i},Toggle{1,1}{j,1})
                TogID=str2double(regexp(Toggle{1,2}(j),'\d*','Match')); % Returns the number of the Secondary
            end % if contains(MS{1,1}{i},Toggle{1,1}{j,1})
        end % for j=1:size(Toggle{1,1},1)
    else
        if TogID<NumSecondaries % If no input file, will toggle Secondaries in this order: 6,5,1,2,3,4.
            TogID=TogID+1;
        else
            TogID=1;
        end % if TogID<3
    end % if TogFlag==1
    MSOutput.Bridges{i,1}=strcat('MS Bridge',{' '},MS{1,1}{i},{' '},Sec{TogID+1}.ID);
    if Activator==1
        MSOutput.Bridges{i,2}=strcat(MS{1,5}{i},Sec{1}.BindingSite,Spacer,Sec{TogID+1}.BindingSite); % '5-Bridge-Activator-Spacer-Sec-3'
    else
        MSOutput.Bridges{i,2}=strcat(MS{1,5}{i},Sec{TogID+1}.BindingSite); % '5-Bridge-Sec-3'
    end % if Activator==1
    if ToeFlag==1
        MSOutput.Toes{i,1}=strcat('MS Toe',{' '},MS{1,1}{i});
        MSOutput.Toes{i,2}=MS{1,4}{i};
    end % if ToeFlag==1
    if TogFlag==1
        TogID=[];
    end % if TogFlag==1
end % for i=1:NumMSIDs

TogID=0;
for i=1:NumBSIDs
    BSOutput.Primers{i,1}=strcat('T7 Reverse Primer',{' '},BS{1,1}{i});
    BSOutput.Primers{i,2}=strcat(T7Promoter,BS{1,6}{i}); % T7 Rev primer
    if TogFlag==1
        for j=1:size(Toggle{1,1},1)
            if contains(BS{1,1}{i},Toggle{1,1}{j,1})
                TogID=str2double(regexp(Toggle{1,2}(j),'\d*','Match')); % Returns the number of the Secondary
            end % if contains(BS{1,1}{i},Toggle{1,1}{j,1})
        end % for j=1:size(Toggle{1,1},1)
    else
        if TogID<NumSecondaries % If no input file, will toggle Secondaries in this order: 6,5,1,2,3,4.
            TogID=TogID+1;
        else
            TogID=1;
        end % if TogID<3
    end % if TogFlag==1
    BSOutput.Bridges{i,1}=strcat('BS Bridge',{' '},BS{1,1}{i},{' '},Sec{TogID+1}.ID);
    if Activator==1
        BSOutput.Bridges{i,2}=strcat(Sec{1}.BindingSite,Spacer,Sec{TogID+1}.BindingSite,BS{1,5}{i}); %'5-Activator-Spacer-Sec-Bridge-3'
    else
        BSOutput.Bridges{i,2}=strcat(Sec{TogID+1}.BindingSite,BS{1,5}{i}); %'5-Sec-Bridge-3'
    end % if Activator==1
    if ToeFlag==1
        BSOutput.Toes{i,1}=strcat('BS Toe',{' '},BS{1,1}{i});
        BSOutput.Toes{i,2}=BS{1,4}{i};
    end % if ToeFlag==1
    if TogFlag==1
        TogID=[];
    end % if TogFlag==1
end % for i=1:NumBSIDs

if UFlag==1
    UniOutput.Primers{1,1}='Universal Forward Primer';
    UniOutput.Primers{1,2}=Universal{1,2}{1,1};
    UniOutput.Primers{2,1}='Universal T7 Reverse Primer';
    UniOutput.Primers{2,2}=strcat(T7Promoter,Universal{1,4}{1,1});
end % if UFlag==1

%% Write to csv file
MSFields=fieldnames(MSOutput);
MSrows=numel(MSFields)*size(MSOutput.(MSFields{1,1}),1);
BSFields=fieldnames(BSOutput);
BSrows=numel(fieldnames(BSOutput))*size(BSOutput.(BSFields{1,1}),1);
SaveFile=strcat(SaveFolder,'Order.xls');
OrderFile=fopen(SaveFile,'w');
if strcmp(Format,'96 Plate') || strcmp(Format,'384 Plate')
    formatSpec='%s\t%s\t%s\n';
    Header=["Well Position","Name","Sequence"];
    
    fprintf(OrderFile,formatSpec,Header);
    WellIdx=0;
    
    if UFlag==1
        fprintf(OrderFile,formatSpec,WellPos(1),UniOutput.Primers{1,1},UniOutput.Primers{1,2});
        fprintf(OrderFile,formatSpec,WellPos(2),UniOutput.Primers{2,1},strcat(UniOutput.Primers{2,2}));
        WellIdx=2;
    end % if UFlag==1
    
    for i=1:numel(MSFields)
        for j=1:size(MSOutput.(MSFields{i,1}),1)
            fprintf(OrderFile,formatSpec,WellPos(j+size(MSOutput.(MSFields{i,1}),1)*(i-1)+WellIdx),MSOutput.(MSFields{i,1}){j,1}{1},MSOutput.(MSFields{i,1}){j,2});
        end % for j=1:size(MSOutput.(MSFields{i,1}),1)
    end % i=1:numel(MSFields)
    WellIdx=i*j+WellIdx;
    
    for i=1:numel(BSFields)
        for j=1:size(BSOutput.(BSFields{i,1}),1)
            fprintf(OrderFile,formatSpec,WellPos(j+size(BSOutput.(BSFields{i,1}),1)*(i-1)+WellIdx),BSOutput.(BSFields{i,1}){j,1}{1},BSOutput.(BSFields{i,1}){j,2});
        end % for j=1:size(BSOutput.(BSFields{i,1}),1)
    end % i=1:numel(BSFields)
    
    fclose(OrderFile);
elseif strcmp(Format,'Tubes')
    formatSpec='%s\t%s\n';
    Header=["Name","Sequence"];
    fprintf(OrderFile,formatSpec,Header);
    
    if UFlag==1
        fprintf(OrderFile,formatSpec,UniOutput.Primers{1,1},UniOutput.Primers{1,2});
        fprintf(OrderFile,formatSpec,UniOutput.Primers{2,1},UniOutput.Primers{2,2});
    end % if UFlag==1
    
    for i=1:numel(MSFields)
        for j=1:size(MSOutput.(MSFields{i,1}),1)
            fprintf(OrderFile,formatSpec,MSOutput.(MSFields{i,1}){j,1}{1},MSOutput.(MSFields{i,1}){j,2});
        end % for j=1:size(MSOutput.(MSFields{i,1}),1)
    end % for i=1:numel(MSFields)
    
    for i=1:numel(BSFields)
        for j=1:size(BSOutput.(BSFields{i,1}),1)
            fprintf(OrderFile,formatSpec,BSOutput.(BSFields{i,1}){j,1}{1},BSOutput.(BSFields{i,1}){j,2});
        end % j=1:size(BSOutput.(BSFields{i,1}),1)
    end % i=1:numel(BSFields)
    
    fclose(OrderFile);
end % if strcmp(Format,'96 Plate') || strcmp(Format,'384 Plate')

