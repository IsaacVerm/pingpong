### packages 

library(plyr)
library(dplyr)

### load data

load("C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\data\\datasets\\tccmaldegem_ledenresultaten\\tccmaldegem_ledenresultaten.RData")

### add variables

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

## calculate expected scores using ELO formula

results$verwachte_score <- 1/(1 + 10^((results$ELO_tegenstander - results$ELO)/400))

## numeric version result

results$resultaat_num <- as.numeric(as.character(mapvalues(x = results$resultaat,
                                                           from = c("V","W"),
                                                           to = 0:1)))

## calculate difference ELO expected versus result

results <- mutate(results, ELO_voorspelling_verschil = abs(verwachte_score - resultaat_num))

results <- mutate(results, ELO_voorspelling_verschil_neg = resultaat_num - verwachte_score)

### save data

save_path <- "C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\data\\datasets\\tccmaldegem_ledenresultaten\\"

save(results, file = paste0(save_path, "extra_tccmaldegem_ledenresultaten.RData"))
write.csv(results, paste0(save_path, "extra_tccmaldegem_ledenresultaten.csv"))