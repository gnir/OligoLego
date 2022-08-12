function ApOPs(varargin)
%% Documentation
% This function appends streets/toes to Oligopaints probes.
% Required input:
% 1. 'MS' - MainStreet intersected text (*.txt) file, which is the
% output of bedtools intersect -wa -wb -a ROI.bed -b probes.bed
% When intersecting, please add a 4th column for your ROI file, which
% is the names of each region (user-defined)
% 2. Streets - A text file, which is a list of mainstreets/backstreets.
% This file can be created using 'MakingStreets.m'.
% 3. PairsMatrix text file, which can be created using 'MakingStreets.m'.
% 4. Maximum street number to avoid, which is the number of the highest
% previous Street used for appending, in case would like to avoid using
% same streets, when running the script multiple times.
% 4. SavePath - The path where you want to save the outputs of this
% function.
% Optional input:
% 5. 'BS' - BackStreet intersected text (*.txt) file (same format as the
% MainStreet)
% 6. In ase would like to make library compatible with toeholds, so the RC
% of the toehold will become the mainstreet/backstreet.
% Output:
% 1. Oligopaints.txt - a text file which has all the oligopaints (OPs) of the
%library. Each line is a different OP.
% 2. MS_IDs.txt - a list with the Forward primers, bridges and toeholds (if
% asked to) sequences.
% 3. BS_IDs.txt - if a backstreet list was given as an input as well, will
% have the same for backstreet.
% 4. MSDensity.txt - Density of rgions
% 5. BSDensity.txt - if a backstreet list was given as an input as well, will
% have the same for backstreet.
% 6. Universal.txt - forward and reverse primer sequence for universals.

% An example for running the function to append mainstreets, backstreets,
% with toes, where the highest street to avoid is 0
% ApOPs('MS','/Volumes/HDD/NunoM/NunoIsected.txt','BS','/Volumes/HDD/NunoM/NunoIsected.txt','Streets','/Users/guynir/Documents/MATLAB/Scratch/Streets_galGal4.txt','PTable','/Users/guynir/Documents/MATLAB/Scratch/PenaltyTable_galGal4.txt','Toes','/Users/guynir/Documents/MATLAB/Scratch/Toes_galGal4.txt','SavePath','/Volumes/HDD/NunoM/Scratch/','MaxAvoid','0');

%% Arranging input
AppendToes=0;
AppendBS=0;
MaxAvoid=0;
SOLiDBarcoding=0;
SameUniFlag=0;
PTFlag=0;
MultiUniFlag=0;
N_BS=1; N_MS=1; % Number of MS and BS barcodes on each street
for i=1:2:nargin-1
    if strcmp(varargin{i},'Toes')
        AppendToes=1;
        ToesPath=varargin{i+1};
    elseif strcmp(varargin{i},'MaxAvoid')
        MaxAvoid=str2double(varargin{i+1});
    elseif strcmp(varargin{i},'BS')
        BSPath=varargin{i+1};
        AppendBS=1;
    elseif strcmp(varargin{i},'MS')
        MSPath=varargin{i+1};
    elseif strcmp(varargin{i},'Streets')
        StreetsPath=varargin{i+1};
    elseif strcmp(varargin{i},'PTable')
        PTablePath=varargin{i+1};
        PTFlag=1;
    elseif strcmp(varargin{i},'SavePath')
        SavePath=varargin{i+1};
    elseif strcmp(varargin{i},'SameUniversal')
        UniPath=varargin{i+1};
        SameUniFlag=1;
    elseif strcmp(varargin{i},'MultipleUniversals')
        MultiUniFlag=1;
        numUni=varargin{i+1};
    elseif strcmp(varargin{i},'SOLiDStreets')
        SOLiDBarcoding=1;
        Hamming=varargin{i+1};
    elseif strcmp(varargin{i},'SOLiDToes')
        SOLiDBarcoding=2;
        Hamming=varargin{i+1};
    elseif strcmp(varargin{i},'NBS')
        N_BS=varargin{i+1};
    elseif strcmp(varargin{i},'NMS')
        N_MS=varargin{i+1};
    end % if strcmp(varargin{i},'Toes')
end % for i=1:2:nargin-1
if PTFlag==0
    command=['wc -l ',StreetsPath];
    [status,cmdout] = unix(command);
    N_Streets=str2double(cmdout(isstrprop(cmdout,'digit')));
    PTablePath=MakeDummyPTable(N_Streets,StreetsPath); % Will save to the Streetpath
