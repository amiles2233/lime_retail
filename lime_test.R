
library(plyr)
library(tidyverse)
library(caret)
library(lime)


trans <- read_csv("transaction_data.csv") %>% rename_all(funs(tolower)) %>%
  mutate(single_price=ifelse(retail_disc<0,(sales_value-(retail_disc+coupon_match_disc))/quantity,
                            (sales_value-coupon_match_disc)/quantity),
         combined_price=single_price*quantity,
         disc_rate=(combined_price-sales_value)/combined_price)
coupon <- read_csv("coupon.csv") %>% rename_all(funs(tolower))
campaign <- read_csv("campaign_table.csv") %>% rename_all(funs(tolower))
campaign_lookup <- read_csv("campaign_desc.csv") %>% rename_all(funs(tolower))
prod <- read_csv("product.csv") %>% rename_all(funs(tolower))
hh_dem <- read_csv("hh_demographic.csv") %>% rename_all(funs(tolower))
#causal_data <- read_csv("causal_data.csv")


## Outcome Variable is Whether they transacted on week 101

wk101trans <- trans %>%
  filter(week_no==101) %>%
  select(household_key, basket_id, sales_value) %>%
  group_by(household_key) %>%
  summarize(trans101=n_distinct(basket_id),
            sales101=sum(sales_value)) %>%
  ungroup() 

wk101campaigns <- campaign %>%
  left_join(campaign_lookup) %>%
  filter(end_day>=699) %>%
  select(household_key, description) %>%
  distinct()

wk101 <- trans %>%
  filter(week_no<101) %>%
  select(household_key) %>%
  distinct() %>%
  left_join(wk101trans) %>%
  left_join(wk101campaigns) %>%
  replace_na(replace=list(sales101=0,trans101=0,description="NoCampaign")) %>%
  mutate(shop101=ifelse(trans101>0,1,0))


camp_pre_101 <- campaign %>%
  left_join(campaign_lookup) %>%
  filter(end_day<699) %>%
  group_by(household_key, description) %>%
  summarize(campaigns=n_distinct(campaign)) %>%
  ungroup() %>%
  spread(description, campaigns) %>%
  replace_na(replace=list(TypeA=0,TypeB=0,TypeC=0))

pre101 <-trans %>%
  filter(week_no<101, sales_value>0) %>%
  arrange(household_key, day, trans_time) %>%
  group_by(household_key, day) %>%
  summarize(trans=n_distinct(basket_id),
            sales=sum(sales_value),
            cost=sum(combined_price),
            products=n_distinct(product_id),
            units=sum(quantity)) %>%
  mutate(cost=ifelse(is.nan(cost),sales,cost),
         disc_rate=(cost-sales)/cost) %>%
  ungroup() %>%
  group_by(household_key) %>%
  mutate(days_between=day-lag(day)) %>%
  summarize(days=n_distinct(day),
            trans=sum(trans),
            sales=mean(sales),
            cost=mean(cost),
            products=mean(products),
            units=mean(units),
            disc_rate=mean(disc_rate),
            days_between=mean(days_between, na.rm=TRUE),
            last_day=max(day))


dat <- pre101 %>%
  left_join(wk101)
  





