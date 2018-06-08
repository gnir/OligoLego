function PolyX = PolydT(oligo,N)
%% This function checks for repetitive dNTPs
% inputs:
% oligo - vector containing numbers 1 to 4, where 1='A', 2='C', 3='G', 4='T'
% N - number of repetitive dNTPs to check.
% output - '1' if an N repetitive dNTP exists, '0' if not.
%%
PolyX=0;
for i=1:length(oligo)-N
    flag=0; flag2=0;
    Counter=1;
    dT=oligo(i);
    while flag==0 && flag2==0
        for j=i+1:i+N-2
            NextdT=oligo(j);
            if dT==NextdT
                Counter=Counter+1;
                if Counter==N
                    flag=1;
                end
            else
                flag2=1;
            end % if dT==NextdT
        end % for j=i+1:i+N-2
        if flag==1
            PolyX=1;
        end % if flag==1
    end % while flag==0 && flag2==0
    if PolyX==1
        break
    end % if PolyX==1
end
