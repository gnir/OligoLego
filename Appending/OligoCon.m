function OligoGram = OligoCon(FileName,pmol)
% Input - pmol: quantity of Opool in picomoles. FileName - path to
% Oligopaints.txt file genertaed with OligoLego
% mass of ssDNA (g) = moles of ssDNA (mol) x ((length of ssDNA (nt) x 308.97 g/mol/bp) + 18.02 g/mol)
% https://nebiocalculator.neb.com/#!/ssdnaamt
% Exact M.W. of ssDNA (e.g., Oligonucleotides):
% M.W. = (An x 313.2) + (Tn x 304.2) + (Cn x 289.2) + (Gn x 329.2) + 79.0ª
% An, Tn, Cn, and Gn are the number of each respective nucleotide within the polynucleotide.
% ªAddition of "79.0" to the M.W. takes into account the 5' monophosphate left by most restriction enzymes. No phosphate is present at the 5' end of strands made by primer extension.

Oligos=readtextfile(FileName);
OligoNum=SequenceToNumbers(Oligos);
numA=numel(find(OligoNum(OligoNum==1)));
numC=numel(find(OligoNum(OligoNum==2)));
numG=numel(find(OligoNum(OligoNum==3)));
numT=numel(find(OligoNum(OligoNum==4)));

OligoGram=pmol*1e-6*(numA*313.2+numC*289.2+numG*329.2+numT*304.2); % [ug]
disp(['Quantity of library in ug ', num2str(OligoGram)]);