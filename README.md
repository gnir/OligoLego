# OligoLego
A tool for Oligopaints library design

Appending tool documentation

If you are using the appending tool, please cite it: [Guy Nir et al. 2018]	

Documentation last edited: 01/23/18

Goal: 

Design Oligopaints library, by adding MainStreets and Backstreets to genome homology region. 
Genome homology region oligos can be downloaded here: http://genetics.med.harvard.edu/oligopaints/and scripts for mining genome homology region oligos, for those who want to do it themselves, can be found here: https://github.com/brianbeliveau/OligoMiner If you use these tools or oligos, please cite: [Brian J. Beliveau et al. OligoMiner: A rapid, flexible environment for the design of genome-scale oligonucleotide in situ hybridization probes, PNAS, 2018].

Oligopaints dictionary:

Oligopaints - Oligopaint probes consist of computationally designed single-stranded oligos that can target their genomic complements while avoiding repeated sequences (Brian J. Beliveau et al. PNAS 2012; Nat. Comms. 2015).
They carry a region of genomic homology that is generally ~32-42 bases long, and carry nongenomic sequences at their 5' and/or 3' ends. These regions, called Mainstreet and Backstreet, respectively, augment the cost-effectiveness of Oligopaints by enabling the libraries to be renewed through amplification or multiplexed through sublibrary-specific primer and barcodes sequences.
Universal - a 20 nt universal PCR primer sequence at both ends of each Oligopaint oligo, which acts as a simple tool to amplify an entire Oligopaints library at once.

Requirements:
You would need MATLAB (MathWorks), or to run the Appending tool through a cluster that has MATLAB.

Appending tool principles:
1.	This tool uses streets (MainStreets, and BackStreets) that were designed using the MakingStreets tool, available here: [URL]. These streets were computationally designed to serve as good PCR primers, as well as FISH oligos. Each street is 20 nt, and has a complement toehold, which is 27 nt long. The toehold is designed to replace an existing street, and block an Oligopaint oligo from being detected (Nir et al. 2018). One can either download a pool of streets, blasted (using bowtie2) against a number of organisms, here: http://genetics.med.harvard.edu/oligopaints/. Or, use the MakingStreets tool, and design a new set of oligos.
2.	When appending streets, the appending tool will only pair MainStreets with BackStreets that are predicted to be efficient PCR primers, thus allowing not only universal amplification, but also, locus-specific amplification. For doing so, it users a penalty table produced by the MakingStreets tool.
3.	The appending tool works chromosome-wise, i.e., you should run it separately for each chromosome. 

