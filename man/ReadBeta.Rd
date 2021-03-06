% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ReadBeta.R
\docType{methods}
\name{ReadBeta}
\alias{ReadBeta}
\alias{readbeta}
\title{Read gene beta scores}
\usage{
ReadBeta(gene_summary, keytype = "Symbol", organism = "hsa")
}
\arguments{
\item{gene_summary}{A file path or a data frame, data frame, which has columns of 'Gene' and '*|beta'.}

\item{keytype}{Type of gene id in `gene_summary`, which should be one of "Entrez" or "Symbol".}

\item{organism}{Character, KEGG species code, or the common species name, used to determine
the gene annotation package. For all potential values check: data(bods); bods. Default org="hsa",
and can also be "human" (case insensitive).}
}
\value{
A data frame, in which the first column is ENTREZID, and the later columns are beta score for each samples.
}
\description{
Read gene beta scores from file or data frame
}
\examples{
data(MLE_Data)
dd = ReadBeta(MLE_Data, organism="hsa")
head(dd)

}
\author{
Wubing Zhang
}
