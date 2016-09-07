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

### save data

save_path <- "C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\data\\datasets\\tccmaldegem_ledenresultaten\\"

save(results, file = paste0(save_path, "extra_tccmaldegem_ledenresultaten.RData"))
write.csv(results, paste0(save_path, "extra_tccmaldegem_ledenresultaten.csv"))