Supporting designs: 
The appending tool currently supports the following 3 designs:
1.	AppMS (Fig. 1A) - appends locus-specific MainStreets, and pairs the MainStreets with a single, universal BackStreet. The advantage of this design is that it allows a shorter Oligopaint probe, compared to other designs the tool offers. The disadvantage is that you loose the option for further barcoding using BackStreets, and it doesn╒t currently support toeholds. 
2.	AppMSBS (Fig. 1B) - appends both locus-specific MainStreets and BackStreets, and a universal primer pair.
3.	AppToMSBS (Fig. 1C) - appends the reverse complements of the toeholds for both MainStreets and BackStreets, and thus allows sequential hybridization imaging. Also appends a universal primer pair.
General note - for historical reasons, the appending tool appends the reverse complements of streets in the oligo pool that is provided to the appending tool. However, the 5’ end universal street will be the same as the one in the pool.

 ![alt text](https://github.com/gnir/OligoLego/blob/master/AllDesigns.png)
Figure 1. Supported Oligopaints designs. (A) Locus-specific for MainStreet only. (B). Locus-specific for MainStreet and BackStreet. (C). Locus-specific for MainStreet and BackStreet, including toeholds.

Inputs:

1.	Intersected text file, one for the MainStreet, and another for the BackStreet, if designs two or three are desired. You can also use the same file twice for signal amplification. Thus, you can represent different barcodes for the same locus, one on the MainStreet, and a second on the BackStreet, and double the signal-to-noise ratio. To make this file, you would want to do the following: 
a.	Download (or mine yourself) Oligopaints genome homology region oligos from http://genetics.med.harvard.edu/oligopaints/that are of interest to you. You can download a whole chromosome, and use the instructions in this document to extract your loci of interest. Make sure to sort this file by coordinates. Mac users can use Terminal in the following way: sort -k 1,1 -k2,2n FilePath -o OutputPath
b.	Make a bed file (I recommend working with TextWrangler, and saving as .bed), which has 4 tab-separated columns. In each row, column #1 represents the chromosome, i.e. chr1. Column #2 and Column #3 are the start and end coordinates of your locus of interest. Make sure that you use the same build you used when you downloaded the genome homology region. For instance, if you downloaded sequences from hg19, then stick with hg19. Column #4 is an ID (name) specified by you. Each locus should have it╒s own ID, and if you put the same ID twice, in more than one row, then you get the same barcode sequence for all of these rows. The latter could be beneficial when adding flanks to a locus, and using the two flanks with the same barcode. When composing this file, make sure it╒s sorted by start coordinate, or sort when you are done editing. See sort example in 1.a. 
c.	Run bedtools intersect from Terminal as follows (for Mac users): bedtools intersect -wa -wb -a YourFile -b Genome homology region file -sorted >output.txt
2.	Streets pool, from Oligopaints website, see Appending tool principles, section 1.
3.	For design #3, which includes toeholds, you would need the toeholds pool, from Oligopaints website, see Appending tool principles, section 1.
4.	Penalty table matrix from Oligopaints website, see Appending tool principles, section 1. 
5.	Path to save folder. A path to where you would like to save the output files from the Appending tool.
Optional inputs:
1.	Max Avoid - a flag for avoiding streets that have already been used in other libraries that are to be image simultaneously. For instance, you would like to image chromosome 1 and chromosome 3. You decide to start with chromosome 1, and you have noticed in the ‘Universal.txt’ output file that the 3╒ universal has the number ‘30’. Now you run the appending tool for chromosome 3, and add the ‘MaxAvoid’ flag, followed by ‘30’. 
2.	Same Universal - a flag for using the same universal primers. One instance when this helpful is when designing Oligopaints from multiple chromosomes, and thus having to run the appending tool multiple times. One may still like to amplify the entire library, which again, consists of multiple chromosomes with a single PCR reaction. Therefore, after running the Appending tool once, you can use the ‘SameUniversal’ flag followed by the path to the Universal.txt ╘Universal.txt╒ file that was created by the Appending tool when you ran it previously.

How to use:

From MATLAB command line:
1.	Call design #1 (AppMS): ApOPs('MS','MainStreetsIntersectedFile’,'Streets',StreetsFilePath','PTable','PenaltyTablePath','SavePath','YourSavePath','MaxAvoid','68','SameUniversal','UniversalFilePath');
Note - ‘MaxAvoid’ and ‘SameUniversal’ are not required.
2.	Call design #2 (AppMSBS): ApOPs('MS','MainStreetsIntersectedFile╒, 'BS','BackStreetsIntersectedFile’,'Streets',╒StreetsFilePath','PTable','PenaltyTablePath','SavePath','YourSavePath','MaxAvoid','200','SameUniversal','UniversalFilePath'); 
Note - ‘MaxAvoid’ and ‘SameUniversal’ are not required.
3.	Call design #3 (AppToMSBS): ApOPs('MS','MainStreetsIntersectedFile’, 'BS','BackStreetsIntersectedFile’,’Toes’,’ToesFilePath','Streets',’StreetsFilePath','PTable','PenaltyTablePath','SavePath','YourSavePath','MaxAvoid','170','SameUniversal','UniversalFilePath'); 
Note – ‘MaxAvoid’ and ‘SameUniversal’ are not required.

From terminal (example for calling design #1):
matlab -nodesktop -nosplash -r "ApOPs('MS','MainStreetsIntersectedFile','Streets',‘StreetsFilePath','PTable','PenaltyTablePath','SavePath','YourSavePath','MaxAvoid','100'); exit"
Note – ‘MaxAvoid’ is not required.

Output:

1. Oligopaints.txt - a text file with your entire Oligopaints library. Each row is one Oligopaint oligo.
2. MS_IDs.txt - a text file with as many rows as the number of loci you specified on the intersected file for your MainStreet, and in each row, 6 columns describing the MainStreet oligos that one may want to purchase for PCR primers, toeholds and bridges or secondaries, i.e. barcodes that bind a specific locus. Column #1 - MSRegionID. The name you gave a locus when prepared an intersected file. For instance, 'DNMT1'. Column #2 - ID. The appending tool assigns a numeric ID to each locus. Column #3 - Toe or StreetNum (depending in the design you set). Column #4 - Toe or StreetSequence. The toehold or street sequence that is the reverse complement to the locus-specific sequence appended to your Oligopaint oligo. Column #5 - BridgeSequence. For designs #1 and #2, this is identical to column #4. For design #3, which includes toeholds, this is the bridge/secondary to use. Column #6 - ForwardPrimerSeq. This is the forward primer to order.
3. BS_IDs.txt - The same as MS_IDs.txt, but for BackStreets. Only relevant for designs 2&3. The 6th column is the reverse primer to order.
4. MSDensity.txt - a text file with as many rows as the number of loci you specified on the intersected file for your MainStreet, and in each row, 6 columns describing the locus as well as the density of Oligopaints oligos within it. Column #1 - MS_Region. The name you gave a locus when prepared an intersected file. For instance, 'DNMT1'. Column #2 - Start coordinate of the locus. Column #3 - End coordinate. Column #4 - Size (kb) of the locus. Column #5 - Number of Oligopaints Oligos assigned to that locus. Column #6 - Probes density (probes/kb).
5. BSDensity.txt -  The same as MSDensity.txt, but for BackStreets. Only relevant for designs 2&3.
6. Universal.txt - A text file with 1 row, containing the forward and reverse universal primers to order, as well as their number (row number) in the oligopool. 



