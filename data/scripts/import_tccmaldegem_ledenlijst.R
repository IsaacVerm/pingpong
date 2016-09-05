### packages

library(rvest)
library(data.table)

### urls

## base url

base_url <- "http://competitie.vttl.be/index.php?menu=6&categ_id=29&club_id=269&season="

## indicators end of url

season_ind <- 7:17

page_ind <- c("&cur_page=1","&cur_page=2")

## urls

urls <- sapply(season_ind, function(x) paste0(base_url,
                                              x))

urls <- paste0(urls,
               rep(page_ind, each = length(urls)))

### parse

htmls <- lapply(urls, read_html)

### list of members

## raw table

select.members <- function(html) {
  
                  xpath_table <- "//*[text()[contains(.,'Spelers')]]/following::table[1]"
  
                  html_nodes(html, xpath = xpath_table) %>%
                      html_table() %>%
                        .[[1]] }
                    
members <- lapply(htmls, select.members)

## cleaned table

# bind together

members_df <- rbindlist(members)
members_df <- as.data.frame(members_df)

# add season

seasons <- sapply(members, nrow)
names(seasons) <- rep(season_ind, 2)

members_df$seizoen <- unlist(mapply(rep, names(seasons), seasons))

# remove empty columns

members_df <- as.data.frame(members_df[, c(2:5,8)])

# remove empty rows

members_df <- members_df[complete.cases(members_df), ]

# remove duplicate rows (because page 2 is requested and page 1 is returned if non-existent)

members_df <- members_df[!duplicated(members_df), ]

# correct column names

names(members_df) <- c("lidnummer","naam","voornaam","klassering","seizoen")

# remove column names within dataframe

members_df <- members_df[-grep(pattern = "Lidnummer",
                               x = members_df$lidnummer), ]

### save objects

## save path

save_path <- "C:\\Users\\Felix Timmermans\\Desktop\\pingpong\\data\\datasets\\tccmaldegem_ledenlijst"

## members overview

save(members_df, file = paste0(save_path,"\\tccmaldegem_ledenlijst.RData"))
write.csv(members_df, file = paste0(save_path,"\\tccmaldegem_ledenlijst.csv"), row.names = FALSE)

## htmls members

mapply(write_xml, htmls, file = paste0(save_path,"\\ledenlijst_", 1:length(htmls), ".xml"))

## urls members

write.csv(urls, file = paste0(save_path,"\\urls_tccmaldegem_ledenlijst.csv"), row.names = FALSE)
