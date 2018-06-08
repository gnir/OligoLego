function Dock = AppendDocking(varargin)
%% Documentation
% This function generates streets with docking sequences. Docking sequences
% are 10 nt, streets are 20 nt if GenerateToeholds==0 and 27nt if
% GenerateToeholds==1.
switch nargin
    case 0
        Docking=LoadDocking;
        for i=1:length(Docking)
            flag=0;
            while flag == 0
                r=randi([1 4],1,10);
                if i==1
                    temp(1:5)=r(1:5); temp(6:15)=Docking(i,:); temp(16:20)=r(6:10);
                elseif i~=8 && i~=2 && i~=6 && i~=14
                    temp=cat(2,r,Docking(i,:)); % '5-random-docking-3'
                else
                    temp=cat(2,Docking(i,:),r); % '5-docking-random-3'
                end % if i==1
                if FilterStreets(temp)==1 % filter streets
                    flag=FilterStreets(ReverseComplement(temp));
                end
            end % while flag == 0
            Dock(i,:)=temp;
        end % for i=1:length(Docking)
    case 1 % GenerateToeholds==1
        if strcmp(varargin{1,1},'GT')
            % Struct='.......((((((((((((((((((((+))))))))))))))))))))'; % 27 nt toehold, containing 7nt overhang at its 5'
            Docking=ReverseComplement(LoadDocking);
            for i=1:size(Docking,1)
                flag=0;
                while flag == 0
                    temp=cat(2,randi([2 3],1,1),randi([1 4],1,15),Docking(i,:),randi([2 3],1,1));
                    if FilterStreets(temp(8:end))==1 % filter streets
                        flag=FilterStreets(ReverseComplement(temp(8:end)));
                    end
                end % while flag == 0
                Seq(i,:)=Numbers2Sequnces(temp);
                %fileID=fopen(FullPath,'w');
                %fprintf(fileID,'%s\n%s\n',Struct,Seq(i,:));
                %fclose(fileID);
                Dock(i,:)=DesignToehold(FullPath,Seq(i,:));
            end % for i=1:size Docking,1)
        end %  if strcmp(varargin{1,1},'GenerateToeholds')
end % switch nargin
