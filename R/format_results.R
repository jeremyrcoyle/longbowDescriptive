#' @export
get_obs_counts <- function(data, nodes){
  to_count <- data[,c(nodes$strata,nodes$Y), with=FALSE]
  setnames(to_count, c(nodes$strata, "Y"))
  set(to_count, ,"Y", paste("nY",to_count$Y,sep=""))
  count_cats <- do.call(CJ, lapply(to_count, unique))

  counts <- setkey(to_count)[count_cats, list(nY=.N), by=.EACHI]
  counts[,n:=sum(nY), by=eval(c(nodes$strata))]
  counts <- counts[n!=0]
  return(counts)
}

#' @export
format_results <- function(results, data, nodes){
  # get nodes
  node_data <- as.data.table(lapply(nodes[c("W","Y")],paste,collapse=", "))
  if(is.null(node_data$W)){
    node_data$W="unadjusted"
  }

  set(results, , names(node_data), node_data)

  # pull out useful columns
  keep_cols <- c(nodes$strata, "W", "Y",
                 "type", "param",
                 "psi_transformed", "lower_transformed", "upper_transformed",
                 "tmle_est","se")
  nice_names <- c(nodes$strata, "adjustment_set", "outcome_variable",
                "type", "parameter",
                "estimate","ci_lower","ci_upper",
                "untransformed_estimate","untransformed_se")
  formatted <- results[,keep_cols, with=FALSE]
  setnames(formatted, nice_names)

  # add collapsed strata label for plotting
  strata_map <- collapse_strata(data, nodes)
  formatted <- merge(strata_map,formatted, by=nodes$strata)

  return(formatted)
}
