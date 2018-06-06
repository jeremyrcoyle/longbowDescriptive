# generate sample data with the expected structure
library(devtools)
library(usethis)
library(sl3)
library(tmle3)
library(data.table)

data(cpp)

data <- as.data.table(cpp)

# for now, complete case on tx and outcome
data <- data[!is.na(parity) & !is.na(haz)]

data$parity01 <- as.numeric(data$parity > 0)
data$parity_cat <- data$parity
data$haz01 <- as.numeric(data$haz > 0)
discretize_variable(data, "parity_cat", 4)
data$parity_cat
data$study_id <- sample(1:5, nrow(data), replace=TRUE)
write.csv(data,package_file("inst","sample_data","birthwt_data.csv"),row.names=FALSE)
sample_rf_data <- data
use_data(sample_rf_data, overwrite = TRUE)
