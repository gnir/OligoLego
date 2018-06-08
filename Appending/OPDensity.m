function OPDensity(varargin)
%% Parse input

nvarargin=numel(varargin);
MSFlag=0; BSFlag=0;
for i=1:2:nvarargin
    if strcmp(varargin{i},'MS')
        MSFlag=1;
        MSPath=varargin{i+1};
        Main = readtextfile(MSPath);
    elseif strcmp(varargin{i},'BS')
        BSFlag=1;
        BSPath=varargin{i+1};
        Back = readtextfile(BSPath);
    elseif strcmp(varargin{i},'SavePath')
        SPath=varargin{i+1};
    end % if strcmp(varargin{i,1},'MS')
end % for i=1:2:nvarargin
%% Arrange Backstreet and Mainstreet lists
if BSFlag==1
    h = waitbar(0,'organzing Backstreet list, please wait');
    for i=1:size(Back,1)
        k=1; t=1;
        for j=1:size(Back,2)
            if ~strcmp(char(00),Back(i,j))
                if ~isspace(Back(i,j))
                    BackCell{i,t}(k)=Back(i,j);
                    k=k+1;
                else
                    k=1; t=t+1;
                end % if ~isspace(Back(i,j))
            else % strcmp(char(00),Back(i,j))
                break
            end %  if ~strcmp(char(00),Back(i,j))
        end % for j=1:size(Back,2)
        waitbar(i/size(Back,1))
    end % for i=1:size(Back,1)
    close(h)
    
    clear temp
    j=1;
    for i=1:size(BackCell,1)
        if i~=size(BackCell,1)
            if ~strcmp(BackCell{i,8},BackCell{i+1,8}) &&...
                    str2double(BackCell{i,2})<=str2double(BackCell{i,6}) &&...
                    str2double(BackCell{i,3})>=str2double(BackCell{i,7})
                for k=1:size(BackCell,2)
                    temp{j,k}=BackCell{i,k};
                end
                j=j+1;
            end % if ~strcmp(BackCell{i,8},BackCell{i+1,8})
        else % if i==size(BackCell,1)
            if ~strcmp(BackCell{i,8},BackCell{i-1,8}) &&...
                    str2double(BackCell{i,2})<=str2double(BackCell{i,6}) &&...
                    str2double(BackCell{i,3})>=str2double(BackCell{i,7})
                for k=1:size(BackCell,2)
                    temp{j,k}=BackCell{i,k};
                end % for k=1:size(BackCell,2)
                j=j+1;
            end % if ~strcmp(BackCell{i,8},BackCell{i-1,8})
        end % if i~=size(BackCell,1)
    end % for i=1:size(BackCell,1)
    clear BackCell
    BackCell=temp;
end % if BSFlag==1

if MSFlag==1
    h = waitbar(0,'organzing Mainstreet list, please wait');
    for i=1:size(Main,1)
        k=1; t=1;
        for j=1:size(Main,2)
            if ~strcmp(char(00),Main(i,j))
                if ~isspace(Main(i,j))
                    MainCell{i,t}(k)=Main(i,j);
                    k=k+1;
                else
                    k=1; t=t+1;
                end % if ~isspace(Back(i,j))
            else % strcmp(char(00),Back(i,j))
                break
            end %  if ~strcmp(char(00),Back(i,j))
        end % for j=1:size(Back,2)
        waitbar(i/size(Main,1))
    end % for i=1:size(Back,1)
    close(h)
    
    clear temp
    j=1;
    for i=1:size(MainCell,1)
        if i~=size(MainCell,1)
            if ~strcmp(MainCell{i,8},MainCell{i+1,8}) &&...
                    str2double(MainCell{i,2})<=str2double(MainCell{i,6}) &&...
                    str2double(MainCell{i,3})>=str2double(MainCell{i,7})
                for k=1:size(MainCell,2)
                    temp{j,k}=MainCell{i,k};
                end % for k=1:size(MainCell,2)
                j=j+1;
            end % if ~strcmp(MainCell{i,8},MainCell{i+1,8}) &&...
        else % if i==size(MainCell,1)
            if ~strcmp(MainCell{i,8},MainCell{i-1,8}) &&...
                    str2double(MainCell{i,2})<=str2double(MainCell{i,6}) &&...
                    str2double(MainCell{i,3})>=str2double(MainCell{i,7})
                for k=1:size(MainCell,2)
                    temp{j,k}=MainCell{i,k};
                end % for k=1:size(MainCell,2)
                j=j+1;
            end % if ~strcmp(MainCell{i,8},MainCell{i-1,8})
        end % if i~=size(MainCell,1)
    end % for i=1:size(MainCell,1)
    clear MainCell
    MainCell=temp;
    
