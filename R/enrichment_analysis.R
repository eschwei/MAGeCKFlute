#' Enrichment analysis
#'
#' Enrichment analysis
#'
#' @docType methods
#' @name enrichment_analysis
#' @rdname enrichment_analysis
#' @aliases enrichment
#'
#' @param geneList a character vector or a ranked numeric vector(for GSEA) with names of geneid,
#' specifying the genelist to do enrichment analysis.
#' @param universe a character vector, specifying the backgound genelist, default is whole genome.
#' @param method One of "ORT"(Over-Representing Test), "GSEA"(Gene Set Enrichment Analysis), "DAVID",
#' "GOstats", and "HGT"(HyperGemetric test), or index from 1 to 5
#' @param type geneset category for testing, KEGG(default).
#' @param organism a character, specifying organism, such as "hsa" or "Human"(default), and "mmu" or "Mouse"
#' @param pvalueCutoff pvalue cutoff.
#' @param qvalueCutoff qvalue cutoff.
#' @param pAdjustMethod one of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none".
#' @param minGSSize minimal size of each geneSet for testing.
#' @param maxGSSize maximal size of each geneSet for analyzing.
#' @param plotTitle same as 'title' in 'plot'.
#' @param gridColour color of grids.
#'
#' @return a list, including two items, \code{gridPlot} and \code{enrichRes}. \code{gridPlot} is
#' a ggplot object, and \code{enrichRes} is a enrichResult instance.
#'
#' @author Feizhen Wu
#'
#' @note  See the vignette for an example of enrichment analysis
#' The source can be found by typing \code{MAGeCKFlute:::enrichment_analysis}
#' or \code{getMethod("enrichment_analysis")}, or
#' browsed on github at \url{https://github.com/WubingZhang/MAGeCKFlute/tree/master/R/enrichment_analysis.R}
#' Users should find it easy to customize this function.
#'
#' @seealso \code{\link{enrich.GOstats}}
#' @seealso \code{\link{enrich.DAVID}}
#' @seealso \code{\link{enrich.GSE}}
#' @seealso \code{\link{enrich.ORT}}
#' @seealso \code{\link{enrich.HGT}}
#' @seealso \code{\link[DOSE]{enrichResult-class}}
#'
#' @examples
#' data(MLE_Data)
#' universe = id2eg(MLE_Data$Gene, "SYMBOL")[,"ENTREZID"]
#' genes = id2eg(Core_Essential[1:200], "SYMBOL")[,"ENTREZID"]
#' keggA = enrichment_analysis(geneList = genes, universe=universe,
#'                          method = "HGT",type = "KEGG",
#'                          organism = "hsa", gridColour="#e41a1c")
#' print(keggA$gridPlot)
#'
#'
#' @export

#====enrichment analysis===================================
enrichment_analysis = function(geneList, universe=NULL, method=1, type="KEGG", organism="hsa",
                               pvalueCutoff = 0.05, qvalueCutoff = 1, pAdjustMethod = "BH",
                               minGSSize = 2, maxGSSize = 500, plotTitle=NULL,gridColour="blue"){
  requireNamespace("stats", quietly=TRUE) || stop("need stats package")
  result=list()
  type=toupper(type[1])
  methods = c("ORT", "GSEA", "DAVID", "GOstats", "HGT")
  names(methods) = toupper(methods)
  if(class(method)=="character"){method = toupper(method)}
  method = methods[method]
  #======================================================================================
  p1=ggplot()
  p1=p1+geom_text(aes(x=0,y=0,label="Less than 10 genes"),size=6)
  p1=p1+labs(title=plotTitle)
  p1=p1+theme(plot.title = element_text(size=10))
  p1=p1+theme_void()
  p1=p1+theme(plot.title = element_text(hjust = 0.5))
  if(length(geneList)<10){
    result$enrichRes = NULL
    result$gridPlot = p1
    return(result)
  }
  #====Gene Set Enrichment Analysis=======================================================
  if(method == "GSEA"){
    geneList=geneList[order(geneList,decreasing = TRUE)]
    enrichRes <- enrich.GSE(geneList, type = type, pvalueCutoff=pvalueCutoff, pAdjustMethod = pAdjustMethod,
                            organism=organism, minGSSize = minGSSize, maxGSSize = maxGSSize)
    result$enrichRes = enrichRes
    gridPlot <- EnrichedGSEView(enrichRes@result, plotTitle, gridColour=gridColour)
    result$gridPlot = gridPlot
    return(result)
  }
  #====Over-Representation Analysis======================================================
  if(method == "ORT"){
    enrichRes <- enrich.ORT(gene = geneList, universe = universe, type = type, organism=organism,
                            pvalueCutoff=pvalueCutoff, qvalueCutoff = qvalueCutoff, pAdjustMethod = pAdjustMethod,
                            minGSSize = minGSSize, maxGSSize = maxGSSize)
  }
  #=============DAVID=======================================================================
  if(method == "DAVID"){
    if(type == "KEGG"){
      annotation = "KEGG_PATHWAY"
    }else if(type %in% c("BP", "CC", "MF")){
      annotation = paste("GOTERM", type, "FAT", sep="_")
    }else if(type == "DO"){
      annotation = "OMIM_DISEASE"
    }else{annotation = type}

    enrichRes = enrich.DAVID(gene = geneList, universe = universe,
                             minGSSize = minGSSize, maxGSSize = maxGSSize, annotation  = annotation,
                             pvalueCutoff  = pvalueCutoff, pAdjustMethod = pAdjustMethod, qvalueCutoff= qvalueCutoff)
  }
  #===============================GOstats enrichment analysis============================
  if(method == "GOstats"){
    enrichRes = enrich.GOstats(gene = geneList, universe = universe, type  = type, organism=organism,
                             pvalueCutoff  = pvalueCutoff, pAdjustMethod = pAdjustMethod)
  }
  #==================================HyperGeometric test=================================
  if(method == "HGT"){
    enrichRes = enrich.HGT(gene = geneList, universe = universe, type  = type, organism=organism,
                             pvalueCutoff  = pvalueCutoff, pAdjustMethod = pAdjustMethod,
                           minGSSize = minGSSize, maxGSSize = maxGSSize)
  }
  result$enrichRes = enrichRes
  gridPlot <- EnrichedView(enrichRes@result, plotTitle, gridColour=gridColour)
  result$gridPlot = gridPlot

  return(result)
}


