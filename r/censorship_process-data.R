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
data.censorship %>%
  dplyr::filter(action == "S")
# implementation, certitude of an event
data.censorship.s.imp <- data.censorship %>%
    dplyr::filter(action == "S", cert == "high")
# list of titles
unique(data.censorship.s.imp$publication.title)

# aggregate by title
data.censorship.aggr.periodical <- data.censorship %>%
    dplyr::group_by(publication.id, publication.title, publication.loc.id, publication.loc, action) %>%
    dplyr::summarise(events = n()) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(desc(events), desc(publication.title))
## make into wide table
data.censorship.aggr.periodical.wide <- data.censorship.aggr.periodical %>%
    dplyr::filter(action %in% c("S", "W", "BI", "PR")) %>%
    tidyr::pivot_wider(names_from = action, values_from = events, values_fill = 0) %>%
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
    tidyr::pivot_wider(names_from = action, values_from = events, values_fill = 0) %>%
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
