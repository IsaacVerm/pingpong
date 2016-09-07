### packages 

library(plyr)
library(dplyr)
library(ggplot2)

### load data

load("C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\data\\datasets\\tccmaldegem_ledenresultaten\\extra_tccmaldegem_ledenresultaten.RData")

### prepare data

## remove odd ranking categories

table(results$klassering_tegenstander)

results <- results[!results$klassering_tegenstander %in% c("A7","A26"), ]
results$klassering_tegenstander <- droplevels(results$klassering_tegenstander)

## remove matches without ELO difference

results <- results[!is.na(results$ELO_verschil), ]

### drawbacks categorical ranking

## ELO variation within category

graph_elo_within_category <- ggplot(data = results,
                                    aes(x = ELO)) +
                             geom_histogram(bins = 10) +
                             facet_wrap(~klassering, scales = "free") +
                             labs(title = "ELO variatie binnen klassering",
                                  x = "ELO",
                                  y = "aantal wedstrijden")

plot(graph_elo_within_category)

## bias towards higher categories

bias_higher_categories <- results %>% 
                              group_by(klassering) %>%
                                  summarise(min_verschil = abs(min(klassering_verschil))) %>%
                                      arrange(min_verschil)

graph_bias_higher_categories <- ggplot(data = bias_higher_categories,
                                       aes(x = klassering, y = min_verschil)) +
                                geom_bar(stat = "identity") +
                                labs(title = "Bias richting hogere klasseringen",
                                     x = "klassering",
                                     y = "maximale nederlaag")

plot(graph_bias_higher_categories)

### drawbacks ELO

## maximum ELO difference

max(abs(results$ELO_verschil), na.rm = TRUE)

## calculate expected scores

results$verwachte_score <- 1/(1 + 10^((results$ELO_tegenstander - results$ELO)/400))

## divide in ELO groups

results <- arrange(results, ELO_verschil)

nr_groups <- 20
results$ELO_groep <- factor(rep(1:nr_groups, each = nrow(results)/nr_groups))

results$ELO_groep[(nrow(results) - 100):nrow(results)] <- nr_groups 

## calculate difference average expected score / average victory percentage by ELO group

results$resultaat_num <- as.numeric(as.character(mapvalues(x = results$resultaat,
                                                           from = c("V","W"),
                                                           to = 0:1)))

results <- mutate(results, ELO_voorspelling_verschil = abs(verwachte_score - resultaat_num))

results$ELO_correct <- 1
results$ELO_correct[results$ELO_voorspelling_verschil >= 0.5] <- 0

expected_score_difference <- results %>%
                                  group_by(ELO_groep) %>%
                                      summarize(avg = mean(ELO_correct),
                                                n = n())

## display difference average expected score / average victory percentage

graph_expected_score_difference <- ggplot(data = expected_score_difference,
                                          aes(x = ELO_groep, y = avg)) +
                                   geom_bar(stat = "identity")

plot(graph_expected_score_difference)
                              
### save objects
