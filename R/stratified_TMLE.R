#' collapse strata columns into a single strata identifier
#' @import data.table
#' @export
collapse_strata <- function(data, nodes)
{
  # get strata levels
  strata <- data[,nodes$strata, with=FALSE]
  strata <- unique(strata)
  set(strata, , "strata_id", 1:nrow(strata))

  # format strata labels
  suppressWarnings({
    long <- melt(strata, id.vars="strata_id", measure.vars=c())
  })
  set(long, , "label", sprintf("%s: %s",long$variable, long$value))
  collapsed <- long[, list(strata_label=paste(label, collapse=", ")), by=list(strata_id)]

  # build map
  strata_map <- merge(strata, collapsed, by="strata_id")
  strata_map$strata_id <- NULL
  strata_map <- setkey(strata_map, "strata_label")
  strata_labels <- strata_map[data, strata_label, on=eval(nodes$strata)]
  set(data, , "strata_label", strata_labels)
  return(strata_map)
}

tmle_for_stratum <- function(stratum_data, nodes, learner_list){
  tmle_spec <- tmle_descriptive()
  tmle_fit <- tmle3(tmle_spec, stratum_data, nodes, learner_list)
  return(tmle_fit$summary)
}

#' @export
#' @importFrom data.table rbindlist
stratified_tmle <- function(data, nodes,learner_list, strata){
  #todo: make this fallback to standard tmle if no stratifying variables
  strata_labels <- strata$strata_label

  # stratum_label=strata_labels[[1]]
  all_results <- lapply(strata_labels, function(stratum_label){
    message("tmle for:\t",stratum_label)
    stratum_data <- data[strata_label==stratum_label]
    stratum_ids <- strata[strata_label==stratum_label]
    results <- tmle_for_stratum(stratum_data, nodes, learner_list)

    results <- cbind(stratum_ids,results)

    return(results)
  })

  results <- rbindlist(all_results)
  return(results)
}
