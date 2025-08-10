#1.5 print LOOIC and WAIC
printFit <- function(..., 
                     ic      = "looic",
                     ncore   = 2,
                     roundTo = 3) {
  
  # Computes "Akaike weights" with LOOIC/WAIC values
  akaike_weights <- function (dev) {
    d <- dev - min(dev)
    f <- exp(-0.5 * d)
    w <- f/sum(f)
    return(w)
  }
  
  modelList <- list(...)
  
  if (ic == "looic") {  # compute only LOOIC
    modelTable = data.frame(Model = NULL, LOOIC = NULL)
    for (i in 1:length(modelList)) {
      #modelTable[i, "Model"] = modelList[[i]]$model
      modelTable[i, "LOOIC"] = extract_ic(modelList[[i]], ic = "looic")$LOOIC$estimates[3,1]
    }
    modelTable[, "LOOIC Weights"] = akaike_weights(modelTable$LOOIC)
    modelTable[,2] <- round(modelTable[,2], roundTo)
  } else if (ic == "waic") { # compute only WAIC
    modelTable = data.frame(Model = NULL, WAIC = NULL)
    for (i in 1:length(modelList)) {
      modelTable[i, "Model"] = modelList[[i]]$model
      modelTable[i, "WAIC"]  = extract_ic(modelList[[i]], ic = "waic")$WAIC$estimates[3,1]
    }
    modelTable[, "WAIC Weights"] = akaike_weights(modelTable$WAIC)
    modelTable[,2] <- round(modelTable[,2], roundTo)
  } else if (ic == "both") { # compute both LOOIC and WAIC
    modelTable = data.frame(Model = NULL, LOOIC = NULL, WAIC = NULL)
    for (i in 1:length(modelList)) {
      #modelTable[i, "Model"] = modelList[[i]]$model
      modelTable[i, "LOOIC"] = extract_ic(modelList[[i]], ic = "both")$LOOIC$estimates[3,1]
      modelTable[i, "WAIC"]  = extract_ic(modelList[[i]], ic = "both")$WAIC$estimates[3,1]
    }
    modelTable[, "LOOIC Weights"] = akaike_weights(modelTable$LOOIC)
    modelTable[, "WAIC Weights"] = akaike_weights(modelTable$WAIC)
    modelTable[,2:3] <- round(modelTable[,2:3], roundTo)
  } else {
    stop("Set 'ic' as 'looic', 'waic', or 'both' \n")
  }
  return(modelTable)
}