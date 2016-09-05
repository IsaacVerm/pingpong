### packages

library(rvest)
library(pbapply)

### load htmls list of members

## load path

load_path <- "C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\data\\datasets\\tccmaldegem_ledenlijst"

## load

htmls <- lapply(list.files(load_path,
                           pattern = ".xml",
                           full.names = TRUE),
                read_html)

### urls individual results members

## xpath link to individual results

xpath_result <- "//img[@alt='Resultaten']/.."

## extract href

urls <- lapply(htmls,
               function(x) try(html_attr(html_nodes(x, xpath = xpath_result), "href")))

## add fixed part 

urls <- unique(paste0("http://competitie.vttl.be", unlist(urls)))

## results each season

season_ind <- 7:17

urls <- paste0(rep(urls, each = length(season_ind)), "&season=", rep(season_ind, times = length(urls)))

htmls <- pblapply(urls,
                  function(x) try(read_html(x)))

### extract matches

### bind together

### save objects

## save path

save_path <- "C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\data\\datasets\\tccmaldegem_ledenresultaten"

## urls

write.csv(urls, file = paste0(save_path,"\\urls_tccmaldegem_ledenresultaten.csv"), row.names = FALSE)

## htmls

mapply(write_xml, htmls, file = paste0(save_path,"\\ledenresultaten_", 1:length(htmls), ".xml"))
