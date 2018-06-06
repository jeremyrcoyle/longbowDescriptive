#load longbowtools
library(longbowtools)
library(devtools)
library(jsonlite)

# template file
rmd_filename <- system.file("templates/longbow_RiskFactors.Rmd", package="longbowRiskFactors")

# generate inputs file (can also use an existing one)
# params <- params_from_rmd(rmd_filename, sample_json)

# inputs file
sample_json <- system.file("sample_data/sample_inputs_unadjusted.json", package="longbowRiskFactors")

# to run on your machine
run_locally(rmd_filename, sample_json, open_result = TRUE)

# to run on ghap rcluster
# provide your ghap credentials
configure_cluster("~/cluster_credentials.json")

# provide inputs (these reference Andrew's dataset)
# inputs_json <- "~/Dropbox/gates/tlapp-demo/templates/birthweight_inputs.json"
run_on_longbow(rmd_filename, sample_json, open_result = TRUE)

# now run on ghap cluster with ghap data
ghap_test_json <- system.file("sample_data/ghap_test.json", package="longbowRiskFactors")
job_id <- run_on_longbow(rmd_filename, ghap_test_json, open_result = TRUE)

# publish your template for other users to use
publish_template(rmd_filename, open_result = TRUE)
