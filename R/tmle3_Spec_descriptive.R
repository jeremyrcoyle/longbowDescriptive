#' Defines a tmle (minus the data)
#'
#' Current limitations:
#' @importFrom R6 R6Class
#' @importFrom tmle3 tmle3_Spec Param_delta
#'
#' @export
#
tmle3_Spec_descriptive <- R6Class(
  classname = "tmle3_Spec_descriptive",
  portable = TRUE,
  class = TRUE,
  inherit = tmle3_Spec,
  public = list(
    initialize = function(...) {
      super$initialize(...)
    },
    make_tmle_task = function(data, node_list, ...) {
      # make tmle_task
      npsem <- list(
        define_node("W", node_list$W),
        define_node("Y", node_list$Y, c("W"))
      )
      
      if(!is.null(node_list$id)){
        tmle_task <- tmle3_Task$new(data, npsem = npsem, id=node_list$id, ...)  
      } else {
        tmle_task <- tmle3_Task$new(data, npsem = npsem, ...)
      }
      
      return(tmle_task)
    },
    make_initial_likelihood = function(tmle_task, learner_list = NULL) {
      # todo: generalize
      factor_list <- list(
        define_lf(LF_emp, "W"),
        define_lf(LF_fit, "Y", learner = learner_list[["Y"]], type = "mean")
      )

      likelihood_def <- Likelihood$new(factor_list)

      # fit_likelihood
      likelihood <- likelihood_def$train(tmle_task)
      return(likelihood)
    },
    make_updater = function() {
      updater <- tmle3_Update$new()
    },
    make_targeted_likelihood = function(likelihood, updater) {
      targeted_likelihood <- Targeted_Likelihood$new(likelihood, updater)
      return(targeted_likelihood)
    },
    make_params = function(tmle_task, likelihood) {
      mean_param <- Param_mean$new(likelihood)
      return(mean_param)
    }
  ),
  active = list(),
  private = list()
)

#' Risk Measures for Binary Outcomes
#'
#' Estimates TSMs, RRs, PAR, and PAF
#'
#' O=(W,A,Y)
#' W=Covariates
#' A=Treatment (binary or categorical)
#' Y=Outcome binary
#' @importFrom sl3 make_learner Lrnr_mean
#' @export
tmle_descriptive <- function() {
  # todo: unclear why this has to be in a factory function
  tmle3_Spec_descriptive$new()
}
