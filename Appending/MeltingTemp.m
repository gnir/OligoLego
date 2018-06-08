function Tm = MeltingTemp(oligo)
%% function Tm = MeltingTemp(oligo)
% This function computes the melting temp of an oligo accotding to
% SantaLucia (1998 PNAS); Tm = delta_H/(delta_S+RlnCt)
% input: vector containing numbers 1 to 4, where 1='A', 2='C', 3='G', 4='T'
% output: Melting temp for this oligo
%% translate to numbers if needed
if ischar(oligo)
    oligo=SequenceToNumbers(oligo);
end % if ischar(oligo)
%% Table
R=1.987; % Gas constant in cal/K*mol)
Ct=1e-11; % according to primer3
wA=0; zC=0; yG=0; xT=0;
% deltaH in [kcal/mol]; deltaS in [cal/mol];
dH_AATT=-7.9; dH_ATTA=-7.2; dH_TAAT=-7.2; dH_CAGT=-8.5; dH_GTCA=-8.4; dH_CTGA=-7.8; 
dH_GACT=-8.2; dH_CGGC=-10.6; dH_GCCG=-9.8; dH_GGCC=-8; dH_ACTG=-8.4; dH_AGTC=-7.8;
dH_CCGG=-8; dH_TCAG=-8.2; dH_TGAC=-8.5; dH_TTAA=-7.9;
dS_AATT=-22.2; dS_ATTA=-20.4; dS_TAAT=-21.3; dS_CAGT=-22.7; dS_ACTG=-22.4; dS_AGTC=-21;
dS_GTCA=-22.4; dS_CTGA=-21; dS_GACT=-22.2; dS_CGGC=-27.2; dS_GCCG=-24.4; dS_GGCC=-19.9;
dS_CCGG=-19.9; dS_TCAG=-22.2; dS_TGAC=-22.7; dS_TTAA=-22.2;
%% Oligo Tm calculation
ds_total=0; dh_total=0;
for i=1:length(oligo)-1
    if (oligo(i)==1 && oligo(i+1)==1)  
        dH=dH_AATT; dS=dS_AATT;
    elseif (oligo(i)==1 && oligo(i+1)==4)
        dH=dH_ATTA; dS=dS_ATTA;
    elseif (oligo(i)==4 && oligo(i+1)==1)
        dH=dH_TAAT; dS=dS_TAAT;
    elseif (oligo(i)==2 && oligo(i+1)==1)  
        dH=dH_CAGT; dS=dS_CAGT;
    elseif (oligo(i)==3 && oligo(i+1)==4) 
        dH=dH_GTCA; dS=dS_GTCA;
    elseif (oligo(i)==2 && oligo(i+1)==4) 
        dH=dH_CTGA; dS=dS_CTGA;
    elseif (oligo(i)==3 && oligo(i+1)==1) 
        dH=dH_GACT; dS=dS_GACT;
    elseif (oligo(i)==2 && oligo(i+1)==3)
        dH=dH_CGGC; dS=dS_CGGC;
    elseif (oligo(i)==3 && oligo(i+1)==2)
        dH=dH_GCCG; dS=dS_GCCG;
    elseif (oligo(i)==3 && oligo(i+1)==3)  
        dH=dH_GGCC; dS=dS_GGCC;
    elseif (oligo(i)==1 && oligo(i+1)==2)
        dH=dH_ACTG; dS=dS_ACTG;
    elseif (oligo(i)==1 && oligo(i+1)==3)
        dH=dH_AGTC; dS=dS_AGTC;
    elseif (oligo(i)==2 && oligo(i+1)==2)
        dH=dH_CCGG; dS=dS_CCGG;
    elseif (oligo(i)==4 && oligo(i+1)==2)
        dH=dH_TCAG; dS=dS_TCAG;
    elseif (oligo(i)==4 && oligo(i+1)==3) 
        dH=dH_TGAC; dS=dS_TGAC;
    elseif (oligo(i)==4 && oligo(i+1)==4)
        dH=dH_TTAA; dS=dS_TTAA;
    end % if (oligo(i)==1 && oligo(i+1)==1) || (oligo(i)==4 && oligo(i+1)==4)
    ds_total=ds_total+dS; dh_total=dh_total+dH;
    if oligo(i)==1
        wA=wA+1;
    elseif oligo(i)==2
        zC=zC+1;
    elseif oligo(i)==3
        yG=yG+1;
    elseif oligo(i)==4
        xT=xT+1;
    end % if oligo(i)==1
end
if oligo(end)==1
    wA=wA+1; dS_total=ds_total-2.8; dH_total=dh_total+0.1; % init term
elseif oligo(end)==2
    zC=zC+1; dS_total=ds_total+4.1; dH_total=dh_total+2.3;
elseif oligo(end)==3
    yG=yG+1; dS_total=ds_total+4.1; dH_total=dh_total+2.3;
elseif oligo(end)==4
    xT=xT+1; dS_total=ds_total-2.8; dH_total=dh_total+0.1;
end % if oligo(end)==1
Na=0.05; % Na in [M]
dS_total=dS_total+0.368*(length(oligo)/2-1)*log(Na); % Salt Correction
Tm_primer3=1000*dH_total/(dS_total+R*log(Ct))-273.15; % 1000*kcal/mol/(cal/K*mol+cal/K*mol)   [c]
%% OligoCalc
OligoConc=8e-11; % primer concentration in mole
% Tm_Oligocalc_salt_Adjusted= 100.5 + (41 * (yG+zC)/(wA+xT+yG+zC)) - (820/(wA+xT+yG+zC)) + 16.6*log10(Na);
Tm_oligoCalc_NN=(1000*dh_total-3.4*1000)/(ds_total+R*log((1/.25*OligoConc)))+16.6*log10(Na)-273.15;
%% Tm
Tm=(Tm_oligoCalc_NN+Tm_primer3)/2; % Tm is an average of NN using OligoCalc and Primer3 settings.