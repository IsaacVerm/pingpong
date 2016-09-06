### packages

library(rvest)
library(pbapply)
library(dplyr)
library(data.table)
library(stringr)

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

### extract match information

## function to extract

extract <- function(html) {
  
                    # match information list
  
                    match_information <- list()
  
                    # extract name
  
                    xpath_first_name <- "//div[@style='font-size: 175%;']"
                    xpath_surname <- "//div[@style='font-size: 210%;']"
                    
                    match_information$first_name <- html_node(html, xpath = xpath_first_name) %>% html_text()
                    match_information$surname <- html_node(html, xpath = xpath_surname) %>% html_text()
  
                    # extract season
                    
                    xpath_season <- "//*[text()[contains(.,'Seizoen')]]"
                    
                    match_information$season <- html_nodes(html, xpath = xpath_season) %>% html_text() %>% .[[2]]
  
                    # extract ranking
                    
                    xpath_ranking <- "//*[text()[contains(.,'Rangschikking')]]"
                    
                    match_information$ranking <- html_nodes(html, xpath = xpath_ranking) %>% html_text() %>% .[[2]]
  
                    # extract age category
                    
                    xpath_age_category <- "//*[text()[contains(.,'Categorie')]]"
                    
                    match_information$age_category <- html_nodes(html, xpath = xpath_age_category) %>% html_text() %>% .[[2]]
                    
                    # extract match results
                    
                    xpath_match_results <- "//div[@id='match_list']/table"
                    
                    match_information$match_results <- try(html_node(html, xpath = xpath_match_results) %>% html_table())
                    
                    # return result
                    
                    return(match_information) }

## extract

match_information <- lapply(htmls, function(x) extract(x))

### bind together

## remove pages without results

match_information <- match_information[!sapply(match_information, function(x) class(x[["match_results"]])) == "try-error"]

## add fixed values to results

add.fixed <- function(list_player) {
  
                      # repeat fixed values
  
                      df_fixed <- as.data.frame(lapply(list_player[1:5], function(x) rep(x, nrow(list_player[["match_results"]]))))
                      
                      # bind to results
                      
                      results <- bind_cols(list_player[["match_results"]], df_fixed)
                      
                      # return
                      
                      return(results) }

results <- lapply(match_information, add.fixed)
  
## bind

results <- rbindlist(results)

### clean

## remove empty columns

results <- select(results, -X1, -X13)

## remove rows containing no information

results <- results[complete.cases(select(results, X2:X12)), ]

results <- results[-grep(pattern = "Datum", x = results$X2), ]

## correct column names

names(results) <- c("datum","geslacht","toernooi_id","reeks","club_tegenstander","tegenstander",
                    "klassering_tegenstander","ELO_tegenstander","sets","ELO","ELO_verandering",
                    "voornaam","familienaam","seizoen","klassering","leeftijdscategorie")

## correct column values

# sets

results$gewonnen_sets <- substr(results$sets, 1, 1)
  
results$verloren_sets <- substr(results$sets, 7, 7)

results$sets <- NULL

# season

results$seizoen <- substr(results$seizoen, 9, 12)

# rating

results$klassering <- substr(results$klassering, 19, 20)

# age category

results$leeftijdscategorie <- str_trim(sapply(str_split(string = results$leeftijdscategorie, pattern = "Â"), function(x) x[3]))

## correct data types

# date

results$datum <- as.Date(results$datum)

# factor and numeric

factor_var <- c("geslacht","toernooi_id","reeks","club_tegenstander","klassering_tegenstander",
                "seizoen","klassering","leeftijdscategorie")

num_var <- c("ELO_tegenstander","ELO","ELO_verandering","gewonnen_sets","verloren_sets")

results <- results %>% mutate_each_(funs(factor), factor_var) %>% mutate_each_(funs(as.numeric), num_var)

## add variables

# name

results <- mutate(results, naam = factor(paste(voornaam, familienaam, sep = " ")))

# result

results$resultaat[results$gewonnen_sets - results$verloren_sets > 0] <- "W" 
results$resultaat[is.na(results$resultaat)] <- "V"

results$resultaat <- factor(results$resultaat)

### save objects

## save path

save_path <- "C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\data\\datasets\\tccmaldegem_ledenresultaten"

## urls

write.csv(urls, file = paste0(save_path,"\\urls_tccmaldegem_ledenresultaten.csv"), row.names = FALSE)

## htmls

mapply(write_xml, htmls, file = paste0(save_path,"\\ledenresultaten_", 1:length(htmls), ".xml"))

## results

save(results, file = paste0(save_path, "\\tccmaldegem_ledenresultaten.RData"))
write.csv(results, file = paste0(save_path, "\\tccmaldegem_ledenresultaten.csv"), row.names = FALSE)
