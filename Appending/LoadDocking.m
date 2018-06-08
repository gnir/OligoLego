function Docking = LoadDocking(varargin)
%% Documentation
% The function opens a dialouge box asking for the user to find the docking
% sequences file. The function outputs the docking sequences in a matrix,
% where 'A'=1, 'C'=2, 'G'=3, 'T'=4. If you enter 'seq', the function
% will return the sequence and no numbers. If you enter 'seqU' it will
% return the aequence with the letter 'U' instead of 'T', which is useful for
% Nupack.
%% Load PAINT sequences
[FileName,PathName] = uigetfile({'*.txt','*.xlsx'},'Select the docking sequences file');
PAINT=Loadingtxt([PathName,FileName]);
Dock=PAINT(:,3);
switch nargin
    case 0
        Docking=zeros(size(Dock,1),length(Dock{1,1}{1,1}));
        for i=1:size(Dock,1)
            for j=1:length(Dock{i,1}{1,1})
                switch Dock{i,1}{1,1}(j)
                    case 'A'
                        Docking(i,j)=1;
                    case 'C'
                        Docking(i,j)=2;
                    case 'G'
                        Docking(i,j)=3;
                    case 'T'
                        Docking(i,j)=4;
                end % switch Dock{i,1}{1,1}(j)
            end % for j=1:length(Dock{i,1}{1,1})
        end % for i=1:size(Dock,1)
    case 1
        if strcmp(varargin{1},'seq')
            Docking=Dock;
        elseif strcmp(varargin{1},'seqU')
            Docking=Dock;
            for i=1:size(Dock,1)
                for j=1:length(Dock{i,1}{1,1})
                    switch Dock{i,1}{1,1}(j)
                        case 'T'
                            Docking{i,1}{1,1}(j)='U';
                    end % switch Dock{i,1}{1,1}(j)
                end % for j=1:length(Dock{i,1}{1,1})
            end % for i=1:size(Dock,1)
        end
end % switch nargin