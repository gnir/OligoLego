function RepBitBarcode(varargin)
%{ 
Documentation:
RepBitBarcode('filename',Path to the bits file,'Hamming',hamming
distance,'BarcodeLength', Length of the barcodes,'N_Streets',number of
barcodes you want,'SaveFolder',folder path where you want to save the barcodes
list)
Example:
RepBitBarcode('filename','/Users/guynir/Documents/MATLAB/Appending/4bitBarcodes.txt','Hamming',2,'BarcodeLength',25,'N_Streets',165,'SaveFolder','/Users/guynir/Documents/MATLAB/');
Output is a text file Barcodes.txt
%}
%% Arranging input
for i=1:2:nargin-1
    if strcmp(varargin{i},'filename')
        filename=varargin{i+1};
    elseif strcmp(varargin{i},'Hamming')
        Hamming=varargin{i+1};
    elseif strcmp(varargin{i},'BarcodeLength')
        BarcodeLength=varargin{i+1};
    elseif strcmp(varargin{i},'N_Streets')
        N_Streets=varargin{i+1};
    elseif strcmp(varargin{i},'SaveFolder')
        SaveFolder=varargin{i+1};
    end % if strcmp(varargin{i},'filename')
end % for i=1:2:nargin-1
%% Generate Barcodes
Barcodes=readtextfile(filename);
N_Shuffles=floor(BarcodeLength/size(Barcodes,2));
NewStreet=zeros(N_Streets,N_Shuffles);
NewStreet(1,:)=randi([1 4],1,N_Shuffles);
h = waitbar(0,'Generating barcodes, please wait');
for i=2:N_Streets
    flag=0;
    while flag==0
        NewStreet(i,:)=randi([1 4],1,N_Shuffles);
        CheckHam=zeros(i,N_Shuffles);
        Counter=0;
        for j=i-1:-1:1
            CheckHam=abs(NewStreet(i,:)-NewStreet(j,:));
            CheckHamSum=length(~find(CheckHam)); % Find how many zeros (which means how many are the same)
            if CheckHamSum>=Hamming
                Counter=Counter+1;
            end % if CheckHamSum<Hamming
        end % for j=i-1:-1:1
        if Counter==i-1
            flag=1;
        end % if Counter==i-1
    end % while flag==0
    waitbar(i/N_Streets)
end % for i=1:N_Streets
close(h)

BList=strings(N_Streets,1);
for i=1:N_Streets
    s=Barcodes(NewStreet(i,:),:);
    for j=1:N_Shuffles
        BList{i}((j-1)*size(s,2)+1:j*size(s,2))=s(j,:);
    end % for j=1:N_Shuffles
end % for i=1:N_Streets

%% Print list to file
prefix='Barcodes.txt';
OutPut=[SaveFolder,prefix];
fileID=fopen(OutPut,'w');
for i=1:size(BList,1)
    fprintf(fileID,'%s\n',BList{i});
end % fprintf(fileID,BList(i,:));
fclose(fileID);