end % if MSFlag==1
%% Indexing (adding the 10th column)
if MSFlag==1
    MainCell{1,end+1}=1; idxMain(1)=1;
    PosMain(1,1)=str2double(MainCell{1,2}); PosMain(1,2)=str2double(MainCell{1,3});
    maxMID=MainCell{1,end};
    for i=1:size(MainCell,1)-1
        flag=0;
        if strcmp(MainCell{i,4},MainCell{i+1,4})
            MainCell{i+1,end}=MainCell{i,end};
            if maxMID<MainCell{i+1,end}
                maxMID=MainCell{i+1,end};
            end % maxMID=MainCell{i+1,end};
        else % ~strcmp(MainCell{i,4},MainCell{i+1,4})
            for j=i:-1:1 % check if ID exists already
                if strcmp(MainCell{i+1,4},MainCell{j,4})
                    MainCell{i+1,end}=MainCell{j,end};
                    flag=1;
                    break
                end % if strcmp(MainCell{i,4},MainCell{j,4})
            end % for j=i:-1:1 % check if ID exists already
            if flag==0
                MainCell{i+1,end}=maxMID+1;
                maxMID=MainCell{i+1,end};
                PosMain(end+1,1)=str2double(MainCell{i+1,2});
                PosMain(end,2)=str2double(MainCell{i+1,3});
                idxMain(end+1)=i+1;
            end % if flag==0
        end % if strcmp(MainCell{i,4},MainCell{j,4})
    end % for i=1:size(MainCell,1)-1
end % if MSFlag==1

if BSFlag==1
    idxBack=1;
    PosBack(1,1)=str2double(BackCell{1,2}); PosBack(1,2)=str2double(BackCell{1,3});
    BackCell{1,end+1}=maxMID+1;
    maxBID=BackCell{1,end};
    for i=1:size(BackCell,1)-1
        flag=0;
        if strcmp(BackCell{i,4},BackCell{i+1,4})
            BackCell{i+1,end}=BackCell{i,end};
            if maxBID<BackCell{i+1,end}
                maxBID=BackCell{i+1,end};
            end % maxBID=BackCell{i+1,end};
        else % ~strcmp(BackCell{i,4},BackCell{i+1,4})
            for j=i:-1:1 % check if ID exists already
                if strcmp(BackCell{i+1,4},BackCell{j,4})
                    BackCell{i+1,end}=BackCell{j,end};
                    flag=1;
                    break
                end % if strcmp(BackCell{i,4},BackCell{j,4})
            end % for j=i:-1:1 % check if ID exists already
            if flag==0
                BackCell{i+1,end}=maxBID+1;
                maxBID=BackCell{i+1,end};
                PosBack(end+1,1)=str2double(BackCell{i+1,2});
                PosBack(end,2)=str2double(BackCell{i+1,3});
                idxBack(end+1)=i+1;
            end % if flag==0
        end % if strcmp(BackCell{i,4},BackCell{i+1,4})
    end % for i=1:size(BackCell,1)-1
end % if BSFlag==1
%% Density calc for Main
if MSFlag==1
DensityMain=zeros(size(idxMain,2),4);
MainTargetID=strings(size(idxMain,2),1);
MainProbeAve=zeros(size(MainCell,1),1);

for i=1:size(MainCell,1)
    MainProbeAve(i)=(str2double(MainCell{i,7})+str2double(MainCell{i,6}))/(2*1e6);
end % for i=1:size(MainCell,1)

prefix='MSDensity.txt';
outputMSDensity=strcat(SPath,prefix);
fileID=fopen(outputMSDensity,'w');
fprintf(fileID,'MS Region\tStart\tEnd\tSize [kb]\t# of OP oligos\tDensity [Oligos/kb]\n');

