#' draw an oncoplot
#' @description takes output generated by read.maf and draws an oncoplot
#'
#' @details
#' Takes maf file as input and plots it as a matrix. Any desired clincal features can be added at the bottom of the oncoplot by providing \code{clinicalFeatures}.
#' Oncoplot can be sorted either by mutations or by clinicalFeatures using arguments \code{sortByMutation} and \code{sortByAnnotation} respectively.
#'
#'
#' @param maf an \code{\link{MAF}} object generated by \code{\link{read.maf}}
#' @param top how many top genes to be drawn. defaults to 20.
#' @param genes Just draw oncoplot for these genes. Default NULL.
#' @param mutsig Mutsig resuts if availbale. Usually file named sig_genes.txt If provided plots significant genes and correpsonding Q-values as side row-bar. Default NULL.
#' @param exprsTbl Expression values if availble. Must be a data.frame with two columns containing to gene names and expression values.
#' @param mutsigQval Q-value to choose significant genes from mutsig results. Default 0.1
#' @param drawRowBar logical plots barplot for each gene. Default \code{TRUE}.
#' @param drawColBar logical plots barplot for each sample. Default \code{TRUE}.
#' @param draw_titv logical Includes TiTv plot. \code{FALSE}
#' @param logColBar Plot top bar plot on log10 scale. Default \code{FALSE}.
#' @param includeColBarCN Whether to include CN in column bar plot. Default TRUE
#' @param showTumorSampleBarcodes logical to include sample names.
#' @param barcode_mar Default 4
#' @param gene_mar Default 5
#' @param clinicalFeatures columns names from `clinical.data` slot of \code{MAF} to be drawn in the plot. Dafault NULL.
#' @param additionalFeature a vector of length two indicating column name in the MAF and the factor level to be highlighted.
#' @param additionalFeaturePch Default 20
#' @param additionalFeatureCol Default "white"
#' @param additionalFeatureCex Default 0.9
#' @param annotationDat If MAF file was read without clinical data, provide a custom \code{data.frame} with a column \code{Tumor_Sample_Barcode} containing sample names along with rest of columns with annotations.
#' You can specify which columns to be drawn using `clinicalFeatures` argument.
#' @param genesToIgnore do not show these genes in Oncoplot. Default NULL.
#' @param annotationColor  Custom colors to use for `clinicalFeatures`. Must be a named list containing a named vector of colors. Default NULL. See example for more info.
#' @param removeNonMutated Logical. If \code{TRUE} removes samples with no mutations in the oncoplot for better visualization. Default \code{TRUE}.
#' @param fill Logical. If \code{TRUE} draws genes and samples as blank grids even when they are not altered.
#' @param cohortSize Number of sequenced samples in the cohort. Default all samples from Cohort. You can manually specify the cohort size. Default \code{NULL}
#' @param colors named vector of colors for each Variant_Classification.
#' @param bgCol Background grid color for wild-type (not-mutated) samples. Default gray - "#CCCCCC"
#' @param borderCol border grid color (not-mutated) samples. Default 'white'.
#' @param sortByMutation Force sort matrix according mutations. Helpful in case of MAF was read along with copy number data. Default FALSE.
#' @param sortByAnnotation logical sort oncomatrix (samples) by provided `clinicalFeatures`. Sorts based on first `clinicalFeatures`.  Defaults to FALSE. column-sort
#' @param numericAnnoCol color palette used for numeric annotations. Default 'YlOrBr' from RColorBrewer
#' @param groupAnnotationBySize Further group `sortByAnnotation` orders by their size.  Defaults to TRUE. Largest groups comes first.
#' @param annotationOrder Manually specify order for annotations. Works only for first `clinicalFeatures`. Default NULL.
#' @param keepGeneOrder logical whether to keep order of given genes. Default FALSE, order according to mutation frequency
#' @param GeneOrderSort logical this is applicable when `keepGeneOrder` is TRUE. Default TRUE
#' @param sampleOrder Manually speify sample names for oncolplot ordering. Default NULL.
#' @param fontSize font size for gene names. Default 0.8.
#' @param sepwd_genes Default 0.5
#' @param sepwd_samples Default 0.25
#' @param SampleNamefontSize font size for sample names. Default 1
#' @param titleFontSize font size for title. Default 1.5
#' @param legendFontSize font size for legend. Default 1.2
#' @param annotationFontSize font size for annotations. Default 1.2
#' @param writeMatrix writes character coded matrix used to generate the plot to an output file.
#' @param colbar_pathway Draw top column bar with respect to diplayed pathway. Default FALSE.
#' @param showTitle Default TRUE
#' @return None.
#' @examples
#' laml.maf <- system.file("extdata", "tcga_laml.maf.gz", package = "maftools")
#' laml.clin = system.file('extdata', 'tcga_laml_annot.tsv', package = 'maftools')
#' laml <- read.maf(maf = laml.maf, clinicalData = laml.clin)
#' #Basic onocplot
#' oncoplot(maf = laml, top = 3)
#' #Changing colors for variant classifications (You can use any colors, here in this example we will use a color palette from RColorBrewer)
#' col = RColorBrewer::brewer.pal(n = 8, name = 'Paired')
#' names(col) = c('Frame_Shift_Del','Missense_Mutation', 'Nonsense_Mutation', 'Multi_Hit', 'Frame_Shift_Ins',
#'                'In_Frame_Ins', 'Splice_Site', 'In_Frame_Del')
#' #Color coding for FAB classification; try getAnnotations(x = laml) to see available annotations.
#' fabcolors = RColorBrewer::brewer.pal(n = 8,name = 'Spectral')
#' names(fabcolors) = c("M0", "M1", "M2", "M3", "M4", "M5", "M6", "M7")
#' fabcolors = list(FAB_classification = fabcolors)
#' oncoplot(maf = laml, colors = col, clinicalFeatures = 'FAB_classification', sortByAnnotation = TRUE, annotationColor = fabcolors)
#' @seealso \code{\link{oncostrip}}
#' @export
oncoplot = function(maf, top = 20, genes = NULL, mutsig = NULL, mutsigQval = 0.1, drawRowBar = TRUE, drawColBar = TRUE, includeColBarCN = TRUE, draw_titv = FALSE, logColBar = FALSE,
                     clinicalFeatures = NULL, exprsTbl = NULL, additionalFeature = NULL, additionalFeaturePch = 20, additionalFeatureCol = "white", additionalFeatureCex = 0.9, annotationDat = NULL, annotationColor = NULL, genesToIgnore = NULL,
                     showTumorSampleBarcodes = FALSE, barcode_mar = 4, gene_mar = 5, removeNonMutated = TRUE, fill = TRUE, cohortSize = NULL, colors = NULL,
                     sortByMutation = FALSE, sortByAnnotation = FALSE, numericAnnoCol = NULL, groupAnnotationBySize = TRUE, annotationOrder = NULL, keepGeneOrder = FALSE,
                     GeneOrderSort = TRUE, sampleOrder = NULL, writeMatrix = FALSE, sepwd_genes = 0.5, sepwd_samples = 0.25, fontSize = 0.8, SampleNamefontSize = 1,
                     showTitle = TRUE, titleFontSize = 1.5, legendFontSize = 1.2, annotationFontSize = 1.2, bgCol = "whitesmoke", borderCol = 'white', colbar_pathway = FALSE){

  if(!is.null(genes)){ #If user provides a gene list
    om = createOncoMatrix(m = maf, g = genes, add_missing = fill)
    numMat = om$numericMatrix
    mat_origin = om$oncoMatrix
  } else if(!is.null(mutsig)){ #If user provides significant gene table (e.g; mutsig results)

    if(as.logical(length(grep(pattern = 'gz$', x = mutsig, fixed = FALSE)))){
      #If system is Linux use fread, else use gz connection to read gz file.
      if(Sys.info()[['sysname']] == 'Windows'){
        mutsigResults.gz = gzfile(description = mutsig, open = 'r')
        suppressWarnings(ms <- data.table::as.data.table(read.csv(file = mutsigResults.gz, header = TRUE, sep = '\t', stringsAsFactors = FALSE, comment.char = '#')))
        close(mutsigResults.gz)
      } else{
        ms = suppressWarnings(data.table::fread(cmd = paste('zcat <', mutsig), sep = '\t', stringsAsFactors = FALSE, verbose = FALSE, data.table = TRUE, showProgress = TRUE, header = TRUE))
      }
    } else{
      ms = data.table::fread(input = mutsig, sep = '\t', stringsAsFactors = FALSE, header = TRUE)
    }

    ms$q = as.numeric(gsub(pattern = "^<", replacement = "", x = as.character(ms$q)))
    mach.epsi = .Machine$double.eps
    ms$q = ifelse(test = ms$q == 0, yes = mach.epsi, no = ms$q)
    ms[,FDR := -log10(as.numeric(as.character(q)))]
    ms.smg = ms[q < as.numeric(as.character(mutsigQval))]
    genes = as.character(ms[as.numeric(as.character(q)) < mutsigQval, gene])

    om = createOncoMatrix(m = maf, g = genes)
    numMat = om$numericMatrix
    mat_origin = om$oncoMatrix

    #Check for any missing genes and ignore them if necessary
    if(length(genes[!genes %in% rownames(numMat)]) > 0){
      message('Following genes from MutSig results are not available in MAF:')
      print(genes[!genes %in% rownames(numMat)])
      message('Ignoring them.')
      genes = genes[genes %in% rownames(numMat)]
      ms.smg = ms.smg[gene %in% genes]
    }

    ms.smg = ms.smg[,.(gene, FDR)]
    ms.smg = data.frame(row.names = ms.smg$gene, FDR = ms.smg$FDR)
    ms.smg = ms.smg[rownames(numMat),,drop = FALSE]
  }else { #If user does not provide gene list or MutSig results, draw TOP (default 20) genes
    genes = getGeneSummary(x = maf)[1:top, Hugo_Symbol]
    om = createOncoMatrix(m = maf, g = genes)
    numMat = om$numericMatrix
    mat_origin = om$oncoMatrix
  }

  #---remove genes from genesToIgnore if any
  if(!is.null(genesToIgnore)){
    numMat = numMat[!rownames(numMat) %in% genesToIgnore,]
    mat_origin = mat_origin[!rownames(mat_origin) %in% genesToIgnore,]
  }

  #Total samples
  if(is.null(cohortSize)){
    totSamps = as.numeric(maf@summary[3,summary])
  }else{
    totSamps = cohortSize
  }
  tsbs = levels(getSampleSummary(x = maf)[,Tumor_Sample_Barcode])

  if(!removeNonMutated){
    tsb.include = matrix(data = 0, nrow = nrow(numMat),
                         ncol = length(tsbs[!tsbs %in% colnames(numMat)]))
    colnames(tsb.include) = tsbs[!tsbs %in% colnames(numMat)]
    rownames(tsb.include) = rownames(numMat)
    numMat = cbind(numMat, tsb.include)
    mat_origin = cbind(mat_origin, tsb.include)
  }

  #If user wannts to keep given gene order
  if(keepGeneOrder){
    if(fill){
      numMat = numMat[genes, , drop = FALSE]
    }else{
      if(GeneOrderSort){
        numMat = sortByGeneOrder(m = numMat, g = genes)
      }else{
        numMat = numMat[genes, , drop = FALSE]
      }
    }
    mat = mat_origin[rownames(numMat), , drop = FALSE]
    mat = mat[,colnames(numMat), drop = FALSE]
  }

  if(sortByMutation){
    numMat_temp = sortByMutation(numMat = numMat, maf = maf)
    numMat = numMat[rownames(numMat_temp), colnames(numMat_temp), drop = FALSE]
  }

  samp_sum = data.table::copy(getSampleSummary(x = maf))
  samp_sum[,total := NULL]
  if("CNV_total" %in% colnames(samp_sum)){
    samp_sum[,CNV_total := NULL]
  }

  if(!includeColBarCN){
    suppressWarnings(samp_sum[,Amp := NULL])
    suppressWarnings(samp_sum[,Del := NULL])
  }
  data.table::setDF(x = samp_sum, rownames = as.character(samp_sum$Tumor_Sample_Barcode))
  samp_sum = samp_sum[,-1]

  #Parse annotations
  if(!is.null(clinicalFeatures)){
    if(is.null(annotationDat)){
      annotation = parse_annotation_dat(annotationDat = maf, clinicalFeatures = clinicalFeatures)
    }else{
      annotation = parse_annotation_dat(annotationDat = annotationDat, clinicalFeatures = clinicalFeatures)
    }
    annotation = annotation[colnames(numMat),, drop = FALSE]

    if(sortByAnnotation){
      numMat = sortByAnnotation(numMat = numMat, maf = maf, anno = annotation, annoOrder = annotationOrder, group = groupAnnotationBySize, isNumeric = FALSE)
    }
  }

  if(!is.null(sampleOrder)){
    sampleOrder = as.character(sampleOrder)
    sampleOrder = sampleOrder[sampleOrder %in% colnames(numMat)]
    if(length(sampleOrder) == 0){
      stop("None of the provided samples are present in the input MAF")
    }
    numMat = numMat[,sampleOrder, drop = FALSE]
  }

  gene_sum = apply(numMat, 1, function(x) length(x[x!=0]))
  percent_alt = paste0(round(100*(apply(numMat, 1, function(x) length(x[x!=0]))/totSamps)), "%")

  if(colbar_pathway){
    samp_sum = getSampleSummary(subsetMaf(maf = maf, genes = genes))
    samp_sum[,total := NULL]
    if("CNV_total" %in% colnames(samp_sum)){
      samp_sum[,CNV_total := NULL]
    }

    if(!includeColBarCN){
      suppressWarnings(samp_sum[,Amp := NULL])
      suppressWarnings(samp_sum[,Del := NULL])
    }
    data.table::setDF(x = samp_sum, rownames = as.character(samp_sum$Tumor_Sample_Barcode))
    samp_sum = samp_sum[,-1]
    top_bar_data = t(samp_sum[colnames(numMat),,])
  }else{
    top_bar_data = t(samp_sum[colnames(numMat),,])
  }

  if(is.null(colors)){
    vc_col = get_vcColors()
  }else{
    vc_col = colors
  }
  vc_codes = om$vc #VC codes

  if(nrow(numMat) == 1){
    stop("Oncoplot requires at-least two genes for plottng.")
  }

  #Plot layout
  plot_layout(clinicalFeatures = clinicalFeatures, drawRowBar = drawRowBar,
              drawColBar = drawColBar, draw_titv = draw_titv, exprsTbl = exprsTbl)

  #01: Draw scale axis for expression table
  if(!is.null(exprsTbl)){
    colnames(exprsTbl) = c('genes', 'exprn')
    data.table::setDF(x = exprsTbl, rownames = as.character(exprsTbl$genes))

    missing_samps = rownames(numMat)[!rownames(numMat) %in% rownames(exprsTbl)]
    if(length(missing_samps) > 0){
      temp_data = data.frame(
        row.names = missing_samps,
        genes = missing_samps,
        exprn = rep(0, length(missing_samps)),
        stringsAsFactors = FALSE
      )
      exprsTbl = rbind(exprsTbl, temp_data)
      exprsTbl = exprsTbl[rownames(numMat),]
    }
    exprsTbl = exprsTbl[genes,, drop = FALSE]

    exprs_bar_lims = c(0, round(max(exprsTbl$exprn, na.rm = TRUE), digits = 2))

    if(drawColBar){
      par(mar = c(0.25 , 0, 1, 2), xpd = TRUE)
      plot(x = NA, y = NA, type = "n", axes = FALSE,
           xlim = exprs_bar_lims, ylim = c(0, 1), xaxs = "i")
    }
  }

  #02: Draw top bar plot
  if(drawColBar){
    if(drawRowBar){
      par(mar = c(0.25 , gene_mar, 2, 3), xpd = TRUE)
    }else{
      par(mar = c(0.25 , gene_mar, 2, 5), xpd = TRUE)
    }

    if(logColBar){
      top_bar_data = apply(top_bar_data, 2, function(x) {
        x_fract = x / sum(x)
        x_log_total = log10(sum(x))
        x_fract * x_log_total
      })
      top_bar_data[is.infinite(top_bar_data)] = 0
    }

    plot(x = NA, y = NA, type = "n", xlim = c(0,ncol(top_bar_data)), ylim = c(0, max(colSums(x = top_bar_data, na.rm = TRUE))),
         axes = FALSE, frame.plot = FALSE, xlab = NA, ylab = NA, xaxs = "i")
    axis(side = 2, at = c(0, round(max(colSums(top_bar_data, na.rm = TRUE)))), las = 2, line = 0.5)
    for(i in 1:ncol(top_bar_data)){
      x = top_bar_data[,i]
      x = x[!x == 0]
      if(length(x) > 0){
        rect(xleft = i-1, ybottom = c(0, cumsum(x)[1:(length(x)-1)]), xright = i-0.1,
             ytop = cumsum(x), col = vc_col[names(x)], border = NA, lwd = 0)
      }
    }
    if(logColBar){
      mtext(text = "(log10)", side = 2, line = 2, cex = 0.6)
    }
  }

  #03: Draw scale for side bar plot
  if(drawRowBar){
    if(is.null(mutsig)){
      side_bar_lims = c(0, max(unlist(apply(numMat, 1, function(x) cumsum(table(x[x!=0])))), na.rm = TRUE))
    }else{
      side_bar_lims = c(0, round(max(ms.smg$FDR, na.rm = TRUE), digits = 2))
    }

    if(is.infinite(side_bar_lims[2])){
      side_bar_lims[2] = 1
    }
    if(drawColBar){
      par(mar = c(0.25 , 0, 1, 2), xpd = TRUE)
      plot(x = NA, y = NA, type = "n", axes = FALSE,
           xlim = side_bar_lims, ylim = c(0, 1), xaxs = "i")
    }
  }

  #Draw expression barplot
  if(!is.null(exprsTbl)){

  if(showTumorSampleBarcodes){
    if(!drawRowBar & !drawColBar){
      par(mar = c(barcode_mar, 1, 2.5, 0), xpd = TRUE)
    }else if(!drawRowBar & drawColBar){
      par(mar = c(barcode_mar, 1, 0, 0), xpd = TRUE)
    }else if(drawRowBar & !drawColBar){
      par(mar = c(barcode_mar, 1, 2.5, 0), xpd = TRUE)
    } else{
      par(mar = c(barcode_mar, 1, 0, 0), xpd = TRUE)
    }
  }else{
    if(!drawRowBar & !drawColBar){
      par(mar = c(0.5, 1, 2.5, 0), xpd = TRUE)
    }else if(!drawRowBar & drawColBar){
      par(mar = c(0.5, 1, 0, 0), xpd = TRUE)
    }else if(drawRowBar & !drawColBar){
      par(mar = c(0.5, 1, 2.5, 0), xpd = TRUE)
    } else{
      par(mar = c(0.5, 1, 0, 0), xpd = TRUE)
    }
  }

    plot(x = NA, y = NA, type = "n", xlim = rev(-exprs_bar_lims), ylim = c(0, nrow(exprsTbl)),
         axes = FALSE, frame.plot = FALSE, xlab = NA, ylab = NA, xaxs = "i", yaxs = "i") #
    for(i in 1:nrow(exprsTbl)){
      x = rev(exprsTbl$exprn)[i]
      rect(ybottom = i-1, xleft = -x, ytop = i-0.1,
           xright = 0, col = "#F2F2F2", border = NA, lwd = 0)
    }
    axis(side = 3, at = rev(-exprs_bar_lims), outer = FALSE, line = 0.25, labels = rev(exprs_bar_lims))
  }

  #04: Draw the main matrix
  if(showTumorSampleBarcodes){
    if(!drawRowBar & !drawColBar){
      par(mar = c(barcode_mar, gene_mar, 2.5, 5), xpd = TRUE)
    }else if(!drawRowBar & drawColBar){
      par(mar = c(barcode_mar, gene_mar, 0, 3), xpd = TRUE)
    }else if(drawRowBar & !drawColBar){
      par(mar = c(barcode_mar, gene_mar, 2.5, 3), xpd = TRUE)
    } else{
      par(mar = c(barcode_mar, gene_mar, 0, 3), xpd = TRUE)
    }
  }else{
    if(!drawRowBar & !drawColBar){
      par(mar = c(0.5, gene_mar, 2.5, 5), xpd = TRUE)
    }else if(!drawRowBar & drawColBar){
      par(mar = c(0.5, gene_mar, 0, 5), xpd = TRUE)
    }else if(drawRowBar & !drawColBar){
      par(mar = c(0.5, gene_mar, 2.5, 3), xpd = TRUE)
    } else{
      par(mar = c(0.5, gene_mar, 0, 3), xpd = TRUE)
    }
  }

  nm = t(apply(numMat, 2, rev))
  nm[nm == 0] = NA
  image(x = 1:nrow(nm), y = 1:ncol(nm), z = nm, axes = FALSE, xaxt="n", yaxt="n",
        xlab="", ylab="", col = "white") #col = "#FC8D62"
  #Plot for all variant classifications
  vc_codes_temp = vc_codes[!vc_codes %in% c('Amp', 'Del')]
  for(i in 2:length(names(vc_codes_temp))){
    vc_code = vc_codes_temp[i]
    col = vc_col[vc_code]
    nm = t(apply(numMat, 2, rev))
    nm[nm != names(vc_code)] = NA
    #Suppress warning due to min/max applied to a vector of NAs; Issue: #286
    #This is an harmless warning as matrix is looped over all VC's and missing VC's form NA's (which are plotted in gray)
    suppressWarnings(image(x = 1:nrow(nm), y = 1:ncol(nm), z = nm, axes = FALSE, xaxt="n", yaxt="n",
          xlab="", ylab="", col = col, add = TRUE))
  }

  #Add blanks
  nm = t(apply(numMat, 2, rev))
  nm[nm != 0] = NA
  image(x = 1:nrow(nm), y = 1:ncol(nm), z = nm, axes = FALSE, xaxt="n", yaxt="n", xlab="", ylab="", col = bgCol, add = TRUE)

  #Add CNVs if any
  mat_origin = mat_origin[rownames(numMat), colnames(numMat), drop = FALSE]
  if(writeMatrix){
    write.table(mat_origin, paste0(prefix_name, "-onco_matrix.txt"), sep = "\t", quote = FALSE)
  }
  mo = t(apply(mat_origin, 2, rev))

  ##Complex events (mutated as well as CN altered)
  complex_events = unique(grep(pattern = ";", x = mo, value = TRUE))

  if(length(complex_events) > 0){
    for(i in 1:length(complex_events)){
      ce = complex_events[i]
      #mo = t(apply(mat_origin, 2, rev))
      ce_idx = which(mo == ce, arr.ind = TRUE)

      ce = unlist(strsplit(x = ce, split = ";", fixed = TRUE))

      nm_temp = matrix(NA, nrow = nrow(nm), ncol = ncol(nm))
      nm_temp[ce_idx] = 0
      image(x = 1:nrow(nm_temp), y = 1:ncol(nm_temp), z = nm_temp, axes = FALSE, xaxt="n",
            yaxt="n", xlab="", ylab="", col = vc_col[ce[2]], add = TRUE)
      points(ce_idx, pch= 15, col= vc_col[ce[1]])
    }
  }

  del_idx = which(mo == "Del", arr.ind = TRUE)
  amp_idx = which(mo == "Amp", arr.ind = TRUE)

  if(nrow(amp_idx) > 0){
    nm_temp = matrix(NA, nrow = nrow(nm), ncol = ncol(nm))
    nm_temp[amp_idx] = 0
    image(x = 1:nrow(nm_temp), y = 1:ncol(nm_temp), z = nm_temp, axes = FALSE, xaxt="n",
          yaxt="n", xlab="", ylab="", col = bgCol, add = TRUE)
    points(amp_idx, pch= 15, col= vc_col['Amp'], cex = 1.5)
  }

  if(nrow(del_idx) > 0){
    nm_temp = matrix(NA, nrow = nrow(nm), ncol = ncol(nm))
    nm_temp[del_idx] = 0
    image(x = 1:nrow(nm_temp), y = 1:ncol(nm_temp), z = nm_temp, axes = FALSE, xaxt="n",
          yaxt="n", xlab="", ylab="", col = bgCol, add = TRUE)
    points(del_idx, pch= 15, col= vc_col['Del'], cex = 1.5)
  }

  #Draw if any additional features are requested
  additionalFeature_legend = FALSE
  if(!is.null(additionalFeature)){
    if(length(additionalFeature) < 2){
      stop("additionalFeature must be of length two. See ?oncoplot for details.")
    }
    af_dat = subsetMaf(maf = maf, genes = rownames(numMat), tsb = colnames(numMat), fields = additionalFeature[1], includeSyn = FALSE, mafObj = FALSE)
    if(length(which(colnames(af_dat) == additionalFeature[1])) == 0){
      message(paste0("Column ", additionalFeature[1], " not found in maf. Here are available fields.."))
      print(getFields(maf))
      stop()
    }
    colnames(af_dat)[which(colnames(af_dat) == additionalFeature[1])] = 'temp_af'
    af_dat = af_dat[temp_af %in% additionalFeature[2]]
    if(nrow(af_dat) == 0){
      warning(paste0("No samples are enriched for ", additionalFeature[2], " in ", additionalFeature[1]))
    }else{
      af_mat = data.table::dcast(data = af_dat, Tumor_Sample_Barcode ~ Hugo_Symbol, value.var = "temp_af", fun.aggregate = length)
      af_mat = as.matrix(af_mat, rownames = "Tumor_Sample_Barcode")

      nm = t(apply(numMat, 2, rev))

      lapply(seq_len(nrow(af_mat)), function(i){
        af_i = af_mat[i,, drop = FALSE]
        af_i_genes = colnames(af_i)[which(af_i > 0)]
        af_i_sample = rownames(af_i)

        lapply(af_i_genes, function(ig){
          af_i_mat = matrix(c(which(rownames(nm) == af_i_sample),
                              which(colnames(nm) == ig)),
                            nrow = 1)
          points(af_i_mat, pch = additionalFeaturePch, col= additionalFeatureCol, cex = additionalFeatureCex)
        })
      })
      additionalFeature_legend = TRUE
    }
  }

  #Add grids
  abline(h = (1:ncol(nm)) + 0.5, col = borderCol, lwd = sepwd_genes)
  abline(v = (1:nrow(nm)) + 0.5, col = borderCol, lwd = sepwd_samples)

  mtext(text = colnames(nm), side = 2, at = 1:ncol(nm),
        font = 3, line = 0.4, cex = fontSize, las = 2)
  mtext(text = rev(percent_alt), side = 4, at = 1:ncol(nm),
        font = 1, line = 0.4, cex = fontSize, las = 2, adj = 0.15)

  if(showTumorSampleBarcodes){
    text(x =1:nrow(nm), y = par("usr")[3] - 0.2,
         labels = rownames(nm), srt = 90, font = 1, cex = SampleNamefontSize, adj = 1)
  }

  #05: Draw side bar plot
  if(drawRowBar){
    if(showTumorSampleBarcodes){
      if(!drawRowBar || !drawColBar){
        par(mar = c(barcode_mar, 0, 2.5, 1), xpd = TRUE)
      }else{
        par(mar = c(barcode_mar, 0, 0, 1), xpd = TRUE)
      }
    }else{
      if(!drawRowBar || !drawColBar){
        par(mar = c(0.5, 0, 2.5, 1), xpd = TRUE)
      }else{
        par(mar = c(0.5, 0, 0, 1), xpd = TRUE)
      }
    }

    if(is.null(mutsig)){
      side_bar_data = apply(numMat, 1, function(x) table(x[x!=0]))
      plot(x = NA, y = NA, type = "n", xlim = side_bar_lims, ylim = c(0, length(side_bar_data)),
           axes = FALSE, frame.plot = FALSE, xlab = NA, ylab = NA, xaxs = "i", yaxs = "i") #

      for(i in 1:length(side_bar_data)){
        x = rev(side_bar_data)[[i]]
        if(length(x) > 0){
          rect(ybottom = i-1, xleft = c(0, cumsum(x)[1:(length(x)-1)]), ytop = i-0.1,
               xright = cumsum(x), col = vc_col[vc_codes[names(x)]], border = NA, lwd = 0)
        }
      }
      axis(side = 3, at = side_bar_lims, outer = FALSE, line = 0.25)

    }else{

      plot(x = NA, y = NA, type = "n", xlim = side_bar_lims, ylim = c(0, nrow(ms.smg)),
           axes = FALSE, frame.plot = FALSE, xlab = NA, ylab = NA, xaxs = "i", yaxs = "i") #
      for(i in 1:nrow(ms.smg)){
        x = rev(ms.smg$FDR)[i]
        rect(ybottom = i-1, xleft = 0, ytop = i-0.1,
             xright = x, col = "#F2F2F2", border = NA, lwd = 0)
      }
      axis(side = 3, at = side_bar_lims, outer = FALSE, line = 0.25)
    }
  }

  #06: Plot annotations if any
  if(!is.null(clinicalFeatures)){

    clini_lvls = as.character(unlist(lapply(annotation, function(x) unique(as.character(x)))))

    if(is.null(annotationColor)){
      annotationColor = get_anno_cols(ann = annotation)
    }

    annotationColor = lapply(annotationColor, function(x) {
      na_idx = which(is.na(names(x)))
      x[na_idx] = "#F2F2F2"
      names(x)[na_idx] = "NA"
      x
    })

    anno_cols = c()
    for(i in 1:length(annotationColor)){
      anno_cols = c(anno_cols, annotationColor[[i]])
    }

    #clini_lvls = clini_lvls[!is.na(clini_lvls)]
    temp_names = suppressWarnings(sample(x = setdiff(x = 1:1000, y = as.numeric(as.character(clini_lvls))), size = length(clini_lvls), replace = FALSE))
    names(clini_lvls) = temp_names#1:length(clini_lvls)
    temp_rownames = rownames(annotation)
    annotation = data.frame(lapply(annotation, as.character),
                            stringsAsFactors = FALSE, row.names = temp_rownames)

    for(i in 1:length(clini_lvls)){
      annotation[annotation == clini_lvls[i]] = names(clini_lvls[i])
    }

    annotation = data.frame(lapply(annotation, as.numeric), stringsAsFactors=FALSE, row.names = temp_rownames)

    annotation = annotation[colnames(numMat), ncol(annotation):1, drop = FALSE]

    if(!is.null(exprsTbl)){
      plot.new()
    }

    if(!drawRowBar){
      par(mar = c(0, gene_mar, 0, 5), xpd = TRUE)
    }else{
      par(mar = c(0, gene_mar, 0, 3), xpd = TRUE)
    }

    image(x = 1:nrow(annotation), y = 1:ncol(annotation), z = as.matrix(annotation),
          axes = FALSE, xaxt="n", yaxt="n", bty = "n",
          xlab="", ylab="", col = "white") #col = "#FC8D62"

    #Plot for all variant classifications
    for(i in 1:length(names(clini_lvls))){
      anno_code = clini_lvls[i]
      col = anno_cols[anno_code]
      #temp_anno = t(apply(annotation, 2, rev))
      temp_anno = as.matrix(annotation)
      #Handle NA's
      if(is.na(col)){
        col = "#F2F2F2"
        temp_anno[is.na(temp_anno)] = as.numeric(names(anno_code))
      }
      temp_anno[temp_anno != names(anno_code)] = NA

      suppressWarnings(image(x = 1:nrow(temp_anno), y = 1:ncol(temp_anno), z = temp_anno,
            axes = FALSE, xaxt="n", yaxt="n", xlab="", ylab="", col = col, add = TRUE))
    }

    #Add grids
    abline(h = (1:ncol(nm)) + 0.5, col = "white", lwd = sepwd_genes)
    abline(v = (1:nrow(nm)) + 0.5, col = "white", lwd = sepwd_samples)
    mtext(text = colnames(annotation), side = 4,
          font = 1, line = 0.4, cex = fontSize, las = 2, at = 1:ncol(annotation))

    if(drawRowBar){
      plot.new()
    }
  }

  #07: Draw TiTv plot
  if(draw_titv){
    titv_dat = titv(maf = maf, useSyn = TRUE, plot = FALSE)
    titv_dat = titv_dat$fraction.contribution
    data.table::setDF(x = titv_dat, rownames = as.character(titv_dat$Tumor_Sample_Barcode))
    titv_dat = titv_dat[,-1]
    titv_dat = t(titv_dat[colnames(numMat), ])

    missing_samps = colnames(numMat)[!colnames(numMat) %in% colnames(titv_dat)]
    if(length(missing_samps) > 0){
      temp_data = matrix(data = 0, nrow = 6, ncol = length(missing_samps))
      colnames(temp_data) = missing_samps
      titv_dat = cbind(titv_dat, temp_data)
      titv_dat = titv_dat[,colnames(numMat)]
    }

    if(!is.null(exprsTbl)){
     plot.new()
    }

    if(!drawRowBar){
      par(mar = c(0, gene_mar, 0, 5), xpd = TRUE)
    }else{
      par(mar = c(0, gene_mar, 0, 3), xpd = TRUE)
    }


    plot(x = NA, y = NA, type = "n", xlim = c(0,ncol(titv_dat)), ylim = c(0, 100),
         axes = FALSE, frame.plot = FALSE, xlab = NA, ylab = NA, xaxs = "i")

    titv_col = get_titvCol(alpha = 1)
    for(i in 1:ncol(titv_dat)){
      x = titv_dat[,i]
      x = x[x > 0]
      if(length(x) > 0){
        rect(xleft = i-1, ybottom = c(0, cumsum(x)[1:(length(x)-1)]), xright = i-0.1,
             ytop = cumsum(x), col = titv_col[names(x)], border = NA, lwd = 0)
      }else{
        rect(xleft = i-1, ybottom = c(0, 100), xright = i-0.1,
             ytop = 100, col = "#F2F2F2", border = NA, lwd = 0)
      }
    }

    if(drawRowBar){
      par(mar = c(0, 0, 1, 6), xpd = TRUE)
      plot(NULL,ylab='',xlab='', xlim=0:1, ylim=0:1, axes = FALSE)
      lep = legend("topleft", legend = names(titv_col),
                   col = titv_col, border = NA, bty = "n",
                   ncol= 2, pch = 15, xpd = TRUE, xjust = 0, yjust = 0,
                   cex = legendFontSize)

    }else{
      mtext(text = names(titv_col)[1:3], side = 2, at = c(25, 50, 75),
            font = 1, line = 0.4, cex = fontSize, las = 2, col = titv_col[1:3])
      mtext(text = names(titv_col)[4:6], side = 4, at = c(25, 50, 75),
            font = 1, line = 0.4, cex = fontSize, las = 2, col = titv_col[4:6],  adj = 0.15)
    }
  }

  #08: Add legends
  par(mar = c(0, 0.5, 0, 0), xpd = TRUE)

  plot(NULL,ylab='',xlab='', xlim=0:1, ylim=0:1, axes = FALSE)
  leg_classes = vc_col[vc_codes[2:length(vc_codes)]]
  leg_classes_pch = rep(15, length(leg_classes))
  if(additionalFeature_legend){
    leg_classes = c(leg_classes,"#F2F2F2")
    names(leg_classes)[length(leg_classes)] = paste(additionalFeature, collapse = ":")
    leg_classes_pch = c(leg_classes_pch, additionalFeaturePch)
  }

  lep = legend("topleft", legend = names(leg_classes),
               col = leg_classes, border = NA, bty = "n",
               ncol= 2, pch = leg_classes_pch, xpd = TRUE, xjust = 0, yjust = 0, cex = legendFontSize)

  x_axp = 0+lep$rect$w

  if(!is.null(clinicalFeatures)){

    for(i in 1:ncol(annotation)){
      #x = unique(annotation[,i])
      x = annotationColor[[i]]

      if(length(x) <= 4){
        n_col = 1
      }else{
        n_col = (length(x) %/% 4)+1
      }
      names(x)[is.na(names(x))] = "NA"

      lep = legend(x = x_axp, y = 1, legend = names(x),
                   col = x, border = NA,
                   ncol= n_col, pch = 15, xpd = TRUE, xjust = 0, bty = "n",
                   cex = annotationFontSize, title = rev(names(annotation))[i],
                   title.adj = 0)
      x_axp = x_axp + lep$rect$w

    }
  }

  if(removeNonMutated){
    #mutSamples = length(unique(unlist(genesToBarcodes(maf = maf, genes = rownames(mat), justNames = TRUE))))
    altStat = paste0("Altered in ", ncol(numMat), " (", round(ncol(numMat)/totSamps, digits = 4)*100, "%) of ", totSamps, " samples.")
  }else{
    mutSamples = length(unique(unlist(genesToBarcodes(maf = maf, genes = rownames(numMat), justNames = TRUE))))
    altStat = paste0("Altered in ", mutSamples, " (", round(mutSamples/totSamps, digits = 4)*100, "%) of ", totSamps, " samples.")
  }

  if(showTitle){
    title(main = altStat, outer = TRUE, line = -1, cex.main = titleFontSize)
  }
}
