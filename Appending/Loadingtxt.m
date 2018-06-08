function Loadtxt = Loadingtxt(InputFile)
%% Documentation
% This function loads a txt file
% input - Leave blank if you want the function to open an 'open box', or
% enter the file path
%% Loading
switch nargin
    case 0
        [FileName,PathName] = uigetfile({'*.txt','*.xlsx'},'Select the txt file to load');
        fid = fopen([PathName,FileName]);
    case 1
        fid = fopen(InputFile);
end
delimiter = char(9); %for a tab
tLines = fgets(fid);
numCols = numel(strfind(tLines,delimiter)) + 1;
txtfile=textscan(fid,'%s','Delimiter','\t');
fclose(fid);
%% Orginizing text file
Loadtxt{1,1}=[];
k=1;
h=waitbar(0,'Please wait, loading text file');
for i=1:numCols:length(txtfile{1,1})-numCols+1
    for j=1:numCols
        Loadtxt{k,j}=txtfile{1,1}(i);
        i=i+1;
    end % for j=1:numCols
    i=i-numCols;
    k=k+1;
    waitbar(i/(length(txtfile{1,1})-numCols))
end
close(h)