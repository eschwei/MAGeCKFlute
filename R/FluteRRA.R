#' Downstream analysis based on MAGeCK-RRA result
#'
#' Integrative analysis pipeline using the gene summary table in MAGeCK RRA results
#'
#' @docType methods
#' @name FluteRRA
#' @rdname FluteRRA
#' @aliases RRApipeline
#'
#' @param gene_summary A file path or a data frame, which has three columns named 'id', 'neg.fdr' and 'pos.fdr'.
#' @param prefix A character, indicating the prefix of output file name.
#' @param enrich_kegg One of "HGT"(HyperGemetric test), "ORT"(Over-Representing Test), "DAVID" and "GOstats",
#' specifying enrichment method used for kegg enrichment analysis.
#' @param organism A character, specifying organism, such as "hsa" or "Human"(default),
#' and "mmu" or "Mouse"
#' @param pathway_limit A two-length vector (default: c(3, 50)), specifying the min and
#' max size of pathways for enrichent analysis.
#' @param pvalueCutoff A numeric, specifying pvalue cutoff of enrichment analysis, default 1.
#' @param adjust One of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none".
#' @param outdir Output directory on disk
#'
#' @author Wubing Zhang
#'
#' @return  All of the pipeline results is output into the \code{out.dir}/\code{prefix}_Results,
#' which includes a pdf file and a folder named 'RRA'.
#'
#' @details MAGeCK RRA allows for the comparison between two experimental conditions. It can identify
#' genes and sgRNAs are significantly selected between the two conditions. The most important output
#' of MAGeCK RRA is the file `gene_summary.txt`. MAGeCK RRA will output both the negative score and
#' positive score for each gene. A smaller score indicates higher gene importance. MAGeCK RRA  will
#' also output the statistical value for the scores of each gene. Genes that are significantly positively
#' and negatively selected can be identified based on the p-value or FDR.
#'
#' The downstream analysis of this function includes identifying positive and negative selection genes,
#' and performing biological functional category analysis and pathway enrichment analysis of these genes.
#'
#' @seealso \code{\link{FluteMLE}}
#'
#' @examples
#' data(RRA_Data)
#' gene_summary = RRA_Data
#' \dontrun{
#'     # Run the FluteRRA pipeline
#'     FluteRRA(gene_summary, prefix="BRAF", organism="hsa")
#' }
#'
#'
#' @export

#===read RRA results=====================================
FluteRRA <- function(gene_summary, prefix="Test", enrich_kegg="HGT",
                     organism="hsa", pathway_limit = c(3, 50),
                     pvalueCutoff=0.25, adjust="BH", outdir="."){
  #=========Prepare the running environment=========
  {
    message(Sys.time(), " # Create output dir and pdf file ...")

    out.dir_sub=file.path(outdir, paste0(prefix, "_Flute_Results"))
    dir.create(file.path(out.dir_sub), showWarnings=FALSE)
    dir.create(file.path(out.dir_sub,"RRA"), showWarnings=FALSE)

    output_pdf = paste0(prefix,"_Flute.rra_summary.pdf")
    pdf(file.path(out.dir_sub, output_pdf),width=11, height = 6)
  }

  #=========Input data=========
  message(Sys.time(), " # Read RRA result ...")
  dd = ReadRRA(gene_summary, organism=organism)

  #enrichment analysis
  {
    universe=dd$ENTREZID
    idx=dd$neg.fdr<pvalueCutoff
    genes = dd[idx, "ENTREZID"]
    geneList= -log10(dd[idx, "neg.fdr"])
    names(geneList) = genes

    kegg.neg=enrichment_analysis(geneList=geneList, universe=universe,
                                 method = enrich_kegg,type = "KEGG",
                                 organism=organism,pvalueCutoff=pvalueCutoff,
                                 plotTitle="KEGG: neg",color="#3f90f7",
                                 pAdjustMethod = adjust, limit = pathway_limit)
    bp.neg=enrichment_analysis(geneList=geneList, universe=universe, method = "ORT",
                               type = "BP", organism=organism,
                               pvalueCutoff = pvalueCutoff, plotTitle="BP: neg",
                               color="#3f90f7", pAdjustMethod = adjust, limit = pathway_limit)

    ggsave(kegg.neg$gridPlot, filename = file.path(out.dir_sub,"RRA/kegg.neg.png"),
           units = "in", width = 6.5, height = 4)
    ggsave(bp.neg$gridPlot,filename=file.path(out.dir_sub,"RRA/bp.neg.png"),
           units = "in", width = 6.5, height = 4)

    idx=dd$pos.fdr<pvalueCutoff
    genes = dd[idx, "ENTREZID"]
    geneList = -log10(dd[idx, "pos.fdr"])
    names(geneList) = genes

    kegg.pos=enrichment_analysis(geneList=geneList, universe=universe,
                                 method = enrich_kegg, type = "KEGG",
                                 organism=organism, pvalueCutoff=pvalueCutoff,
                                 plotTitle="KEGG: pos",color="#e41a1c",
                                 pAdjustMethod = adjust, limit = pathway_limit)
    bp.pos=enrichment_analysis(geneList=geneList, universe=universe, method = "ORT",
                               type = "BP", organism=organism,
                               pvalueCutoff = pvalueCutoff, plotTitle="BP: pos",
                               color="#e41a1c", pAdjustMethod = adjust, limit = pathway_limit)
    ggsave(kegg.pos$gridPlot,filename=file.path(out.dir_sub,"RRA/kegg.pos.png"),
           units = "in", width = 6.5, height = 4)
    ggsave(bp.pos$gridPlot,filename=file.path(out.dir_sub,"RRA/bp.pos.png"),
           units = "in", width = 6.5, height = 4)

    grid.arrange(kegg.neg$gridPlot, bp.neg$gridPlot, kegg.pos$gridPlot, bp.pos$gridPlot, ncol = 2)
  }
  dev.off()
}
