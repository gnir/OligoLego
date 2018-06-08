function Toehold = DesignToehold(InputFile,varargin)
%% Documentation
% This function designs a toehold of user-specified nt, where the first X nt at the 5', are ssDNA overhang,
% the 20th nt is a G/C, and it excludes polyN=5, or polyGC=4.
%  The function then cehcks for duplex stabilty with toehold's RC and
%  toehold's RC for the 20 nt not including X nt overhangs.
% The function will run in a while loop until satisfying conditions for
% stability are met.
% Input: InputFile - Toehold.fold; MakingStreets will generate it for you.
% Output: the toehold sequence.
%% Toehold design
ToeFlag=0; flag=0;
while ToeFlag==0 || flag==0
    [statusNu,Spath]=unix('echo $NUPACKHOME');
    PreventPath=strcat(Spath,'/Scratch/preventfile.txt');
    NUPACKInputPath=InputFile(1:end-5); % -.fold
    ConPath=strcat(NUPACKInputPath,'.con');
    
    fileID=fopen(PreventPath,'w');
    fprintf(fileID,'AAAAA\nCCCCC\nGGGGG\nUUUUU\nSSSS\n'); % Avoid these sequences
    fclose(fileID);
    
    StrandCon=1e-6;
    fileID=fopen(ConPath,'w');
    fprintf(fileID,'%d\n%d\n%d\n',StrandCon,StrandCon,StrandCon);
    fclose(fileID);
    
    designCmd=sprintf('design -material dna -init SSM -T 42 -sodium 0.39 -magnesium 0 -pairs -prevent %s %s', PreventPath, NUPACKInputPath);
    % 2X SSC, 30% formamide. Tc = -0.65 per 1% FA.
    switch nargin
        case 1
            
            [statusDes,Desout] = unix(designCmd);
            
            ToeSum=readtextfile(strcat(NUPACKInputPath,'.summary'));
            ToeDuplex=ToeSum(33,:);
            ToeStrand=ToeDuplex(1:find(ToeDuplex==char(43))-1);
            Bridge=ToeDuplex(find(ToeDuplex==char(43))+1:find(ToeDuplex==char(00))-1);
            ToeRC=ReverseComplement(ToeStrand,1);
        case 4
            TSFlag=0;
            StreetLength=20;
            nvarargin=numel(varargin);
            for i=1:nvarargin
                if strcmp(varargin{i},'TLength')
                    toeLength=varargin{i+1}; 
                end % if strcmp(varargin{i},'TLength')
            end % for i=1:nvarargin
            for i=1:nvarargin
                if strcmp(varargin{i},'seq')
                    ToeStrand=Numbers2Sequnces(cat(2,randi([2 3],1,1),randi([1 4],1,toeLength+StreetLength-2),randi([2 3],1,1)));
                    TSFlag=1;
                end % if strcmp(varargin{i},'seq')
            end % for i=1:nvarargin
            if TSFlag==0
                ToeStrand=varargin{1,1};
            end % if TSFlag==0
            Bridge=ToeStrand(toeLength+1:end);
            ToeRC=ReverseComplement(ToeStrand,1);
            
    end % if strcmp(varargin{1,1},'NoDes')
    
    inPath=strcat(NUPACKInputPath,'.in');
    fileID=fopen(inPath,'w');
    fprintf(fileID,'3\n%s\n%s\n%s\n2\n',ToeStrand,Bridge,ToeRC);
    fclose(fileID);
    
    complexesCmd=sprintf('complexes -T 42 -material dna -sodium 0.39 -magnesium 0 %s', NUPACKInputPath);
    concCmd=sprintf('concentrations %s', NUPACKInputPath);
    [statusComp,Compout] = unix(complexesCmd);
    [statusConc,Concout] = unix(concCmd);
    
    ToeEq=load(strcat(NUPACKInputPath,'.eq'));
    for i=1:size(ToeEq,1)
        if ToeEq(i,2)==1 && ToeEq(i,4)==1
            ToeRCStab=ToeEq(i,6)/StrandCon;
        elseif ToeEq(i,3)==1 && ToeEq(i,4)==1
            NoToeRCStab=ToeEq(i,6)/StrandCon;
        elseif ToeEq(i,2)==2
            SelfDup2=ToeEq(i,6)/StrandCon;
        elseif ToeEq(i,3)==2
            SelfDup3=ToeEq(i,6)/StrandCon;
        elseif ToeEq(i,4)==2
            SelfDup4=ToeEq(i,6)/StrandCon;
        end % if ToeEq(i,2)==1 && ToeEq(i,4)==1
    end % for i=1:size(ToeEq,1)
    if ToeRCStab>.9 && NoToeRCStab>0.001 && SelfDup2<0.0001 && SelfDup3<0.0001 && SelfDup4<0.0001
        ToeFlag=1;
    end % if ToeRCStab>.9 && NoToeRCStab>0.001 && SelfDup2<0.0001 && SelfDup3<0.0001 && SelfDup4<0.0001
    ToeNum=SequenceToNumbers(ToeStrand);
    if FilterStreets(ToeNum(toeLength+1:end))==1 &&  ...
            FilterStreets(ReverseComplement(ToeNum(toeLength+1:end)))==1 && ...
            FilterStreets(ToeNum(1:StreetLength))==1 % filter streets
        %FilterStreets(ReverseComplement(ToeNum(1:20)))==1
        flag=1;
    end % if FilterStreets(ToeStrand)==1 % filter streets
end % while ToeFlag==0 && flag==0
Toehold=ToeStrand;
