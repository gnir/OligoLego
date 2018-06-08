function filterToehold = FilterToehold(InputFile,Existing)
%% Documentation
% This function filters toehold of 27 nt, where the first 7nt at the 5', are ssDNA overhang,
% the 20th nt is a G/C, and it excludes polyN=5, or polyGC=4.
%  The function then cehcks for duplex stabilty with toehold's RC and
%  toehold's RC for the 20 nt not including 7 nt overhangs.
% The function will run in a while loop until satisfying conditions for
% stability are met.
% Input: InputFile - Toehold.fold; MakingStreets will generate it for you.
% Existing - pool of oligos to filter.
% Output: the toehold sequence.
%% Toehold design

k=1;
for ii=1:size(Existing,1)
    flag=0; ToeFlag=0;
    
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
    
    designCmd=sprintf('design -material dna -init SSM -T 55 -sodium 0.157 -magnesium 0 -pairs -prevent %s %s', PreventPath, NUPACKInputPath);
    % 1x PBS, 50% formamide. Tc = -0.65 per 1% FA.
    
    ToeStrand=cell2str(Existing{ii,1});
    ToeStrand=ToeStrand(3:end-3);
    Bridge=ToeStrand(8:end);
    ToeRC=ReverseComplement(ToeStrand,1);
    
    inPath=strcat(NUPACKInputPath,'.in');
    fileID=fopen(inPath,'w');
    fprintf(fileID,'3\n%s\n%s\n%s\n2\n',ToeStrand,Bridge,ToeRC);
    fclose(fileID);
    
    complexesCmd=sprintf('complexes -T 55 -material dna -sodium 0.157 -magnesium 0 %s', NUPACKInputPath);
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
    if FilterStreets(ToeNum(8:end))==1 &&  ...
            FilterStreets(ReverseComplement(ToeNum(8:end)))==1 && ...
               FilterStreets(ToeNum(1:20))==1 % filter streets
            %FilterStreets(ReverseComplement(ToeNum(1:20)))==1 
        flag=1;
    end % if FilterStreets(ToeStrand)==1 % filter streets
    if flag==1 && ToeFlag==1
        filterToehold(k)=ToeStrand;
        k=k+1;
    end % if flag==1 && ToeFlag==1
end % for i=1:size(Existing,1)