setwd("~/R/Analyses/LIME Test")

library(plyr)
library(tidyverse)
library(caret)
library(lime)


trans <- read_csv("transaction_data.csv") %>% rename_all(funs(tolower))
coupon <- read_csv("coupon.csv") %>% rename_all(funs(tolower))
campaign <- read_csv("campaign_table.csv") %>% rename_all(funs(tolower))
campaign_lookup <- read_csv("campaign_desc.csv") %>% rename_all(funs(tolower))
prod <- read_csv("product.csv") %>% rename_all(funs(tolower))
hh_dem <- read_csv("hh_demographic.csv") %>% rename_all(funs(tolower))
#causal_data <- read_csv("causal_data.csv")





