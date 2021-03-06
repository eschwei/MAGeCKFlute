% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FluteRRA.R
\docType{methods}
\name{FluteRRA}
\alias{FluteRRA}
\alias{RRApipeline}
\title{Downstream analysis based on MAGeCK-RRA result}
\usage{
FluteRRA(gene_summary, prefix = "Test", enrich_kegg = "HGT",
  organism = "hsa", pathway_limit = c(3, 50), pvalueCutoff = 0.25,
  adjust = "BH", outdir = ".")
}
\arguments{
\item{gene_summary}{A file path or a data frame, which has three columns named 'id', 'neg.fdr' and 'pos.fdr'.}

\item{prefix}{A character, indicating the prefix of output file name.}

\item{enrich_kegg}{One of "HGT"(HyperGemetric test), "ORT"(Over-Representing Test), "DAVID" and "GOstats",
specifying enrichment method used for kegg enrichment analysis.}

\item{organism}{A character, specifying organism, such as "hsa" or "Human"(default),
and "mmu" or "Mouse"}

\item{pathway_limit}{A two-length vector (default: c(3, 50)), specifying the min and
max size of pathways for enrichent analysis.}

\item{pvalueCutoff}{A numeric, specifying pvalue cutoff of enrichment analysis, default 1.}

\item{adjust}{One of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none".}

\item{outdir}{Output directory on disk}
}
\value{
All of the pipeline results is output into the \code{out.dir}/\code{prefix}_Results,
which includes a pdf file and a folder named 'RRA'.
}
\description{
Integrative analysis pipeline using the gene summary table in MAGeCK RRA results
}
\details{
MAGeCK RRA allows for the comparison between two experimental conditions. It can identify
genes and sgRNAs are significantly selected between the two conditions. The most important output
of MAGeCK RRA is the file `gene_summary.txt`. MAGeCK RRA will output both the negative score and
positive score for each gene. A smaller score indicates higher gene importance. MAGeCK RRA  will
also output the statistical value for the scores of each gene. Genes that are significantly positively
and negatively selected can be identified based on the p-value or FDR.

The downstream analysis of this function includes identifying positive and negative selection genes,
and performing biological functional category analysis and pathway enrichment analysis of these genes.
}
\examples{
data(RRA_Data)
gene_summary = RRA_Data
\dontrun{
    # Run the FluteRRA pipeline
    FluteRRA(gene_summary, prefix="BRAF", organism="hsa")
}


}
\seealso{
\code{\link{FluteMLE}}
}
\author{
Wubing Zhang
}
