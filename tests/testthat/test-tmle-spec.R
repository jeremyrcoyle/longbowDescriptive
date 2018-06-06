context("TMLE Spec")
library(sl3)
library(tmle3)
data(sample_rf_data)
nodes <- list(
  strata = c("study_id"),
  W = c(
    "apgar1", "apgar5", "gagebrth", "mage",
    "meducyrs", "sexn"
  ),
  A = "parity_cat",
  Y = "haz01"
)

# drop missing values
processed <- process_missing(sample_rf_data, nodes, complete_nodes = c("strata","A","Y"))
data <- processed$data
nodes <- processed$node_list

#define learners
if(FALSE && length(nodes$W)>0){
  qlib <- make_learner_stack("Lrnr_mean",
                             "Lrnr_glm_fast",
                             "Lrnr_glmnet",
                             list("Lrnr_xgboost", nthread=1))

  glib <- make_learner_stack("Lrnr_mean",
                             "Lrnr_glmnet",
                             list("Lrnr_xgboost", nthread=1))



  # qlib <- glib <- make_learner_stack("Lrnr_mean")
  mn_metalearner <- make_learner(Lrnr_solnp, loss_function = loss_loglik_multinomial, learner_function = metalearner_linear_multinomial)
  metalearner <- make_learner(Lrnr_nnls)
  Q_learner <- make_learner(Lrnr_sl, qlib, metalearner)
  g_learner <- make_learner(Lrnr_sl, glib, mn_metalearner)
} else {
  Q_learner <- make_learner(Lrnr_glm)
  g_learner <- make_learner(Lrnr_mean)
}

learner_list <- list(Y=Q_learner, A=g_learner)
# tmle3_Fit$debug(".tmle_fit")
tmle_spec<-tmle_risk_binary(baseline_level="[1,2)")
# debugonce(tmle_spec$make_params)
tmle_fit <- tmle3(tmle_spec, data, nodes, learner_list)
