#' @import ggplot2
#' @export
mean_plot <- function(formatted_results){
  #todo: generalize faceting
  ggplot(formatted_results,aes_string(x="strata_label", y="estimate", ymin="ci_lower", ymax="ci_upper"))+
    geom_point()+geom_errorbar()+coord_flip()+
    xlab("Strata")+ylab("Estimate")+theme_bw()+ggtitle("Strata-specific Means")+
    theme(axis.text.x=element_text(angle=90, hjust=1, vjust=0.5))
}