for i=1:size(idxMain,2)
    MainTargetID(i)=MainCell{idxMain(i),4};
    DensityMain(i,1)=str2double(MainCell{idxMain(i),2});
    DensityMain(i,2)=str2double(MainCell{idxMain(i),3});
    DensityMain(i,3)=(DensityMain(i,2)-DensityMain(i,1))/1000;
    if i~=size(idxMain,2)
        DensityMain(i,4)=(idxMain(i+1)-idxMain(i))/DensityMain(i,3);
        figure();
        hist(MainProbeAve(idxMain(i):idxMain(i+1)-1),round(sqrt(idxMain(i+1)-idxMain(i))));
        title(['Probe histogram: ',MainTargetID(i)]);
        xlabel('Genomic Position [Mb]')
        ylabel('Frequency')
        set(gca,'FontName','Helvetica','FontSize',18)
        Prefix=[MainCell{idxMain(i),4},' Histogram.png'];
        print(gcf,[SPath,Prefix],'-r300','-dpng')
        fprintf(fileID,'%s\t%s\t%s\t%d\t%d\t%d\n',MainCell{idxMain(i),4},MainCell{idxMain(i),2},MainCell{idxMain(i),3},DensityMain(i,3),idxMain(i+1)-idxMain(i),DensityMain(i,4));
    else
        DensityMain(i,4)=(size(MainCell,1)-idxMain(i))/DensityMain(i,3);
        figure();
        hist(MainProbeAve(idxMain(i):size(MainCell,1)),round(sqrt(size(MainCell,1)-idxMain(i))));
        title(['Probe histogram: ',MainTargetID(i)]);
        xlabel('Genomic Position [Mb]')
        ylabel('Frequency')
        set(gca,'FontName','Helvetica','FontSize',18)
        Prefix=[MainCell{idxMain(i),4},' Histogram.png'];
        print(gcf,[SPath,Prefix],'-r300','-dpng')
        fprintf(fileID,'%s\t%s\t%s\t%d\t%d\t%d\n',MainCell{idxMain(i),4},MainCell{idxMain(i),2},MainCell{idxMain(i),3},DensityMain(i,3),size(MainCell,1)-idxMain(i),DensityMain(i,4));
    end % if i~=size(idxMain,2)
end % for i=1:size(idxMain,2)
fclose(fileID);
end % if MSFlag==1
%% Density calc for Back
if BSFlag==1
DensityBack=zeros(size(idxBack,2),4);
BackTargetID=strings(size(idxBack,2),1);
BackProbeAve=zeros(size(BackCell,1),1);

for i=1:size(BackCell,1)
    BackProbeAve(i)=(str2double(BackCell{i,7})+str2double(BackCell{i,6}))/(2*1e6);
end % for i=1:size(BackCell,1)

prefix='BSDensity.txt';
outputBSDensity=strcat(SPath,prefix);
fileID=fopen(outputBSDensity,'w');
fprintf(fileID,'BS Region\tStart\tEnd\tSize [kb]\t# of OP oligos\tDensity [Oligos/kb]\n');

for i=1:size(idxBack,2)
    BackTargetID(i)=BackCell{idxBack(i),4};
    DensityBack(i,1)=str2double(BackCell{idxBack(i),2});
    DensityBack(i,2)=str2double(BackCell{idxBack(i),3});
    DensityBack(i,3)=(DensityBack(i,2)-DensityBack(i,1))/1000;
    if i~=size(idxBack,2)
        DensityBack(i,4)=(idxBack(i+1)-idxBack(i))/DensityBack(i,3);
        figure();
        hist(BackProbeAve(idxBack(i):idxBack(i+1)-1),round(sqrt(idxBack(i+1)-idxBack(i))));
        title(['Probe histogram: ',BackTargetID(i)]);
        xlabel('Genomic Position [Mb]')
        ylabel('Frequency')
        set(gca,'FontName','Helvetica','FontSize',18)
        Prefix=[BackCell{idxBack(i),4},' Histogram.png'];
        print(gcf,[SPath,'BS',Prefix],'-r300','-dpng')
        fprintf(fileID,'%s\t%s\t%s\t%d\t%d\t%d\n',BackCell{idxMain(i),4},BackCell{idxMain(i),2},BackCell{idxMain(i),3},DensityBack(i,3),idxBack(i+1)-idxBack(i),DensityBack(i,4));
    else
        DensityBack(i,4)=(size(BackCell,1)-idxBack(i))/DensityBack(i,3);
        figure();
        hist(BackProbeAve(idxBack(i):size(BackCell,1)),round(sqrt(size(BackCell,1)-idxBack(i))));
        title(['Probe histogram: ',BackTargetID(i)]);
        xlabel('Genomic Position [Mb]')
        ylabel('Frequency')
        set(gca,'FontName','Helvetica','FontSize',18)
        Prefix=[BackCell{idxBack(i),4},' Histogram.png'];
        print(gcf,[SPath,Prefix],'-r300','-dpng')
        fprintf(fileID,'%s\t%s\t%s\t%d\t%d\t%d\n',BackCell{idxBack(i),4},BackCell{idxBack(i),2},BackCell{idxBack(i),3},DensityBack(i,3),size(BackCell,1)-idxBack(i),DensityBack(i,4));
    end % if i~=size(idxBack,2)
end % for i=1:size(idxBack,2)
fclose(fileID);
end % if BSFlag==1