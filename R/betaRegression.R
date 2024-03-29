.betaRegression <- function(formula, link = "probit", object, mc.cores, ...){
  
  strand(object) <- "*"
  object <- sort(object)

  if(link == "loglog"){
    inv.link <- function(x){
      exp(-exp(-x))
    }
  }
  if(link == "logit"){
    inv.link <- function(x){
      1 / ( 1 + exp(-x))
    }
  }
  if(link == "probit"){
    inv.link <- function(x){
      pnorm(x)
    }
  }
  if(link == "cloglog"){
    inv.link <- function(x){
      1 - exp(-exp(x))
    }
  }
  if(link == "log"){
    inv.link <- function(x){
      exp(x)
    }
  }
  
  min.meth <- min(methLevel(object)[methLevel(object) > 0], na.rm=TRUE)
  max.meth <- max(methLevel(object)[methLevel(object) < 1], na.rm=TRUE)
  
  object.split <- split(object, f = rep(1:mc.cores, length.out = nrow(object)))

  beta.regr <- function(object.part, formula, link, ...){
    chr <- as.character(seqnames(rowData(object.part)))
    pred.meth.part <- methLevel(object.part)

    p.val <- rep(NA,nrow(object.part))
    meth.group1 <- rep(NA,nrow(object.part))
    meth.group2 <- rep(NA,nrow(object.part))
    meth.diff <- rep(NA,nrow(object.part))
    direction <- rep(NA,nrow(object.part))
    pseudo.R.sqrt <- rep(NA,nrow(object.part))
    estimate <- rep(NA,nrow(object.part))
    std.error <- rep(NA,nrow(object.part))

    for(j in 1:nrow(pred.meth.part)){
      pred.meth <- pred.meth.part[j,]
      pred.meth[pred.meth == 0] <- min.meth
      pred.meth[pred.meth == 1] <- max.meth
      data <- cbind(pred.meth = pred.meth,
                    as.data.frame(colData(object)))
      options(show.error.messages = FALSE)
      suppressWarnings(
                       lmodel <- try(summary(betareg(formula = as.formula(paste("pred.meth ~ ", formula[2])),
                                                     data=data, link = link, ...)), silent=TRUE)
                       )
      options(show.error.messages = TRUE)
      if(class(lmodel) == "try-error"){
        p.val[j] <- NA
        meth.diff[j] <- NA
      } else{
                                        # Test auf 0: 2 * pnorm(-abs(Estimate / Std.Error))
                                        # Test auf min.diff > 0: 2 * min(0.5, pnorm( -(abs(Estimate)-min.diff)/Std.Error, mean=-min.diff))
        p.val[j] <- max(lmodel$coefficients$mean[2, 4], 1e-323) # should not be zero
        baseline <- lmodel$coefficients$mean[1, 1]
        coef <- lmodel$coefficients$mean[2, 1]
        se <- lmodel$coefficients$mean[2, 2]
        meth.group1[j] <- inv.link(baseline)
        meth.group2[j] <- inv.link(baseline + coef)
        meth.diff[j] <-  meth.group1[j] - meth.group2[j]
        pseudo.R.sqrt[j] <- lmodel$pseudo.r.squared
        estimate[j] <- coef
        std.error[j] <- se
      }
    }
    
    out <- data.frame(chr = chr,
                      pos = start(ranges(object.part)),
                      p.val,
                      meth.group1,
                      meth.group2,
                      meth.diff,
                      estimate,
                      std.error,
                      pseudo.R.sqrt)
    return(out)
  }
  
  summary.df.l <- mclapply(object.split, beta.regr, formula=formula, link=link, mc.cores=mc.cores, ...)
  summary.df <- do.call(rbind, summary.df.l)
  pos.object <- paste(seqnames(object), start(object), sep="_")
  pos.summary <- paste(summary.df$chr, summary.df$pos, sep="_")
  ind <- match(pos.object, pos.summary)
  summary.df <- summary.df[ind,]
  summary.df$cluster.id <- elementMetadata(rowData(object))$cluster.id
  return(summary.df)
}



setMethod("betaRegression",
          signature=c(formula = "formula", link = "character", object="BSrel", mc.cores = "numeric"),
          .betaRegression)

setMethod("betaRegression",
          signature=c(formula = "formula", link = "character",  object="BSrel", mc.cores = "missing"),
          function(formula, link, object, ...) {
            .betaRegression(formula, link, object, mc.cores = 1, ...)
          })
