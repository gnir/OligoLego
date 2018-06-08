function [BIsectOutput,sISect,ISectOut] = BedtoolsIntersect(SortProbesinput,SortProbesoutput,SortROIinput,SortROIoutput)
%% Documentation
% This function uses unix's sort command and then bedtools intersect to
% intersect 2 bedfiles.
% Input: SortProbesinput/output- Probes file path. SortROIinput/output - ROI file path.
% Output: sISect - command status. ISectOut - Terminal printout.
% BIsectOutput - is the path of the intersected saved bed file.
% You need to have bedtools defined in matlab's startup.
%% Sort and Intersect
sortsyntax='sort -k 1,1 -k2,2n'; sortoutputflag='-o';
SortProbesCommand=sprintf('%s %s %s %s',sortsyntax,SortProbesinput,sortoutputflag,SortProbesoutput);
[ssortProbes,sortoutProbes] = unix(SortProbesCommand);
SortROICommand=sprintf('%s %s %s %s',sortsyntax,SortROIinput,sortoutputflag,SortROIoutput);
[ssortROI,sortoutROI] = unix(SortROICommand);
BIsect='bedtools intersect -wa -wb -a';
BIsectInput=SortROIoutput;
BIsect_b='-b';
BIsect_ProbeFile=SortProbesoutput;
BIsect_Sorted='-sorted >';
BIsectOutput=strcat(BIsectInput(1:end-11),'_Intersected.bed');
BIsectCommand=sprintf('%s %s %s %s %s %s',BIsect,BIsectInput,BIsect_b,BIsect_ProbeFile,BIsect_Sorted,BIsectOutput);
[sISect,ISectOut] = unix(BIsectCommand);