end % if PTFlag==0
%% Call specific appending street function
if AppendToes==1 && AppendBS==1 && SameUniFlag==0 && ...
        SOLiDBarcoding==0 && MultiUniFlag==0
    AppToMSBS(MSPath,BSPath,StreetsPath,PTablePath,ToesPath,MaxAvoid,SavePath);
elseif AppendToes==1 && AppendBS==1 && SameUniFlag==0 && ...
        SOLiDBarcoding==0 && MultiUniFlag==1
    AppToMSBS(MSPath,BSPath,StreetsPath,PTablePath,ToesPath,MaxAvoid,SavePath,'MultipleUniversals',numUni);
elseif AppendToes==1 && AppendBS==1 && SameUniFlag==1 && SOLiDBarcoding==0
    AppToMSBS(MSPath,BSPath,StreetsPath,PTablePath,ToesPath,MaxAvoid,SavePath,'SameUniversal',UniPath);
elseif AppendToes==1 && AppendBS==1 && SameUniFlag==0 && SOLiDBarcoding==1
    AppToMSBS(MSPath,BSPath,StreetsPath,PTablePath,ToesPath,MaxAvoid,SavePath,'SOLiDStreets',Hamming); 
elseif AppendToes==1 && AppendBS==1 && SameUniFlag==0 && SOLiDBarcoding==2
    AppToMSBS(MSPath,BSPath,StreetsPath,PTablePath,ToesPath,MaxAvoid,SavePath,'SOLiDToes',Hamming); 
elseif AppendToes==1 && AppendBS==1 && SameUniFlag==1 && SOLiDBarcoding==1
    AppToMSBS(MSPath,BSPath,StreetsPath,PTablePath,ToesPath,MaxAvoid,SavePath,'SameUniversal',UniPath,'SOLiDStreets',Hamming);   
elseif AppendToes==1 && AppendBS==1 && SameUniFlag==1 && SOLiDBarcoding==2
    AppToMSBS(MSPath,BSPath,StreetsPath,PTablePath,ToesPath,MaxAvoid,SavePath,'SameUniversal',UniPath,'SOLiDToes',Hamming);
elseif AppendToes==0 && AppendBS==0 && SameUniFlag==0 && SOLiDBarcoding==0
    AppMS(MSPath,StreetsPath,PTablePath,MaxAvoid,SavePath);
elseif AppendToes==0 && AppendBS==0 && SameUniFlag==1 && SOLiDBarcoding==0
    AppMS(MSPath,StreetsPath,PTablePath,MaxAvoid,SavePath,'SameUniversal',UniPath);
elseif AppendToes==0 && AppendBS==0 && SameUniFlag==0 && SOLiDBarcoding==1
    AppMS(MSPath,StreetsPath,PTablePath,MaxAvoid,SavePath,'SOLiDStreets',Hamming);
elseif AppendToes==0 && AppendBS==0 && SameUniFlag==1 && SOLiDBarcoding==1
    AppMS(MSPath,StreetsPath,PTablePath,MaxAvoid,SavePath,'SameUniversal',UniPath,'SOLiDStreets',Hamming);
elseif AppendToes==0 && AppendBS==1 && SameUniFlag==0 && SOLiDBarcoding==0
    AppMSBS(MSPath,BSPath,StreetsPath,PTablePath,MaxAvoid,SavePath)
elseif AppendToes==0 && AppendBS==1 && SameUniFlag==1 && SOLiDBarcoding==0
    AppMSBS(MSPath,BSPath,StreetsPath,PTablePath,MaxAvoid,SavePath,'SameUniversal',UniPath)
elseif AppendToes==0 && AppendBS==1 && SameUniFlag==0 && SOLiDBarcoding==1
    AppMSBS(MSPath,BSPath,StreetsPath,PTablePath,MaxAvoid,SavePath,'SOLiDStreets',Hamming)
elseif AppendToes==0 && AppendBS==1 && SameUniFlag==1 && SOLiDBarcoding==1
    AppMSBS(MSPath,BSPath,StreetsPath,PTablePath,MaxAvoid,SavePath,'SameUniversal',UniPath,'SOLiDStreets',Hamming)
else
    prefix='Error.txt';
    outputError=strcat(SavePath,prefix);
    fileID=fopen(outputError,'w');
    fprintf(fileID,'The requested the design is not scurrently supported\n');
    fclose(fileID);
end % if AppendToes==1 && AppendBS==1 && SameUniFlag==0