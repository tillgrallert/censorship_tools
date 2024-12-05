# this script processes the censorship data into subsets
# load necessary packages
library(tidyverse)
library(lubridate) # for working with dates
library(here)

# read data
setwd(here("../censorship_data/csv/"))
data.censorship <- read.csv("censorship-levant.csv", header=TRUE, sep = ",", quote = "\"")

# aggregate periods
## use cut() to generate summary stats for time periods
## create variables of the year, quarter week and month of each observation:

data.censorship <- data.censorship %>%
  dplyr::mutate(date = as.Date(date.documented),
                year = as.Date(cut(date, breaks = "year")),
                quarter = as.Date(cut(date, breaks = "quarter")),
                month = as.Date(cut(date, breaks = "month")),
                week = as.Date(cut(date, breaks = "week", start.on.monday = TRUE))
                ) %>%
    tidyr::drop_na(date.documented) %>%
    dplyr::rename(action = subtype)

write.table(data.censorship, "censorship-levant_processed.csv" , row.names = F, quote = T , sep = ",")
# filter for specific types
data.censorship.s <- data.censorship %>%
  dplyr::filter(action == "S")
data.censorship.w <- data.censorship %>%
  dplyr::filter(action == "W")
# available titles, i.e. those, which I could check for gaps
data.censorship.s.imp <- data.censorship.s %>%
    dplyr::filter(cert == "high")
unique(data.censorship.s.imp$publication.id)
data.censorship.s.titles.available <- data.censorship.s %>%
    subset(publication.id %in% unique(data.censorship.s.imp$publication.id))
# aggregate by title
data.censorship.s.titles.available.wide <- data.censorship.s.titles.available %>%
    dplyr::group_by(publication.id, publication.title, publication.loc.id, publication.loc, cert) %>%
    dplyr::summarise(events = n()) %>%
    dplyr::ungroup() #%>%
    #tidyr::pivot_wider(names_from = cert, values_from = events) %>%
    #dplyr::arrange(desc("S"))

data.censorship.aggr.periodical <- data.censorship %>%
    dplyr::group_by(publication.id, publication.title, publication.loc.id, publication.loc, action) %>%
    dplyr::summarise(events = n()) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(desc(events), desc(publication.title))
## make into wide table
data.censorship.aggr.periodical.wide <- data.censorship.aggr.periodical %>%
    dplyr::filter(action %in% c("S", "W", "BI", "PR")) %>%
    tidyr::pivot_wider(names_from = action, values_from = events) %>%
    dplyr::arrange(desc("S"), desc("W"))

write.table(data.censorship.aggr.periodical.wide, "censorship_by-periodical.csv" , row.names = F, quote = T , sep = ",")

# aggregate data by year
data.censorship.aggr.year <- data.censorship %>%
  dplyr::group_by(action, cert, year) %>%
  dplyr::summarise(events = n()) %>%
  dplyr::ungroup() %>%
    tidyr::drop_na(year) %>%
    dplyr::arrange(year)
## make into wide table
data.censorship.aggr.year.wide <- data.censorship.aggr.year %>%
    dplyr::group_by(action, year) %>%
    dplyr::summarise(events = sum(events)) %>%
    dplyr::filter(action %in% c("S", "W", "BI", "PR")) %>%
    tidyr::pivot_wider(names_from = action, values_from = events) %>%
    dplyr::arrange(year)

write.table(data.censorship.aggr.year.wide, "censorship_by-year.csv" , row.names = F, quote = T , sep = ",")

w <- data.censorship.aggr.year %>%
    dplyr::filter(action == "W")
s <- data.censorship.aggr.year %>%
    dplyr::filter(action == "S")
s.imp <- data.censorship.aggr.year %>%
    dplyr::filter(action == "S",
                  cert == "high")
sum(w$events)
sum(s$events)
sum(s.imp$events)
#f.percent(sum(s$events), sum(s.imp$events))
