### packages 

library(plyr)
library(dplyr)
library(ggplot2)

### load data

load("C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\data\\datasets\\tccmaldegem_ledenresultaten\\tccmaldegem_ledenresultaten.RData")

### prepare data

## remove odd ranking categories

table(results$klassering_tegenstander)

results <- results[!results$klassering_tegenstander %in% c("A7","A26"), ]
results$klassering_tegenstander <- droplevels(results$klassering_tegenstander)

## numerical interpretation ranking category

klassering_levels <- sort(as.character(unique(results$klassering_tegenstander)))

results$klassering_num <- mapvalues(x = results$klassering,
                                    from = klassering_levels,
                                    to = 1:length(klassering_levels))

results$klassering_tegenstander_num <- mapvalues(x = results$klassering_tegenstander,
                                                 from = klassering_levels,
                                                 to = 1:length(klassering_levels))

results$klassering_num <- as.numeric(as.character(results$klassering_num))
results$klassering_tegenstander_num <- as.numeric(as.character(results$klassering_tegenstander_num))

## calculate quality differences

# ranking category

results <- mutate(results, klassering_verschil = klassering_num - klassering_tegenstander_num)

# ELO

results <- mutate(results, ELO_verschil = ELO - ELO_tegenstander)

### calculate difference by name

## ranking category

klassering_verschil_naam <- filter(results, resultaat == "V") %>% 
                                group_by(naam) %>% 
                                    summarise(klassering_verschil = min(klassering_verschil),
                                              aantal_wedstrijden = n())

## ELO