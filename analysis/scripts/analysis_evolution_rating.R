### packages 

library(dplyr)
library(ggplot2)

### load data

load("C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\data\\datasets\\tccmaldegem_ledenresultaten\\extra_tccmaldegem_ledenresultaten.RData")

### prepare data

## remove matches without ELO or leeftijdscategorie

ELO_na <- which(is.na(results$ELO))
leeftijdscategorie_na <- which(is.na(results$leeftijdscategorie))

results <- results[-union(ELO_na, leeftijdscategorie_na), ]

## find players having started as cadette

cadette <- results %>%
                group_by(naam) %>%
                    summarise(cadet = sum("Cadetten" %in% leeftijdscategorie)) %>%
                        filter(cadet == "1")

cadette_players <- as.character(cadette$naam)

## find players having no gaps for 5 consecutive seasons

consecutive <- results %>%
                    group_by(naam, seizoen) %>%
                        summarise(n = n()) %>%
                            group_by(naam) %>%
                                summarise(n = n(),
                                          opeenvolgend = sum(diff(as.numeric(as.character(seizoen))) > 1)) %>%
                                      filter(opeenvolgend == "0", n >= 5)

consecutive_players <- as.character(consecutive$naam)

## only select players having no gaps + started as cadette

results <- droplevels(filter(results, naam %in% intersect(cadette_players, consecutive_players)))

## add match number for each player

results <- arrange(results, naam)

results$match_nummer <- unlist(lapply(table(results$naam), function(x) 1:x))

## make sure there are no sudden ELO drops

results <- arrange(results, naam, datum)

drops_ind <- which(abs(diff(results$ELO)) > 100)

drops <- results[sort(c(drops_ind, drops_ind - 1)), ]



which(abs(diff(filter(results, naam == "JEROEN VAN DER HOOFT")[["ELO"]])) > 100)

### graph evolution

graph_evolution_rating <- ggplot(data = filter(results, naam == "JEROEN VAN DER HOOFT"),
                                 aes(x = match_nummer, y = ELO, group = naam)) +
                          geom_line(aes(colour = naam))

plot(graph_evolution_rating)