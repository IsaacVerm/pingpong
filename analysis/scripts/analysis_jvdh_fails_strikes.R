### packages 

library(dplyr)
library(ggplot2)

### load data

load("C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\data\\datasets\\tccmaldegem_ledenresultaten\\extra_tccmaldegem_ledenresultaten.RData")

### prepare data

## remove odd ranking categories

table(results$klassering_tegenstander)

results <- results[!results$klassering_tegenstander %in% c("A7","A26"), ]
results$klassering_tegenstander <- droplevels(results$klassering_tegenstander)

### largest quality differences

## ranking category

klassering_verschil_naam <- filter(results, resultaat == "V") %>% 
                                group_by(naam) %>% 
                                    top_n(5, desc(klassering_verschil))

## ELO
