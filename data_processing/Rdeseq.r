#!/bin/Rscript

args <- commandArgs(TRUE)


library("DESeq")


dir=args[1]
#dir="/media/HD1_/Documents/AG3C/Results/"
filename=args[2]

datafile=paste(dir,filename,sep="")
datafile="/media/HD1_/Documents/AG3C/Results/RNA_dseq/rna_data.csv"

countTable <- read.table(datafile,header=T,row.names=1,sep="\t")

rRNA.names=sprintf("ECB_r%05d", 1:22)
tRNA.names=sprintf("ECB_t%05d", 1:86)
#ncRNA.names=sprintf("RF%05d", 1:96)

keep=!(row.names(countTable) %in% c(rRNA.names,tRNA.names)) 
countTable = countTable[keep, ]

hour_analyzed_1 = "t3"
hour_analyzed_2 = c("t4","t5","t6","t8","t24", "t48","t168","t336")


for (hour in hour_analyzed_2)
{
	print(hour)
	print(c(hour_analyzed_1, hour,hour_analyzed_1, hour,hour_analyzed_1, hour))
	condition=factor(c(hour_analyzed_1, hour,hour_analyzed_1, hour,hour_analyzed_1, hour))
	countTable_2t <- countTable[names(countTable) %in% c("t3_1","t3_2","t3_3", paste(hour,"_1",sep=""),
	paste(hour,"_2",sep=""),
	paste(hour,"_3",sep=""))]
	print(head(countTable_2t))

	cds=newCountDataSet(countTable_2t,condition)
	cds=estimateSizeFactors(cds)

	sF=sizeFactors(cds)
	counts(cds,normalized=TRUE)

	cds=estimateDispersions(cds)
	res=nbinomTest( cds, hour_analyzed_1, hour)


	nonsig=res[!is.na(res$pval) & res$pval>=0.05,]
	sig=res[!is.na(res$pval) & res$pval<0.05,]

	write.csv(sig, paste(dir,args[2],"_sig_gene_",hour_analyzed_1,"_",hour,sep=""))
	write.csv(sF,paste(dir,args[2],"_size_factors",hour_analyzed_1,"_",hour,sep=""))

}

