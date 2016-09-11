### packages 

library(dplyr)
library(ggplot2)
library(lubridate)
library(htmlTable)

### load data

load("C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\data\\datasets\\tccmaldegem_ledenresultaten\\extra_tccmaldegem_ledenresultaten.RData")

### remarkable results through time

## results jeroen only

jeroen_results <- filter(results, naam == "JEROEN VAN DER HOOFT")

## date indicator

season_n <- jeroen_results %>% group_by(year(datum)) %>% summarise(n = n()) %>% .[["n"]]

jeroen_results$datum_ind  <- mapply(function(x,y) x + y,
                                    x = year(jeroen_results$datum),
                                    y = unlist(lapply(season_n,
                                                      function(x) seq(from = 0,
                                                                      to = 0.99,
                                                                      length.out = x))))
## graph

graph_result_vs_expectation <- ggplot(data = jeroen_results,
                                      aes(x = datum_ind, y = ELO_voorspelling_verschil_neg)) +
                               geom_bar(stat = "identity") +
                               scale_x_continuous(breaks = unique(year(jeroen_results$datum))) +
                               labs(title = "Verschil voorspelling/resultaat 2006-2016",
                                    x = "jaar",
                                    y = "verschil voorspelling/resultaat")

### table most remarkable victories in 2010

var_display <- c("tegenstander","klassering_tegenstander","ELO_tegenstander","ELO",
                 "klassering","ELO_voorspelling_verschil")

remarkable_victories_2010 <- filter(jeroen_results, year(datum) == "2010") %>%
                                  select(one_of(var_display)) %>%
                                      top_n(n = 10, wt = ELO_voorspelling_verschil) %>%
                                          arrange(desc(ELO_voorspelling_verschil))

### save objects

## save graphs

graphs <- grep(pattern = "graph_", x = ls(), value = TRUE)

save_path <- "C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\analysis\\output\\analysis_jvdh_fails_strikes\\"

mapply(ggsave, paste0(save_path, graphs,".png"), mget(graphs))

## save tables

html_remarkable_victories_2010 <- htmlTable(remarkable_victories_2010)
print(html_remarkable_victories_2010, type='html', file=paste0(save_path,
                                                               "remarkable_victories_2010.html"))

write.csv(remarkable_victories_2010,
          file = paste0(save_path, "remarkable_victories_2010.csv"),
          row.names = FALSE)
