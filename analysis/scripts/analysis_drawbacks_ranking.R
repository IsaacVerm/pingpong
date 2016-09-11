### packages 

library(plyr)
library(dplyr)
library(ggplot2)
library(stringr)

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

## divide in ELO groups

# add groups

results <- arrange(results, ELO_verschil)

nr_groups <- 50
results$ELO_groep <- factor(rep(1:nr_groups, each = nrow(results)/nr_groups))

# last group is a little larger since division rarely results in integer

overflow <- as.numeric(str_extract(string = names(warnings()),
                                   pattern = "\\d+(?= items\\))"))

results$ELO_groep[(nrow(results) - overflow):nrow(results)] <- nr_groups 

## calculate difference average expected score / average victory percentage by ELO group

expected_score_difference <- results %>%
                                  group_by(ELO_groep) %>%
                                      summarize(incorrecte_voorspelling = round(mean(ELO_voorspelling_verschil > 0.5) * 100,
                                                                                digits = 0),
                                                ELO_min = min(ELO_verschil),
                                                ELO_max = max(ELO_verschil)) %>%
                                                    mutate(ELO_range = paste0("[",
                                                                              ELO_min,
                                                                              ";",
                                                                              ELO_max,
                                                                              "]"))
expected_score_difference$ELO_range <- factor(expected_score_difference$ELO_range,
                                              levels = expected_score_difference$ELO_range)

## display difference average expected score / average victory percentage

graph_expected_score_difference <- ggplot(data = expected_score_difference,
                                          aes(x = ELO_range, y = incorrecte_voorspelling)) +
                                   geom_line(group = 1) + 
                                   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
                                   labs(title = "Hoe goed zijn de ELO voorspellingen?",
                                        x = "ELO groep",
                                        y = "Percentage incorrecte voorspellingen per groep")

plot(graph_expected_score_difference)
                              
### save graphs

graphs <- grep(pattern = "graph_", x = ls(), value = TRUE)

save_path <- "C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\analysis\\output\\analysis_drawbacks_ranking\\"

mapply(ggsave, paste0(save_path, graphs,".png"), mget(graphs))



